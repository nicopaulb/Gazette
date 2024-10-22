import 'package:flutter/widgets.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class AnecdoteController extends GetxController {
  RxBool isLoading = false.obs;
  List<Anecdote> anecdotes = <Anecdote>[];

  @override
  void onInit() {
    loadAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(svGetScaffoldColor());
    });
    super.onInit();
  }

  Future<void> loadAnecdotes() async {
    isLoading.value = true;
    try {
      anecdotes = await PocketbaseService.to.getAllAnecdotes();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  String getUserName(int index) {
    return anecdotes[index].user?.firstname ?? "";
  }

  String getUserAvatar(int index) {
    return anecdotes[index].user?.getResizedAvatar(100, 100) ?? "";
  }

  String getDate(int index) {
    return new DateFormat.yMMMMd("fr_FR")
        .format(anecdotes[index].date!)
        .capitalizeFirstLetter();
  }

  String getImage(int index) {
    return anecdotes[index].imageUri ?? "";
  }

  String getText(int index) {
    return anecdotes[index].text;
  }
}
