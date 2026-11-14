import 'package:flutter/widgets.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/models/PublishedAnecdoteStats.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/screens/auth/LogInScreen.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class AnecdoteController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxBool isLoading = false.obs;
  final loadError = RxnString();
  final moreError = RxnString();
  final isLoadingMore = false.obs;
  final publishedStats = Rxn<PublishedAnecdoteStats>();
  final isLoadingStats = false.obs;
  final statsError = RxnString();
  List<Anecdote> anecdotes = <Anecdote>[];
  int page = 1;
  final int NB_PER_PAGE = 15;
  bool canLoadMore = false;
  int _feedVersion = 0;

  @override
  void onInit() {
    super.onInit();
    PocketbaseService.to.isAuthValid().then((bool valid) {
      if (!valid) {
        Get.off(LogInScreen());
      }
    });
    scrollController.addListener(_scrollListener);
    loadPublishedStats();
    loadFirstAnecdotes();
    afterBuildCreated(() {
      setStatusBarColor(getScaffoldColor());
    });
  }

  Future<void> loadPublishedStats() async {
    if (isLoadingStats.value) return;
    isLoadingStats.value = true;
    statsError.value = null;
    try {
      publishedStats.value =
          await PocketbaseService.to.getPublishedAnecdoteStats();
    } catch (e) {
      statsError.value = 'Impossible de charger les statistiques.';
      Get.log('Stats loading error: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadFirstAnecdotes() async {
    if (isLoading.value) return;
    ++_feedVersion;
    isLoading.value = true;
    isLoadingMore.value = false;
    loadError.value = null;
    moreError.value = null;
    try {
      anecdotes =
          await PocketbaseService.to.getAnecdotesPerPage(1, NB_PER_PAGE);
      page = 2;
      canLoadMore = anecdotes.length == NB_PER_PAGE;
    } catch (e) {
      loadError.value =
          'Impossible de charger les anecdotes. Vérifiez votre connexion puis réessayez.';
      Get.log('GotError : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreAnecdotes() async {
    if (canLoadMore && !isLoading.value && !isLoadingMore.value) {
      final version = _feedVersion;
      isLoadingMore.value = true;
      moreError.value = null;
      try {
        List<Anecdote> additionalAnecdotes =
            await PocketbaseService.to.getAnecdotesPerPage(page, NB_PER_PAGE);
        if (version != _feedVersion) return;
        page++;
        if (additionalAnecdotes.isNotEmpty) {
          anecdotes.addAll(additionalAnecdotes);
          update();
        }

        canLoadMore = additionalAnecdotes.length == NB_PER_PAGE;
      } catch (e) {
        if (version != _feedVersion) return;
        moreError.value = 'Impossible de charger la suite des anecdotes.';
        Get.log('GotError : $e');
      } finally {
        if (version == _feedVersion) isLoadingMore.value = false;
      }
    }
  }

  Future<void> refreshFeed() async {
    await Future.wait([loadFirstAnecdotes(), loadPublishedStats()]);
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
    return new DateFormat.yMMMMd("fr_FR")
        .format(anecdotes[index].date!)
        .capitalizeFirstLetter();
  }

  String getImage(int index) {
    return anecdotes[index].getResizedImage(1000, 1000, true);
  }

  String getFullSizeImage(int index) {
    return anecdotes[index].imageUri ?? "";
  }

  String getText(int index) {
    return anecdotes[index].text;
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 1000 &&
        moreError.value == null) {
      loadMoreAnecdotes();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
