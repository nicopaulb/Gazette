import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:gazette/models/UserModel.dart';
import 'package:gazette/services/StorageService.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PocketbaseService extends GetxService {
  static PocketbaseService get to => Get.find();
  final _pocketBaseUrl = "***REMOVED***";

  late PocketBase _client;
  late AuthStore _authStore;
  final Map<String, User> _cachedUsersData = {};
  final Map<String, Newspaper> _cachedNewspapersData = {};
  final Map<String, Anecdote> _cachedAnecdotesData = {};
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

  Future<bool> isAuthValid() async {
    if (_authStore.isValid) {
      try {
        await _client.collection('users').authRefresh();
      } catch (e) {
        _authStore.clear();
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  void clearCachedData() {
    _cachedUsersData.clear();
    _cachedNewspapersData.clear();
    _cachedAnecdotesData.clear();
  }

  Future login(String username, password) async {
    try {
      RecordAuth userData = await _client.collection('users').authWithPassword(username, password);
      return userData;
    } on ClientException catch (e) {
      throw e;
    }
  }

  Future logout() async {
    _client.authStore.clear();
    StorageService.to.user = null;
  }

  Future<List<User>> getAllUserDetails({bool useCache = true}) async {
    try {
      if (useCache && _cachedUsersData.isNotEmpty) {
        return Future<List<User>>.value(_cachedUsersData.values.toList().cast<User>());
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
    bool useCache = true,
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

  Future<List<Newspaper>> getAllNewspapers({bool useCache = false}) async {
    try {
      if (useCache && _cachedNewspapersData.isNotEmpty) {
        return Future<List<Newspaper>>.value(_cachedNewspapersData.values.toList().cast<Newspaper>());
      }
      final results = await _client.collection('edition').getFullList(sort: "-date", expand: "editionStats_via_edition");
      return results.map((final result) {
        var newspaper = Newspaper.fromRecord(result);
        _cachedNewspapersData[newspaper.id] = newspaper;
        return newspaper;
      }).toList();
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<Newspaper> getNewspaper(
    String newspaperId, {
    bool useCache = true,
  }) async {
    try {
      if (useCache && _cachedNewspapersData.containsKey(newspaperId)) {
        return Future<Newspaper>.value(_cachedNewspapersData[newspaperId]);
      }
      final result = await _client.collection('edition').getOne(newspaperId);
      var newspaper = Newspaper.fromRecord(result);

      _cachedNewspapersData[newspaperId] = newspaper;
      return newspaper;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<List<Anecdote>> getAllAnecdotes({bool useCache = true}) async {
    List<Anecdote> anecdotesList = [];
    try {
      if (useCache && _cachedAnecdotesData.isNotEmpty) {
        return Future<List<Anecdote>>.value(_cachedAnecdotesData.values.toList().cast<Anecdote>());
      }
      final results = await _client.collection('anecdotes').getFullList(sort: "-date", filter: "published = true");
      for (RecordModel anecdoteRecord in results) {
        var anecdote = Anecdote.fromRecord(anecdoteRecord);
        anecdote.user = await getUserDetails(anecdote.userId);
        if (anecdote.newspaperId != null) {
          anecdote.newspaper = await getNewspaper(anecdote.newspaperId!);
        }
        _cachedAnecdotesData[anecdote.id] = anecdote;
        anecdotesList.add(anecdote);
      }
      return anecdotesList;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<List<Anecdote>> getAnecdotesPerPage(int page, int perPage) async {
    List<Anecdote> anecdotesList = [];
    try {
      final results = await _client.collection('anecdotes').getList(perPage: perPage, page: page, sort: "-date", filter: "published = true");

      for (RecordModel anecdoteRecord in results.items) {
        var anecdote = Anecdote.fromRecord(anecdoteRecord);
        anecdote.user = await getUserDetails(anecdote.userId);
        if (anecdote.newspaperId.isNotEmpty) {
          anecdote.newspaper = await getNewspaper(anecdote.newspaperId!);
        }
        _cachedAnecdotesData[anecdote.id] = anecdote;
        anecdotesList.add(anecdote);
      }

      return anecdotesList;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<List<Anecdote>> getAllAnecdotesFromUser(User user) async {
    List<Anecdote> anecdotesList = [];
    try {
      final results = await _client.collection('anecdotes').getFullList(filter: 'published = true && user = "${user.id}"');

      for (RecordModel anecdoteRecord in results) {
        var anecdote = Anecdote.fromRecord(anecdoteRecord);
        anecdote.user = user;
        if (anecdote.newspaper != null) {
          anecdote.newspaper = await getNewspaper(anecdote.newspaperId!);
        }
        anecdotesList.add(anecdote);
      }

      return anecdotesList;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<List<Anecdote>> getAllSubmittedAnecdotesFromCurrentUser() async {
    DateTime now = DateTime.now();
    DateTime limit = DateTime(now.year, now.day < 3 ? now.month - 1 : now.month, 2);

    try {
      final results = await _client
          .collection('anecdotes')
          .getFullList(filter: 'published = false && date > "${limit.toIso8601String()}" && user = "${this.user!.id}"');
      return Future.wait(results.map((final result) async {
        var anecdote = Anecdote.fromRecord(result);
        anecdote.user = user;
        return anecdote;
      }).toList());
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<List<Anecdote>> getAllSubmittedAnecdotes() async {
    List<Anecdote> anecdotesList = [];

    try {
      final results = await _client.collection('anecdotes').getFullList(filter: 'published = false', sort: "+date");

      for (RecordModel anecdoteRecord in results) {
        var anecdote = Anecdote.fromRecord(anecdoteRecord);
        anecdote.user = await getUserDetails(anecdote.userId);
        _cachedAnecdotesData[anecdote.id] = anecdote;
        anecdotesList.add(anecdote);
      }
      return anecdotesList;
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<void> publishAnecdote(Anecdote anecdote) async {
    try {
      anecdote.published = true;
      final result = await _client.collection('anecdotes').update(anecdote.id, body: anecdote.toJson());
      anecdote = Anecdote.fromRecord(result);
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Future<Anecdote> createAnecdote(String text, XFile image, DateTime date) async {
    final result = await _client.collection("anecdotes").create(body: {
      "user": this.user!.id,
      "text": text,
      "date": date.toString(),
      "published": "false"
    }, files: [
      http.MultipartFile.fromBytes(
        "image",
        await image.readAsBytes(),
        filename: "${new DateFormat.yMd("fr_FR").format(date).replaceAll("/", "-")}_${this.user!.firstname}",
      )
    ]);
    var anecdote = Anecdote.fromRecord(result);
    _cachedAnecdotesData[anecdote.id] = anecdote;
    return anecdote;
  }

  Future<Anecdote> updateAnecdote(Anecdote currentAnecdote, String text, XFile? image, DateTime date) async {
    List<http.MultipartFile> file = [];
    if (image != null) {
      file.add(http.MultipartFile.fromBytes(
        "image",
        await image.readAsBytes(),
        filename: "${new DateFormat.yMd("fr_FR").format(date).replaceAll("/", "-")}_${this.user!.firstname}",
      ));
    }
    final result = await _client.collection("anecdotes").update(currentAnecdote.id,
        body: {
          "user": this.user!.id,
          "text": text,
          "date": date.toString(),
        },
        files: file);
    var anecdote = Anecdote.fromRecord(result);
    _cachedAnecdotesData[anecdote.id] = anecdote;
    return anecdote;
  }

  Future<void> deleteAnecdote(Anecdote anecdote) async {
    try {
      await _client.collection('anecdotes').delete(anecdote.id);
    } on ClientException catch (e) {
      Get.log(e.toString());
      throw e.originalError;
    }
  }

  Uri getFileUrl(RecordModel recordModel, String fileName) => _client.files.getUrl(recordModel, fileName);
}
