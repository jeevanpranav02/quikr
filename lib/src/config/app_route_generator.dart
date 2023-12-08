import 'package:flutter/material.dart';

import '../common/models/user_model.dart';
import '../features/auth/onboarding_page.dart';
import '../features/home/home_page.dart';
import '../features/home/message/components/custom_message_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case OnBoardingPage.routeName:
        return MaterialPageRoute(builder: (_) => const OnBoardingPage());
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case CustomMessageScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => CustomMessageScreen(
            userModel: args as UserModel,
          ),
        );
      default:
        return unknownRoute(settings);
    }
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
