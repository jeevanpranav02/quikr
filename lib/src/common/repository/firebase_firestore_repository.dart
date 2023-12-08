import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseFirestoreRepositoryProvider =
    Provider<FirebaseFirestoreRepository>((ref) {
  return FirebaseFirestoreRepository(ref.watch(firebaseFirestoreProvider));
});

class FirebaseFirestoreRepository {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreRepository(this._firestore);

  Future<QuerySnapshot> getCollection(String collectionName) async {
    return await _firestore.collection(collectionName).get();
  }

  Future<DocumentSnapshot> getDocument(
      String collectionName, String documentId) async {
    return await _firestore.collection(collectionName).doc(documentId).get();
  }

  Future<bool> addDocument(
      String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      return true;
    } catch (e) {
      log('error adding document: $e');
      return false;
    }
  }

  Future<bool> addUserDocument(
      String collectionName, String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(userId).set(data);
      return true;
    } catch (e) {
      log('error adding document: $e');
      return false;
    }
  }

  Future<List<UserModel>> getUserUidList(String collectionName) async {
    List<UserModel> userList = [];
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      for (var element in querySnapshot.docs) {
        userList.add(UserModel.fromMap(element.data() as Map<String, dynamic>));
      }
    } catch (e) {
      log('error getting document: $e');
    }
    return userList;
  }
}
