import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/constants/constants.dart';
import '../../../common/models/user_model.dart';
import '../../../common/repository/firebase_auth_repository.dart';
import '../../../common/repository/firebase_firestore_repository.dart';
import '../../utils/date_util.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

class UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  UserRepository({required this.firestore, required this.auth});

  Future<UserModel?> getUserDetailsFromUID(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection(Constants.usersCollection).doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(documentSnapshot.data()! as Map<String, dynamic>);
      return userModel;
    } catch (e) {
      log('error getting document: $e');
      return null;
    }
  }

  Future<List<UserModel>> getUserUidList(String collection) async {
    List<UserModel> userList = [];
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection(Constants.usersCollection).get();
      for (var element in querySnapshot.docs) {
        userList.add(UserModel.fromMap(element.data() as Map<String, dynamic>));
      }
    } catch (e) {
      log('error getting document: $e');
    }
    return userList;
  }

  Stream<UserModel> getUserPresenceStatus({required String uid}) {
    return firestore
        .collection(Constants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  Future<void> updateUserPresenceStatus({required String? uid}) async {
    if (uid != null && uid.isNotEmpty) {
      try {
        await firestore
            .collection(Constants.usersCollection)
            .doc(uid)
            .update({'active': true});
      } catch (e) {
        log('error updating document: $e');
      }
    }
  }

  Future<void> updateUserPresenceStatusOffline({required String? uid}) async {
    if (uid != null && uid.isNotEmpty) {
      try {
        await firestore
            .collection(Constants.usersCollection)
            .doc(uid)
            .update({'active': false});
        await firestore
            .collection(Constants.usersCollection)
            .doc(uid)
            .update({'lastSeen': DateUtil.getEpochFromDate(DateTime.now())});
      } catch (e) {
        log('error updating document: $e');
      }
    }
  }
}
