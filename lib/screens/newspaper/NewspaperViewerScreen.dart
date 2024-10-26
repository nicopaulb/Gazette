import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NewspaperViewerScreen extends StatelessWidget {
  final NewspaperViewerController _newspaperViewerController =
      Get.put(NewspaperViewerController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewspaperViewerController>(
        builder: (_) => Scaffold(
              appBar: AppBar(
                backgroundColor: svGetScaffoldColor(),
                title: Text(_newspaperViewerController.getName(),
                    style: boldTextStyle(size: 20)),
                elevation: 0,
                centerTitle: true,
              ),
              body: SfPdfViewer.network(
                _newspaperViewerController.getPdfUri(),
              ),
            ));
  }
}
