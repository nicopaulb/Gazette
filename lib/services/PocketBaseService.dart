import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:gazette/models/UserModel.dart';
import 'package:gazette/services/StorageService.dart';

class PocketbaseService extends GetxService {
  static PocketbaseService get to => Get.find();
  final _pocketBaseUrl = "***REMOVED***";

  late PocketBase _client;
  late AuthStore _authStore;
  final Map<String, User> _cachedUsersData = {};
  User? user;
  bool get isAuth => user != null;

  Future<PocketbaseService> init() async {
    _initializeAuthStore();
    _client = PocketBase(_pocketBaseUrl, authStore: _authStore);
    // Listen to authStore changes
    _client.authStore.onChange.listen((AuthStoreEvent event) {
      if (event.model is RecordModel) {
        user = User.fromRecord(event.model);
        user?.token = event.token;
        StorageService.to.user = user;
      }
    });
    return this;
  }

  void _initializeAuthStore() {
    _authStore = AuthStore();
    user = StorageService.to.user;
    String? token = user?.token;
    if (user == null || token == null) return;
    RecordModel model = RecordModel.fromJson(user!.toJson());
    _authStore.save(token, model);
  }

  /// Auth
  Future login(String username, password) async {
    try {
      RecordAuth userData = await _client
          .collection('users')
          .authWithPassword(username, password);
      return userData;
    } on ClientException catch (e) {
      throw e.originalError;
    }
  }

  Future logout() async {
    _client.authStore.clear();
    StorageService.to.user = null;
  }

  Future<List<User>> getAllUserDetails({bool useCache = false}) async {
    try {
      if (useCache && _cachedUsersData.isNotEmpty) {
        return Future<List<User>>.value(
            _cachedUsersData.values.toList().cast<User>());
      }
      final results = await _client.collection('users').getFullList();
      return results.map((final result) {
        var user = User.fromRecord(result);
        _cachedUsersData[user.id] = user;
        return user;
      }).toList();
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<User> getUserDetails(
    String userId, {
    bool useCache = false,
  }) async {
    try {
      if (useCache && _cachedUsersData.containsKey(userId)) {
        return Future<User>.value(_cachedUsersData[userId]);
      }
      final result = await _client.collection('users').getOne(userId);
      var user = User.fromRecord(result);
      _cachedUsersData[userId] = user;
      return user;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Uri getFileUrl(RecordModel recordModel, String fileName) =>
      _client.files.getUrl(recordModel, fileName);
}
