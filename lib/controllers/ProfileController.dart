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

  @override
  void onInit() async {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });
    super.onInit();
  }

  void updateUser(String userId) async {
    isLoading.value = true;
    selectedUser.value = await _pocketBaseService.getUserDetails(userId);
    try {
      anecdotes = await _pocketBaseService.getAllAnecdotesFromUser(selectedUser.value!);
    } catch (e) {
      Get.log('GotError : $e');
    }

    isLoading.value = false;
  }

  String getName() {
    return selectedUser.value?.firstname ?? "Name";
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
    final regex = new RegExp(r"\w+(\'\w+)?");
    for (Anecdote anecdote in anecdotes) {
      wordCount += regex.allMatches(anecdote.text).length;
    }
    return wordCount;
  }

  String getAnecdoteImage(int index) {
    return anecdotes[index].getResizedImage(500, 500, true);
  }
}
