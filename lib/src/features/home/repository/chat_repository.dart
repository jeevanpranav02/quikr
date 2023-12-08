import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/constants/constants.dart';
import '../../../common/enum/message_type.dart';
import '../../../common/helper/helper.dart';
import '../../../common/models/last_message_model.dart';
import '../../../common/models/message_model.dart';
import '../../../common/models/user_model.dart';
import '../../../common/repository/firebase_auth_repository.dart';
import '../../../common/repository/firebase_firestore_repository.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<MessageModel>> getAllOneToOneMessage(String receiverId) {
    return firestore
        .collection(Constants.usersCollection)
        .doc(auth.currentUser!.uid)
        .collection(Constants.chatsCollection)
        .doc(receiverId)
        .collection(Constants.messagesCollection)
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var message in event.docs) {
        messages.add(MessageModel.fromMap(message.data()));
      }
      return messages;
    });
  }

  Stream<List<LastMessageModel>> getAllLastMessageList() {
    return firestore
        .collection(Constants.usersCollection)
        .doc(auth.currentUser!.uid)
        .collection(Constants.chatsCollection)
        .snapshots()
        .asyncMap((event) async {
      List<LastMessageModel> contacts = [];
      for (var document in event.docs) {
        final lastMessage = LastMessageModel.fromMap(document.data());
        final userData = await firestore
            .collection(Constants.usersCollection)
            .doc(lastMessage.getSenderId)
            .get();
        final user = UserModel.fromMap(userData.data()!);
        contacts.add(
          LastMessageModel(
            username: user.getDisplayName,
            profileImageUrl: user.getPhotoUrl,
            senderId: lastMessage.getSenderId,
            timeSent: lastMessage.timeSent,
            lastMessage: lastMessage.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  void sendTextMessage({
    required BuildContext context,
    required String textMessage,
    required String receiverId,
    required UserModel? senderData,
  }) async {
    try {
      final timeSent = DateTime.now().millisecondsSinceEpoch;
      final receiverDataMap = await firestore
          .collection(Constants.usersCollection)
          .doc(receiverId)
          .get();
      final receiverData = UserModel.fromMap(receiverDataMap.data()!);
      final textMessageId = const Uuid().v1();

      _saveToMessageCollection(
        receiverId: receiverId,
        textMessage: textMessage,
        timeSent: timeSent,
        textMessageId: textMessageId,
        senderUsername: senderData!.getDisplayName,
        receiverUsername: receiverData.getDisplayName,
        messageType: MessageType.text,
      );

      _saveAsLastMessage(
        senderUserData: senderData,
        receiverUserData: receiverData,
        lastMessage: textMessage,
        timeSent: timeSent,
        receiverId: receiverId,
      );
    } catch (e) {
      Helper.showAlertDialog(context: context, message: e.toString());
    }
  }

  void _saveToMessageCollection({
    required String receiverId,
    required String textMessage,
    required int timeSent,
    required String textMessageId,
    required String senderUsername,
    required String receiverUsername,
    required MessageType messageType,
  }) async {
    final message = MessageModel(
      senderId: auth.currentUser!.uid,
      receiverId: receiverId,
      textMessage: textMessage,
      type: messageType,
      timeSent: timeSent,
      messageId: textMessageId,
      isSeen: false,
    );

    // sender
    await firestore
        .collection(Constants.usersCollection)
        .doc(auth.currentUser!.uid)
        .collection(Constants.chatsCollection)
        .doc(receiverId)
        .collection(Constants.messagesCollection)
        .doc(textMessageId)
        .set(message.toMap());

    // receiver
    await firestore
        .collection(Constants.usersCollection)
        .doc(receiverId)
        .collection(Constants.chatsCollection)
        .doc(auth.currentUser!.uid)
        .collection(Constants.messagesCollection)
        .doc(textMessageId)
        .set(message.toMap());
  }

  void _saveAsLastMessage({
    required UserModel senderUserData,
    required UserModel receiverUserData,
    required String lastMessage,
    required int timeSent,
    required String receiverId,
  }) async {
    try {
      final receiverLastMessage = LastMessageModel(
        username: senderUserData.getDisplayName,
        profileImageUrl: senderUserData.getPhotoUrl,
        senderId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: lastMessage,
      );

      await firestore
          .collection(Constants.usersCollection)
          .doc(receiverId)
          .collection(Constants.chatsCollection)
          .doc(auth.currentUser!.uid)
          .set(receiverLastMessage.toMap());
    } catch (e) {
      log("Error saving last message: $e");
    }

    try {
      final senderLastMessage = LastMessageModel(
        username: receiverUserData.getDisplayName,
        profileImageUrl: receiverUserData.getPhotoUrl,
        senderId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: lastMessage,
      );

      await firestore
          .collection(Constants.usersCollection)
          .doc(auth.currentUser!.uid)
          .collection(Constants.chatsCollection)
          .doc(receiverId)
          .set(senderLastMessage.toMap());
    } catch (e) {
      log("Error saving last message: $e");
    }
  }
}
