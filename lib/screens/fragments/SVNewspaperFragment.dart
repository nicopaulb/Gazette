import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperController.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';

class SVNewspaperFragment extends StatelessWidget {
  final NewspaperController _newspaperController = Get.put(NewspaperController());

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
                ? const Center(child: Text("Erreur lors de la récuparation des gazettes"))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _newspaperController.newspapers.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                              title: Text(_newspaperController.getName(index)),
                              // subtitle: SizedBox(
                              //   height: 40,
                              //   child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       padding: const EdgeInsets.all(8.0),
                              //       itemCount: 15,
                              //       itemBuilder: (context, index) {
                              //         return CachedNetworkImage(
                              //           imageUrl:
                              //               "***REMOVED***/api/files/_pb_users_auth_/nfv7go82lrwjuxj/lena_FjKTskZDW9.jpg?token=",
                              //           imageBuilder: (context, imageProvider) => Container(
                              //             width: 30,
                              //             height: 30,
                              //             decoration: BoxDecoration(
                              //               shape: BoxShape.circle,
                              //               image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              //             ),
                              //           ),
                              //           fit: BoxFit.cover,
                              //           errorWidget: (context, url, error) => Image.asset(
                              //             'images/gazette/icons/ic_Profile.png',
                              //             color: SVAppColorPrimary,
                              //           ),
                              //         );
                              //       }),
                              // ),
                              trailing: Icon(Icons.visibility),
                              onTap: () {
                                _newspaperController.startNewspaperViewer(index);
                                NewspaperViewerScreen().launch(context);
                              }));
                    })));
  }
}
