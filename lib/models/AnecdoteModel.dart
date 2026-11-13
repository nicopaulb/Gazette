import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/models/UserModel.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:pocketbase/pocketbase.dart';

class Anecdote {
  final String id;
  final DateTime? created;
  final DateTime? updated;
  final String collectionId;
  final String collectionName;
  final String userId;
  final DateTime? date;
  final String text;
  final String imageFileName;
  bool published;
  final String newspaperId;
  // URL without file token, the token is added on read by imageUri
  String? imageBaseUri;
  User? user;
  Newspaper? newspaper;
  String? token;

  Anecdote({
    required this.id,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.userId,
    required this.date,
    required this.text,
    required this.imageFileName,
    required this.published,
    required this.newspaperId,
    required this.imageBaseUri,
    this.token,
  });

  String? get imageUri => imageBaseUri == null ? null : PocketbaseService.to.signFileUrl(imageBaseUri);

  factory Anecdote.fromJson(Map<String, dynamic> json) {
    return Anecdote(
      id: json["id"],
      created: DateTime.tryParse(json["created"] ?? ""),
      updated: DateTime.tryParse(json["updated"] ?? ""),
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      userId: json["user"],
      date: DateTime.tryParse(json["date"] ?? ""),
      text: json["text"],
      imageFileName: json["image"],
      published: json["published"],
      newspaperId: json["edition"],
      imageBaseUri: json["imageUri"],
    );
  }

  factory Anecdote.fromRecord(RecordModel record) {
    Anecdote anecdote = Anecdote.fromJson(record.toJson());
    if (anecdote.imageFileName.isNotEmpty) {
      anecdote.imageBaseUri = PocketbaseService.to.getFileUrl(record, anecdote.imageFileName).toString();
    }
    return anecdote;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "user": userId,
        "date": date.toString(),
        "text": text,
        "image": imageFileName,
        "published": published.toString(),
        "edition": newspaperId,
        "imageUri": imageBaseUri
      };

  String getResizedImage(int width, int height, bool resize) {
    return PocketbaseService.to
        .signFileUrl(imageBaseUri, thumb: width.toString() + "x" + height.toString() + (resize ? "f" : ""));
  }
}
