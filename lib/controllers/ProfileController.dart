import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/UserModel.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:nb_utils/nb_utils.dart';

class ProfileController extends GetxController {
  final _pocketBaseService = PocketbaseService.to;
  Rxn<User> selectedUser = Rxn<User>();
  List<Anecdote> anecdotes = [];
  RxBool isLoading = false.obs;
  final profileError = RxnString();
  final anecdotesError = RxnString();
  String? _requestedUserId;
  int _requestVersion = 0;

  @override
  void onInit() async {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });
    super.onInit();
  }

  Future<void> updateUser(String userId, {bool useCache = true}) async {
    final version = ++_requestVersion;
    _requestedUserId = userId;
    isLoading.value = true;
    profileError.value = null;
    anecdotesError.value = null;
    selectedUser.value = null;
    anecdotes = [];
    try {
      final user =
          await _pocketBaseService.getUserDetails(userId, useCache: useCache);
      if (version != _requestVersion) return;
      selectedUser.value = user;
      try {
        final results = await _pocketBaseService.getAllAnecdotesFromUser(user);
        if (version != _requestVersion) return;
        anecdotes = results
          ..sort((a, b) =>
              (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)));
      } catch (e) {
        if (version != _requestVersion) return;
        anecdotesError.value =
            'Impossible de charger les anecdotes de ce profil.';
        Get.log('Profile anecdotes error: $e');
      }
    } catch (e) {
      if (version != _requestVersion) return;
      profileError.value =
          'Impossible de charger ce profil. Vérifiez votre connexion puis réessayez.';
      Get.log('GotError : $e');
    } finally {
      if (version == _requestVersion) isLoading.value = false;
    }
  }

  Future<void> reload() async {
    if (isLoading.value) return;
    final userId = _requestedUserId;
    if (userId != null) await updateUser(userId, useCache: false);
  }

  String getName() {
    final user = selectedUser.value;
    if (user == null) return '';
    final name = [user.firstname.trim(), user.lastname.trim()]
        .where((part) => part.isNotEmpty)
        .join(' ');
    return name.isEmpty ? user.username : name;
  }

  String getUsername() {
    return "@${selectedUser.value?.username ?? "username"}";
  }

  String getAvatar() {
    return selectedUser.value?.getResizedAvatar() ?? "";
  }

  int getAnecdotesCount() {
    return anecdotes.length;
  }

  int getAnecdotesWordsCount() {
    int wordCount = 0;
    final regex =
        RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);
    for (Anecdote anecdote in anecdotes) {
      wordCount += regex.allMatches(anecdote.text).length;
    }
    return wordCount;
  }

  String getAnecdoteImage(int index) {
    return anecdotes[index].getResizedImage(500, 500, true);
  }
}
