import '../enum/message_type.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String textMessage;
  final MessageType type;
  final int timeSent;
  final String messageId;
  final bool isSeen;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.textMessage,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "textMessage": textMessage,
      "type": type.type,
      "timeSent": timeSent,
      "messageId": messageId,
      "isSeen": isSeen,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map["senderId"],
      receiverId: map["receiverId"],
      textMessage: map["textMessage"],
      type: (map["type"] as String).toEnum(),
      timeSent: map["timeSent"],
      messageId: map["messageId"],
      isSeen: map["isSeen"] ?? false,
    );
  }

  String get getSenderId => senderId;
  String get getReceiverId => receiverId;
  String get getTextMessage => textMessage;
  MessageType get getType => type;
  int get getTimeSent => timeSent;
  String get getMessageId => messageId;
  bool get getIsSeen => isSeen;
}
