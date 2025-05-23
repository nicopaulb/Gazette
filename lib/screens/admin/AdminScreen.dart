import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AdminController.dart';
import 'package:gazette/screens/admin/AdminAnecdoteScreen.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class AdminScreen extends StatelessWidget {
  final AdminController _adminController = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        title: Text('Administration', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
        actions: <Widget>[
          PopupMenuButton<void Function()>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  enabled: true,
                  onTap: () => _adminController.publish(),
                  child: ListTile(
                    leading: Icon(Icons.publish, color: Theme.of(context).primaryColor),
                    title: Text('Publier'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _adminController.generatePdf(),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf, color: Theme.of(context).primaryColor),
                    title: Text('Générer'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _adminController.downloadAllImages(),
                  child: ListTile(
                    leading: Icon(Icons.image, color: Theme.of(context).primaryColor),
                    title: Text('Télécharger'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
          color: context.scaffoldBackgroundColor,
          child: Obx(
            () => _adminController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _adminController.anecdotes.isEmpty
                    ? const Center(child: Text("Aucune anecdotes en attente."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _adminController.anecdotes.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                                  title: Text("Anecdote ${index + 1}"),
                                  leading: CachedNetworkImage(
                                      imageUrl: _adminController.getImage(index), width: 100, height: 100),
                                  onTap: () {
                                    _adminController.selectedIndex = index;
                                    Get.to(AdminAnecdoteScreen());
                                  }));
                        }),
          )),
    );
  }
}
