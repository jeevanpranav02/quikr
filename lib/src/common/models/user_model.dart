import '../../features/utils/date_util.dart';

class UserModel {
  final String displayName;
  final String uid;
  final String email;
  String photoUrl;
  final bool active;
  final int createdAt;
  final int lastSeen;
  final String phoneNumber;

  UserModel({
    required this.displayName,
    required this.uid,
    this.photoUrl =
        'https://www.kindpng.com/picc/m/24-248417_transparent-twitter-emblem-png-emblem-png-download.png',
    required this.active,
    required this.email,
    required this.createdAt,
    required this.lastSeen,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
      'active': active,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      active: map['active'] ?? false,
      createdAt: map['createdAt'] ?? DateUtil.getEpochFromDate(DateTime.now()),
      lastSeen: map['lastSeen'] ?? DateUtil.getEpochFromDate(DateTime.now()),
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  String get getDisplayName => displayName;
  String get getUid => uid;
  String get getEmail => email;
  String get getPhotoUrl => photoUrl;
  bool get getActive => active;
  int get getCreatedAt => createdAt;
  int get getLastSeen => lastSeen;
  String get getPhoneNumber => phoneNumber;
}
