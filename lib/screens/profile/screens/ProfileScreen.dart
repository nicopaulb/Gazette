import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/Common.dart';
import 'package:gazette/utils/Constants.dart';
import 'package:gazette/utils/Colors.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: getScaffoldColor(),
        appBar: AppBar(
          backgroundColor: getScaffoldColor(),
          title: Text('Profil', style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
        ),
        body: Obx(
          () => _profileController.isLoading.value || _profileController.selectedUser.value == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 180,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Image.asset(
                                  'images/gazette/banner.png',
                                  width: ContextExtensions(context).width(),
                                  height: 130,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRectOnly(topLeft: AppCommonRadius.toInt(), topRight: AppCommonRadius.toInt()),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: radius(18)),
                                    child: CachedNetworkImage(
                                      imageUrl: _profileController.getAvatar(),
                                      height: 88,
                                      width: 88,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Image.asset(
                                        'images/gazette/icons/ic_Profile.png',
                                        color: AppColorPrimary,
                                      ),
                                    ).cornerRadiusWithClipRRect(AppCommonRadius),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text(_profileController.getName(), style: boldTextStyle(size: 20))],
                      ),
                      Text(_profileController.getUsername(), style: secondaryTextStyle(color: getBodyColor())),
                      24.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Anecdotes', style: secondaryTextStyle(color: getBodyColor(), size: 12)),
                              4.height,
                              Text("${_profileController.getAnecdotesCount()}", style: boldTextStyle(size: 18)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Mots', style: secondaryTextStyle(color: getBodyColor(), size: 12)),
                              4.height,
                              Text("${_profileController.getAnecdotesWordsCount()}", style: boldTextStyle(size: 18)),
                            ],
                          )
                        ],
                      ),
                      16.height,
                      Container(
                        constraints: BoxConstraints(maxWidth: 1000),
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(AppContainerRadius)),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Anecdotes',
                                  style: TextStyle(
                                    color: AppColorPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  height: 2,
                                  width: ContextExtensions(context).width() / 2 - 32,
                                  color: AppColorPrimary,
                                ),
                              ],
                            ),
                            32.height,
                            GridView.builder(
                              itemCount: _profileController.getAnecdotesCount(),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return CachedNetworkImage(imageUrl: _profileController.getAnecdoteImage(index), height: 100, fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(8);
                              },
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      16.height,
                    ],
                  ),
                ),
        ));
  }
}
