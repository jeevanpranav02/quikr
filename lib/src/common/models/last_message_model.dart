class LastMessageModel {
  final String username;
  final String profileImageUrl;
  final String senderId;
  final int timeSent;
  final String lastMessage;

  LastMessageModel({
    required this.username,
    required this.profileImageUrl,
    required this.senderId,
    required this.timeSent,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
      'senderId': senderId,
      'timeSent': timeSent,
      'lastMessage': lastMessage,
    };
  }

  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      senderId: map['senderId'] ?? '',
      timeSent: map['timeSent'],
      lastMessage: map['lastMessage'] ?? '',
    );
  }

  String get getUsername => username;
  String get getProfileImageUrl => profileImageUrl;
  String get getSenderId => senderId;
  int get getTimeSent => timeSent;
  String get getLastMessage => lastMessage;
}
