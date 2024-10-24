import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NewspaperViewerScreen extends StatefulWidget {
  const NewspaperViewerScreen({super.key});

  @override
  State<NewspaperViewerScreen> createState() => _NewspaperViewerState();
}

class _NewspaperViewerState extends State<NewspaperViewerScreen> {
  final NewspaperController _newspaperController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: svGetScaffoldColor(),
        title: Text(_newspaperController.getCurrentName(),
            style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SfPdfViewer.network(
        _newspaperController.getCurrentPdfUri(),
      ),
    );
  }
}
