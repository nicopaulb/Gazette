import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/controllers/ProfileController.dart';
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
  final NewspaperViewerController _newspaperViewerController =
      Get.put(NewspaperViewerController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: radius(SVAppCommonRadius),
                    color: SVAppColorPrimary.withOpacity(0.8)),
                child: Row(
                  children: [
                    20.width,
                    Icon(
                      Icons.info_rounded,
                      color: Colors.white,
                    ),
                    20.width,
                    Flexible(
                      child: Text(
                          "Bienvenue sur la première version de la Gazette numérique !\nN'hesitez pas à addresser vos retours à l'équipe de la Gazette.",
                          style:
                              primaryTextStyle(color: Colors.white, size: 14)),
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
                    ? const Center(
                        child: Text(
                            "Erreur lors de la récuparation des anecdotes"))
                    : ListView.builder(
                        itemCount: _anecdoteController.anecdotes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: radius(SVAppCommonRadius),
                                color: context.cardColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _profileController.updateUser(
                                            _anecdoteController
                                                .getUserId(index));
                                        ProfileScreen().launch(context);
                                      },
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: _anecdoteController
                                                .getUserAvatar(index),
                                            height: 56,
                                            width: 56,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(
                                              SVAppCommonRadius),
                                          12.width,
                                          Text(
                                              _anecdoteController
                                                  .getUserName(index),
                                              style: boldTextStyle()),
                                        ],
                                      ).paddingSymmetric(horizontal: 16),
                                    ),
                                    Row(
                                      children: [
                                        Text(_anecdoteController.getDate(index),
                                            style: secondaryTextStyle(
                                                color: svGetBodyColor(),
                                                size: 12)),
                                        PopupMenuButton(
                                          onSelected: (item) {
                                            _newspaperViewerController
                                                    .newspaper =
                                                _anecdoteController
                                                    .getNewspaper(index);
                                            NewspaperViewerScreen()
                                                .launch(context);
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return const [
                                              PopupMenuItem(
                                                child: Text(
                                                    "Ouvrir la version PDF"),
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
                                svRobotoText(
                                        text:
                                            _anecdoteController.getText(index),
                                        textAlign: TextAlign.start)
                                    .paddingSymmetric(horizontal: 16),
                                16.height,
                                CachedNetworkImage(
                                  imageUrl: _anecdoteController.getImage(index),
                                  height: 400,
                                  width:
                                      ContextExtensions(context).width() - 32,
                                  fit: BoxFit.cover,
                                )
                                    .cornerRadiusWithClipRRect(
                                        SVAppCommonRadius)
                                    .center(),
                              ],
                            ),
                          );
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      )),
          ],
        ),
      ),
    );
  }
}
