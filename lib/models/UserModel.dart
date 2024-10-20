import 'dart:io';

import 'package:pocketbase/pocketbase.dart';
import 'package:gazette/services/PocketBaseService.dart';

class User {
  final String id;
  final DateTime? created;
  final DateTime? updated;
  final String collectionId;
  final String collectionName;
  final String email;
  final bool emailVisibility;
  final String username;
  final bool verified;
  final String avatarFileName;
  final String firstname;
  final String lastname;
  Uri? avatarUri;
  String? token;

  User({
    required this.id,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.email,
    required this.emailVisibility,
    required this.username,
    required this.verified,
    required this.firstname,
    required this.lastname,
    required this.avatarFileName,
    required this.avatarUri,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      created: DateTime.tryParse(json["created"] ?? ""),
      updated: DateTime.tryParse(json["updated"] ?? ""),
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      email: json["email"],
      emailVisibility: json["emailVisibility"],
      username: json["username"],
      verified: json["verified"],
      avatarFileName: json["avatar"],
      avatarUri: json["avatarUri"],
      firstname: json["firstname"],
      lastname: json["lastname"],
    );
  }

  factory User.fromRecord(RecordModel record) {
    User user = User.fromJson(record.toJson());
    if (user.avatarFileName.isNotEmpty) {
      user.avatarUri =
          PocketbaseService.to.getFileUrl(record, user.avatarFileName);
    }
    return user;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "email": email,
        "emailVisibility": emailVisibility,
        "username": username,
        "verified": verified,
        "token": token,
        "firstname": firstname,
        "lastname": lastname,
        "avatar": avatarFileName,
        "avatarUri": avatarUri,
      };
}
