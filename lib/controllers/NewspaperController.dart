import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:html' as html;

class NewspaperController extends GetxController {
  final NewspaperViewerController _newspaperViewerController = Get.put(NewspaperViewerController());
  RxBool isLoading = false.obs;
  List<Newspaper> newspapers = <Newspaper>[];
  int _currentIndex = -1;

  @override
  void onInit() {
    loadNewspapers();
    afterBuildCreated(() {
      setStatusBarColor(getScaffoldColor());
    });
    super.onInit();
  }

  set currentIndex(int value) {
    assert(value >= 0);
    _currentIndex = value;
  }

  Future<void> loadNewspapers() async {
    isLoading.value = true;
    try {
      newspapers = await PocketbaseService.to.getAllNewspapers();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  String getNumber(int index) {
    return newspapers[index].number.toString();
  }

  String getName(int index) {
    return new DateFormat.yMMMM("fr_FR").format(newspapers[index].date!).capitalizeFirstLetter();
  }

  int getAnecdotesCount(int index) {
    return newspapers[index].anecdoteCount ?? 0;
  }

  int getUsersCount(int index) {
    return newspapers[index].userCount ?? 0;
  }

  String getCurrentName() {
    return getName(_currentIndex);
  }

  String getCurrentPdfUri() {
    return newspapers[_currentIndex].pdfUri ?? "";
  }

  void startNewspaperViewer(int index) {
    _newspaperViewerController.newspaper = newspapers[index];
  }

  void download(int index) async {
    if (newspapers[index].pdfUri != null) {
      final anchor = html.AnchorElement(href: newspapers[index].pdfUri!);
      anchor.setAttribute('download', newspapers[index].pdfUri!);
      anchor.click();
    }
  }
}
