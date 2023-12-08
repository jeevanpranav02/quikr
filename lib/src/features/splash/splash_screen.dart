import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../config/app_asset_path.dart';
import '../../config/app_secure_storage.dart';
import '../auth/onboarding_page.dart';
import '../home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isUidPresent = false;
  String? uid;
  Future<void> checkForAuthToken() async {
    uid = await AppSecureStorage.getUID();
    log('UID: $uid');
    if (uid != null) {
      isUidPresent = true;
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () async {
        await checkForAuthToken();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (isUidPresent) {
                return const HomePage();
              } else {
                return const OnBoardingPage();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          AppAssetPath.SPLASH,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
