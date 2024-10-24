import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:nb_utils/nb_utils.dart';

class ProfileController extends GetxController {
  final _pocketBaseService = PocketbaseService.to;
  List<Anecdote> anecdotes = [];
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    loadAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });

    super.onInit();
  }

  void loadAnecdotes() async {
    isLoading.value = true;
    try {
      anecdotes = await _pocketBaseService
          .getAllAnecdotesFromUser(_pocketBaseService.user!);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  String getName() {
    return _pocketBaseService.user!.firstname;
  }

  String getUsername() {
    return "@${_pocketBaseService.user!.username}";
  }

  String getAvatar() {
    return _pocketBaseService.user!.getResizedAvatar(100, 100);
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
    return anecdotes[index].getResizedImage(500, 500);
  }
}
