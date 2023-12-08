// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/components/prompt_button.dart';
import '../../../common/repository/firebase_auth_repository.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_layout.dart';
import '../../../config/app_secure_storage.dart';
import '../../auth/onboarding_page.dart';
import '../repository/user_repository.dart';

class ProfileWidget extends ConsumerStatefulWidget {
  const ProfileWidget({super.key});

  static const appBarTitle = 'Profile';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends ConsumerState<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: AppLayout.paddingSmall,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: PromptButton(
          onPressed: () async {
            bool signedOut = await _signOut();
            if (signedOut) {
              String? uid = await AppSecureStorage.getUID();
              if (uid != null) {
                log('UID is not null : $uid');
                await AppSecureStorage.deleteAll();
              } else {
                log('UID is null');
              }
              ref
                  .read(userRepositoryProvider)
                  .updateUserPresenceStatusOffline(uid: uid);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  OnBoardingPage.routeName, (Route<dynamic> route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed Out'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign Out Failed'),
                ),
              );
            }
          },
          textContent: 'Sign Out',
          height: height * 0.06,
          width: width * 0.5,
          isEnabled: true,
          textContentColor: AppColors.primaryTextColor,
          isEnabledColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  Future<bool> _signOut() async {
    try {
      await ref.read(firebaseAuthProvider).signOut();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
