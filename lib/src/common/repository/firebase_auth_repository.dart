import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

class FirebaseAuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository(this._auth);

  Future<bool> updateUserDisplayName({
    required String displayName,
  }) async {
    try {
      await _auth.currentUser!.updateDisplayName(displayName);
      return true;
    } catch (e) {
      log('Error when updating displayName : $e');
      return false;
    }
  }

  Future<bool> updateUserPhotoURL({
    required String photoURL,
  }) async {
    try {
      await _auth.currentUser!.updatePhotoURL(photoURL);
      return true;
    } catch (e) {
      log('Error when updating photoURL : $e');
      return false;
    }
  }

  Future<bool> updateUserEmail({
    required String email,
  }) async {
    try {
      await _auth.currentUser!.updateEmail(email);
      return true;
    } catch (e) {
      log('Error when updating email : $e');
      return false;
    }
  }
}
