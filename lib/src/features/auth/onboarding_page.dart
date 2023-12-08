// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/components/prompt_button.dart';
import '../../common/constants/constants.dart';
import '../../common/models/user_model.dart';
import '../../common/repository/firebase_auth_repository.dart';
import '../../common/repository/firebase_firestore_repository.dart';
import '../../config/app_asset_path.dart';
import '../../config/app_colors.dart';
import '../../config/app_layout.dart';
import '../../config/app_secure_storage.dart';
import '../home/home_page.dart';
import '../utils/date_util.dart';
import '../utils/vaildator_util.dart';
import 'components/custom_text_field.dart';

class OnBoardingPage extends ConsumerStatefulWidget {
  const OnBoardingPage({super.key});

  static const String routeName = '/login';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends ConsumerState<OnBoardingPage> {
  int _currentIndex = 0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Container(
              height: height,
              width: width,
              padding: EdgeInsets.only(
                bottom: height * 0.4,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryAccentColorLight,
              ),
              child: Center(
                child: Image.asset(
                  AppAssetPath.MESSAGES,
                  width: width * 0.16,
                  height: width * 0.15,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: width,
                height: _currentIndex == 0 ? height * 0.4 : height * 0.5,
                decoration: BoxDecoration(
                  borderRadius: AppLayout.borderRadiusMediumTopLeftAndTopRight,
                  color: AppColors.white,
                ),
                padding: AppLayout.paddingSmall,
                child: loginOrSignUp(_currentIndex, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loginOrSignUp(int currentIndex, BuildContext context) {
    switch (currentIndex) {
      case 0:
        return getLoginWidget(context);
      case 1:
        return getterWidgetForUserDetails(context);
      default:
        return getLoginWidget(context);
    }
  }

  Future<bool> signUpUser(context) async {
    try {
      final userCredential =
          await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );
      log("From signUp : $userCredential");
      await login(context);
      setState(() {
        _currentIndex = 1;
      });
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'email-already-in-use') {
        log('SignUp Page: User already exists');
        bool loggedIn = await login(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back!'),
          ),
        );
        return loggedIn;
      } else if (e.code == 'weak-password') {
        log('SignUp Page: Weak password');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weak password'),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> saveUserToDB() async {
    String displayName = displayNameController.text;
    String? uid = await AppSecureStorage.getUID();
    String email = emailController.text;
    String phoneNumber = phoneNumberController.text;
    int createdAt = DateUtil.getEpochFromDate(DateTime.now());
    int lastSeen = DateUtil.getEpochFromDate(DateTime.now());
    bool active = false;
    final userModel = UserModel(
      displayName: displayName,
      uid: uid!,
      active: active,
      email: email,
      createdAt: createdAt,
      lastSeen: lastSeen,
      phoneNumber: phoneNumber,
    );

    bool userAdded =
        await ref.read(firebaseFirestoreRepositoryProvider).addUserDocument(
              Constants.usersCollection,
              uid,
              userModel.toMap(),
            );
    return userAdded;
  }

  Future<bool> login(context) async {
    try {
      final userCredential =
          await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              );
      log("From login : $userCredential");
      bool uidSaved = await saveUID();
      if (!uidSaved) {
        log('Login Page: UID not saved');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UID not saved'),
          ),
        );
        return false;
      } else {
        log('Login Page: UID saved');
        return true;
      }
    } catch (e) {
      log('Login Page: Login failed');
      log(e.toString());
      return false;
    }
  }

  Future<bool> saveUID() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    final uid = user!.uid;
    await AppSecureStorage.setUID(uid);
    return await AppSecureStorage.isUIDSet();
  }

  Widget getLoginWidget(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter email';
                } else if (!ValidatorUtil.isEmailValid(value)) {
                  return 'Please enter valid email';
                }
                return null;
              },
              controller: emailController,
              hint: 'Email',
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter password';
                } else if (!ValidatorUtil.isPasswordStrong(value)) {
                  return 'Please enter strong password';
                }
                return null;
              },
              controller: passwordController,
              hint: 'Password',
              isPassword: true,
            ),
          ),
          PromptButton(
            onPressed: () async {
              _formKey.currentState!.validate();
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                bool loginSuccess = await signUpUser(context);
                if (loginSuccess) {
                  log('Login Page: Login success');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login Success'),
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomePage.routeName,
                    (route) => false,
                  );
                } else {
                  log('Login Page: Login failed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login failed'),
                    ),
                  );
                }
              } else {
                log('Login Page: Empty fields');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                  ),
                );
              }
            },
            textContent: 'Get Started',
            height: height * 0.05,
            width: width * 0.5,
            isEnabled: true,
            isEnabledColor: AppColors.primaryColor,
            textContentColor: AppColors.primaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget getterWidgetForUserDetails(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
              controller: displayNameController,
              hint: 'Name',
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter phone number';
                } else if (!ValidatorUtil.isPhoneNumberValid(value)) {
                  return 'Please enter valid phone number';
                }
                return null;
              },
              controller: phoneNumberController,
              hint: 'Phone Number',
            ),
          ),
          PromptButton(
            onPressed: () async {
              _formKey.currentState!.validate();
              bool displayNameUpdated = await ref
                  .read(firebaseAuthRepositoryProvider)
                  .updateUserDisplayName(
                    displayName: displayNameController.text,
                  );
              if (!displayNameUpdated) {
                log('SignUp Page: Display name not updated');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Display name not updated'),
                  ),
                );
              }
              bool userPhotoURLUpdated = await ref
                  .read(firebaseAuthRepositoryProvider)
                  .updateUserPhotoURL(
                    photoURL: Constants.defaultProfilePic,
                  );
              if (!userPhotoURLUpdated) {
                log('SignUp Page: User photo URL not updated');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User photo URL not updated'),
                  ),
                );
              }
              bool userAdded = await saveUserToDB();
              if (!userAdded) {
                log('SignUp Page: User not added to DB');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User not added to DB'),
                  ),
                );
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomePage.routeName,
                (route) => false,
              );
            },
            textContent: 'Update Profile',
            height: height * 0.05,
            width: width * 0.5,
            isEnabled: true,
            isEnabledColor: AppColors.primaryColor,
            textContentColor: AppColors.primaryTextColor,
          ),
        ],
      ),
    );
  }
}
