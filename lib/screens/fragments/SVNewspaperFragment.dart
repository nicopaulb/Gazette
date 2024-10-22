import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperController.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';

class SVNewspaperFragment extends StatelessWidget {
  final NewspaperController _newspaperController =
      Get.put(NewspaperController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: svGetScaffoldColor(),
        appBar: AppBar(
          backgroundColor: svGetScaffoldColor(),
          title: Text('Gazette PDF', style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Obx(() => _newspaperController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _newspaperController.newspapers.isEmpty
                ? const Center(
                    child: Text("Erreur lors de la récuparation des gazettes"))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _newspaperController.newspapers.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                              title: Text(_newspaperController.getName(index)),
                              trailing: Icon(Icons.visibility),
                              onTap: () {
                                _newspaperController.currentIndex = index;
                                NewspaperViewerScreen().launch(context);
                              }));
                    })));
  }
}
