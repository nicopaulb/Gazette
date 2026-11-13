import 'package:pocketbase/pocketbase.dart';
import 'package:gazette/services/PocketBaseService.dart';

class User {
  final String id;
  final DateTime? created;
  final DateTime? updated;
  final String collectionId;
  final String collectionName;
  final String username;
  final String avatarFileName;
  final String firstname;
  final String lastname;
  final bool admin;
  // URL without file token, the token is added on read by avatarUri
  String? avatarBaseUri;
  String? token;

  User({
    required this.id,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.avatarFileName,
    required this.avatarBaseUri,
    required this.admin,
    this.token,
  });

  String? get avatarUri => avatarBaseUri == null ? null : PocketbaseService.to.signFileUrl(avatarBaseUri);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        created: DateTime.tryParse(json["created"] ?? ""),
        updated: DateTime.tryParse(json["updated"] ?? ""),
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        username: json["username"],
        avatarFileName: json["avatar"] ?? "",
        avatarBaseUri: json["avatarUri"] ?? "",
        firstname: json["firstname"] ?? "",
        lastname: json["lastname"] ?? "",
        admin: json["priviliged"].toString() == "true",
        token: json["token"]);
  }

  factory User.fromRecord(RecordModel record) {
    User user = User.fromJson(record.toJson());
    if (user.avatarFileName.isNotEmpty) {
      user.avatarBaseUri = PocketbaseService.to.getFileUrl(record, user.avatarFileName).toString();
    }
    return user;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "username": username,
        "token": token,
        "firstname": firstname,
        "lastname": lastname,
        "avatar": avatarFileName,
        "avatarUri": avatarBaseUri.toString(),
        "priviliged": admin.toString()
      };

  String getResizedAvatar() {
    return PocketbaseService.to.signFileUrl(avatarBaseUri, thumb: "200x200");
  }
}
