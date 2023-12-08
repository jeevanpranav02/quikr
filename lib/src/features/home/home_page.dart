// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/repository/firebase_auth_repository.dart';
import '../../config/app_text.dart';
import 'message/components/custom_message_screen.dart';
import 'message/message_widget.dart';
import 'profile/profile_widget.dart';
import 'providers/user_search_provider.dart';
import 'repository/user_repository.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  final String title = "Home Page";

  static const String routeName = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<Widget> items = [
    const MessageWidget(),
    const ProfileWidget(),
  ];

  String switchAppBarTitle(int index) {
    switch (index) {
      case 0:
        return MessageWidget.appBarTitle;
      case 1:
        return ProfileWidget.appBarTitle;
      default:
        return MessageWidget.appBarTitle;
    }
  }

  Future<void> updateUserPresenceStatus() async {
    String? uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    try {
      await ref.read(userRepositoryProvider).updateUserPresenceStatus(uid: uid);
    } catch (e) {
      log('error cannot update online status : $e');
    }
  }

  Future<void> updateUserPresenceStatusOffline() async {
    String? uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    try {
      await ref
          .read(userRepositoryProvider)
          .updateUserPresenceStatusOffline(uid: uid);
    } catch (e) {
      log('error cannot update online status : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updateUserPresenceStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.resumed) {
      log('resumed');
      updateUserPresenceStatus();
    } else {
      log('paused');
      updateUserPresenceStatusOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switchAppBarTitle(_currentIndex),
          style: AppText.textStyleAppBar,
        ),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    String? searchResult = await showSearch(
                      context: context,
                      delegate: UserSearchProvider(),
                    );
                    if (searchResult != null && searchResult.isNotEmpty) {
                      log('searchResult: $searchResult');
                      final user = await ref
                          .read(userRepositoryProvider)
                          .getUserDetailsFromUID(searchResult);
                      Navigator.of(context).pushNamed(
                        CustomMessageScreen.routeName,
                        arguments: user,
                      );
                    }
                  },
                ),
              ]
            : null,
      ),
      body: items[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
