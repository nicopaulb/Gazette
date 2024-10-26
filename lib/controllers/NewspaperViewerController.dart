import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class NewspaperViewerController extends GetxController {
  Newspaper? _newspaper;

  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(svGetScaffoldColor());
    });
    super.onInit();
  }

  String getName() {
    return new DateFormat.yMMMM("fr_FR")
        .format(newspaper.date!)
        .capitalizeFirstLetter();
  }

  String getPdfUri() {
    return newspaper.pdfUri ?? "";
  }

  set newspaper(Newspaper value) {
    _newspaper = value;
    update();
  }

  Newspaper get newspaper => _newspaper!;
}
