import 'package:pocketbase/pocketbase.dart';
import 'package:gazette/services/PocketBaseService.dart';

class Newspaper {
  final String id;
  final DateTime? created;
  final DateTime? updated;
  final String collectionId;
  final String collectionName;
  final DateTime? date;
  final String pdfFileName;
  final int number;
  String? pdfUri;
  String? token;

  Newspaper({
    required this.id,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.number,
    required this.date,
    required this.pdfFileName,
    required this.pdfUri,
    this.token,
  });

  factory Newspaper.fromJson(Map<String, dynamic> json) {
    return Newspaper(
      id: json["id"],
      created: DateTime.tryParse(json["created"] ?? ""),
      updated: DateTime.tryParse(json["updated"] ?? ""),
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      number: json["number"],
      date: DateTime.tryParse(json["date"] ?? ""),
      pdfFileName: json["pdf"],
      pdfUri: json["pdfUri"],
    );
  }

  factory Newspaper.fromRecord(RecordModel record) {
    Newspaper newspaper = Newspaper.fromJson(record.toJson());
    if (newspaper.pdfFileName.isNotEmpty) {
      newspaper.pdfUri = PocketbaseService.to.getFileUrl(record, newspaper.pdfFileName).toString();
    }
    return newspaper;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "updated": updated?.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "number": number.toString(),
        "date": date.toString(),
        "pdf": pdfFileName,
        "pdfUri": pdfUri
      };
}
