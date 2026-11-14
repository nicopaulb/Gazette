import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nb_utils/nb_utils.dart' show sharedPreferences;

import 'package:gazette/models/UserModel.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late GetStorage _storage;

  Future<StorageService> init() async {
    await GetStorage.init();
    _storage = GetStorage();
    return this;
  }

  final _userKey = "_userKey";

  User? get user {
    if (!_storage.hasData(_userKey)) return null;
    return User.fromJson(_storage.read(_userKey));
  }

  set user(User? data) => _storage.write(_userKey, data?.toJson());

  Map<String, dynamic>? readDraft(String userId, String anecdoteId) {
    final encoded = sharedPreferences.getString('draft:$userId:$anecdoteId');
    if (encoded == null) return null;
    final data = jsonDecode(encoded);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // Await the actual storage result before reporting a draft as saved.
  // GetStorage.write completes before its queued disk flush finishes.
  Future<void> writeDraft(
      String userId, String anecdoteId, Map<String, dynamic> data) async {
    final saved = await sharedPreferences.setString(
        'draft:$userId:$anecdoteId', jsonEncode(data));
    if (!saved) throw StateError('Draft could not be saved');
  }

  Future<void> removeDraft(String userId, String anecdoteId) async {
    final removed = await sharedPreferences.remove('draft:$userId:$anecdoteId');
    if (!removed) throw StateError('Draft could not be removed');
  }

  void clear() => _storage.erase();
}
