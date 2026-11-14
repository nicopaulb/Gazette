import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:html' as html;

class NewspaperController extends GetxController {
  final NewspaperViewerController _newspaperViewerController =
      Get.put(NewspaperViewerController());
  RxBool isLoading = false.obs;
  final loadError = RxnString();
  final downloadError = RxnString();
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
    if (isLoading.value) return;
    isLoading.value = true;
    loadError.value = null;
    downloadError.value = null;
    try {
      newspapers = await PocketbaseService.to.getAllNewspapers();
      newspapers.sort((a, b) {
        final dateOrder =
            (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970));
        return dateOrder == 0 ? b.number.compareTo(a.number) : dateOrder;
      });
      isLoading.value = false;
    } catch (e) {
      loadError.value =
          'Impossible de charger les gazettes. Vérifiez votre connexion puis réessayez.';
      isLoading.value = false;
      Get.log('GotError : $e');
    }
  }

  String getNumber(int index) {
    return newspapers[index].number.toString();
  }

  String getName(int index) {
    return new DateFormat.yMMMM("fr_FR")
        .format(newspapers[index].date!)
        .capitalizeFirstLetter();
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

  void download(int index) {
    downloadError.value = null;
    try {
      final uri = newspapers[index].pdfUri;
      if (uri == null || uri.isEmpty) {
        downloadError.value = 'Le PDF de cette gazette est indisponible.';
        return;
      }
      final anchor = html.AnchorElement(href: uri);
      anchor.setAttribute('download', newspapers[index].pdfFileName);
      anchor.click();
    } catch (e) {
      downloadError.value =
          'Impossible de démarrer le téléchargement. Réessayez avec le bouton Télécharger.';
      Get.log('Download error: $e');
    }
  }
}
