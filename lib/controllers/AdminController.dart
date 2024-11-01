import 'package:gazette/utils/SVColors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

class AdminController extends GetxController {
  RxBool isLoading = false.obs;
  List<Anecdote> anecdotes = [];
  int _selectedIndex = 0;
  final _clipboard = SystemClipboard.instance;

  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });
    loadAnecdotes();
    super.onInit();
  }

  Future<void> loadAnecdotes() async {
    isLoading.value = true;
    try {
      anecdotes = await PocketbaseService.to.getAllSubmittedAnecdotes();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  Future<void> publish() async {
    Get.defaultDialog(
        middleText:
            "Est-tu sûr de vouloir publier toutes les anecdotes en attente ?",
        title: "Confirmation",
        textConfirm: "Publier",
        textCancel: "Annuler",
        buttonColor: SVAppColorPrimary,
        cancelTextColor: SVAppColorPrimary,
        radius: 5,
        onCancel: () {},
        onConfirm: () {
          isLoading.value = true;
          Future.wait(anecdotes.map((final anecdote) async {
            PocketbaseService.to.publishAnecdote(anecdote);
          }));
          anecdotes = [];
          isLoading.value = false;
        });
  }

  void showNextAnecdote() {
    if (_selectedIndex + 1 < anecdotes.length) {
      _selectedIndex++;
      update();
    }
  }

  void showPrevAnecdote() {
    if (_selectedIndex > 0) {
      _selectedIndex--;
      update();
    }
  }

  void copyName() async {
    if (_clipboard != null) {
      final item = DataWriterItem();
      item.add(Formats.plainText(getSelectedName()));
      await _clipboard!.write([item]);
    }
  }

  void copyDate() async {
    if (_clipboard != null) {
      final item = DataWriterItem();
      item.add(Formats.plainText(getSelectedDate()));
      await _clipboard!.write([item]);
    }
  }

  void copyText() async {
    if (_clipboard != null) {
      final item = DataWriterItem();
      item.add(Formats.plainText(getSelectedText()));
      await _clipboard!.write([item]);
    }
  }

  void copyImage() async {
    if (_clipboard != null) {
      http.Response response = await http.get(
        Uri.parse(anecdotes[_selectedIndex].imageUri ?? ""),
      );
      final item =
          DataWriterItem(suggestedName: '${anecdotes[_selectedIndex].id}.png');
      item.add(Formats.png(response.bodyBytes));
      await _clipboard!.write([item]);
    }
  }

  Future<void> downloadImage() async {
    await WebImageDownloader.downloadImageFromWeb(
        anecdotes[_selectedIndex].imageUri ?? "",
        name: new DateFormat.yMd("fr_FR")
                .format(anecdotes[_selectedIndex].date!)
                .replaceAll("/", "-") +
            " " +
            anecdotes[_selectedIndex].user!.firstname);
  }

  String getId(int index) {
    return anecdotes[index].id;
  }

  String getImage(int index) {
    return anecdotes[index].getResizedImage(100, 100);
  }

  String getSelectedId() {
    return getId(_selectedIndex);
  }

  String getSelectedText() {
    return anecdotes[_selectedIndex].text;
  }

  String getSelectedName() {
    return (anecdotes[_selectedIndex].user?.firstname ?? "") +
        " " +
        (anecdotes[_selectedIndex].user?.lastname ?? "");
  }

  String getSelectedDate() {
    return new DateFormat.MMMMd("fr_FR")
        .format(anecdotes[_selectedIndex].date!)
        .capitalizeFirstLetter();
  }

  String getSelectedImage() {
    return getImage(_selectedIndex);
  }

  String getSelectedUserAvatar() {
    return anecdotes[_selectedIndex].user?.getResizedAvatar() ?? "";
  }

  bool isFirstAnecdote() {
    return _selectedIndex == 0;
  }

  bool isLastAnecdote() {
    return _selectedIndex == anecdotes.length - 1;
  }

  set selectedIndex(int value) {
    _selectedIndex = value;
    update();
  }

  int get selectedIndex => _selectedIndex;
}
