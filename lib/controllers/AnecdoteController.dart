import 'package:flutter/widgets.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class AnecdoteController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxBool isLoading = false.obs;
  List<Anecdote> anecdotes = <Anecdote>[];
  int page = 1;
  final int NB_PER_PAGE = 15;
  bool canLoadMore = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadFirstAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(svGetScaffoldColor());
    });
  }

  Future<void> loadFirstAnecdotes() async {
    isLoading.value = true;
    try {
      anecdotes = await PocketbaseService.to.getAnecdotesPerPage(page++, NB_PER_PAGE);
      canLoadMore = true;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  Future<void> loadMoreAnecdotes() async {
    if (canLoadMore) {
      canLoadMore = false;
      try {
        List<Anecdote> additionalAnecdotes = await PocketbaseService.to.getAnecdotesPerPage(page++, NB_PER_PAGE);
        if (additionalAnecdotes.isNotEmpty) {
          anecdotes.addAll(additionalAnecdotes);
          update();
        }

        if (additionalAnecdotes.length == NB_PER_PAGE) {
          canLoadMore = true;
        }
      } catch (e) {
        Get.log('GotError : $e');
      }
    }
  }

  String getUserId(int index) {
    return anecdotes[index].user?.id ?? "";
  }

  String getUserName(int index) {
    return anecdotes[index].user?.firstname ?? "";
  }

  String getUserAvatar(int index) {
    return anecdotes[index].user?.getResizedAvatar() ?? "";
  }

  Newspaper? getNewspaper(int index) {
    return anecdotes[index].newspaper;
  }

  String getDate(int index) {
    return new DateFormat.yMMMMd("fr_FR").format(anecdotes[index].date!).capitalizeFirstLetter();
  }

  String getImage(int index) {
    return anecdotes[index].getResizedImage(1000, 1000);
  }

  String getFullSizeImage(int index) {
    return anecdotes[index].imageUri ?? "";
  }

  String getText(int index) {
    return anecdotes[index].text;
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 1000) {
      loadMoreAnecdotes();
    }
  }
}
