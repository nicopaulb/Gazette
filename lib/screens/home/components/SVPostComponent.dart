import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';

class SVPostComponent extends StatelessWidget {
  final AnecdoteController _anecdoteController = Get.put(AnecdoteController());
  final ProfileController _profileController = Get.put(ProfileController());
  final NewspaperViewerController _newspaperViewerController = Get.put(NewspaperViewerController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _anecdoteController.scrollController,
      child: Column(
        children: [
          16.height,
          Center(
            child: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(borderRadius: radius(SVAppCommonRadius), color: SVAppColorPrimary.withOpacity(0.8)),
                      child: Row(
                        children: [
                          20.width,
                          Icon(
                            Icons.info_rounded,
                            color: Colors.white,
                          ),
                          20.width,
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                  "Bienvenue sur la première version de la Gazette numérique !\nN'hesitez pas à adresser vos retours et suggestions à l'équipe de la Gazette.",
                                  style: primaryTextStyle(color: Colors.white, size: 14)),
                            ),
                          )
                        ],
                      )),
                  Obx(() => _anecdoteController.isLoading.value
                      ? Column(
                          children: [
                            50.height,
                            const Center(child: CircularProgressIndicator()),
                          ],
                        )
                      : _anecdoteController.anecdotes.isEmpty
                          ? const Center(child: Text("Erreur lors de la récuparation des anecdotes"))
                          : GetBuilder<AnecdoteController>(
                              builder: (_) => ListView.builder(
                                itemCount: _anecdoteController.anecdotes.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: radius(SVAppCommonRadius), color: context.cardColor),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _profileController.updateUser(_anecdoteController.getUserId(index));
                                                ProfileScreen().launch(context);
                                              },
                                              child: Row(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: _anecdoteController.getUserAvatar(index),
                                                    height: 56,
                                                    width: 56,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      'images/gazette/icons/ic_Profile.png',
                                                      color: SVAppColorPrimary,
                                                    ),
                                                  ).cornerRadiusWithClipRRect(SVAppCommonRadius),
                                                  12.width,
                                                  Text(_anecdoteController.getUserName(index), style: boldTextStyle()),
                                                ],
                                              ).paddingSymmetric(horizontal: 16),
                                            ),
                                            Row(
                                              children: [
                                                Text(_anecdoteController.getDate(index),
                                                    style: secondaryTextStyle(color: svGetBodyColor(), size: 12)),
                                                PopupMenuButton(
                                                  onSelected: (item) {
                                                    Newspaper? news = _anecdoteController.getNewspaper(index);
                                                    if (news != null) {
                                                      _newspaperViewerController.newspaper = news;
                                                      NewspaperViewerScreen().launch(context);
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    return [
                                                      PopupMenuItem(
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.picture_as_pdf),
                                                            10.width,
                                                            Text("Ouvrir la gazette"),
                                                          ],
                                                        ),
                                                        value: 'newspaper',
                                                      )
                                                    ];
                                                  },
                                                ),
                                              ],
                                            ).paddingSymmetric(horizontal: 16),
                                          ],
                                        ),
                                        16.height,
                                        svRobotoText(text: _anecdoteController.getText(index), textAlign: TextAlign.start)
                                            .paddingSymmetric(horizontal: 16),
                                        16.height,
                                        GestureDetector(
                                            onTap: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (_) => Dialog(
                                                    backgroundColor: Colors.transparent,
                                                    child: FractionallySizedBox(
                                                      widthFactor: 0.95,
                                                      heightFactor: 0.95,
                                                      child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: CachedNetworkImage(
                                                            imageUrl: _anecdoteController.getFullSizeImage(index),
                                                            fit: BoxFit.contain,
                                                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                              child: SizedBox(
                                                                height: 100,
                                                                width: 100,
                                                                child: CircularProgressIndicator(
                                                                    value: downloadProgress.progress, color: SVAppColorPrimary),
                                                              ),
                                                            ),
                                                            errorWidget: (context, url, error) =>
                                                                Icon(Icons.error, color: SVAppColorPrimary, size: 50),
                                                          )),
                                                    )),
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: _anecdoteController.getImage(index),
                                              height: 400,
                                              width: ContextExtensions(context).width() - 32,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                child: SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child: CircularProgressIndicator(value: downloadProgress.progress, color: SVAppColorPrimary),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error, color: SVAppColorPrimary, size: 30),
                                            ).cornerRadiusWithClipRRect(SVAppCommonRadius).center()),
                                      ],
                                    ),
                                  );
                                },
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            )),
                ],
              ),
            ),
          ),
          16.height,
        ],
      ),
    );
  }
}
