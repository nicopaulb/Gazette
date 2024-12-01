import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AdminController.dart';
import 'package:gazette/controllers/SettingController.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class AdminAnecdoteScreen extends StatelessWidget {
  final AdminController _adminController = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminController>(
        builder: (_) => Scaffold(
              backgroundColor: svGetScaffoldColor(),
              appBar: AppBar(
                backgroundColor: svGetScaffoldColor(),
                title: Text("Anecdote ${_adminController.selectedIndex + 1}/${_adminController.anecdotes.length}", style: boldTextStyle(size: 20)),
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                    ),
                    onPressed: () => _adminController.deleteSelectedAnecdote(),
                  )
                ],
              ),
              body: Container(
                color: context.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Avatar : ",
                          style: boldTextStyle(),
                        ),
                        CachedNetworkImage(height: 50, width: 50, fit: BoxFit.cover, imageUrl: _adminController.getSelectedUserAvatar()),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => {_adminController.copyUserAvatar()},
                                icon: Icon(
                                  Icons.copy,
                                  color: ContextExtensions(context).iconColor,
                                )),
                            IconButton(
                                onPressed: () => {_adminController.downloadUserAvatar()},
                                icon: Icon(
                                  Icons.download,
                                  color: ContextExtensions(context).iconColor,
                                ))
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Auteur : ",
                          style: boldTextStyle(),
                        ),
                        Row(
                          children: [
                            Text(
                              _adminController.getSelectedName(),
                              style: primaryTextStyle(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => {_adminController.copyName()},
                                icon: Icon(
                                  Icons.copy,
                                  color: ContextExtensions(context).iconColor,
                                ))
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Image : ",
                          style: boldTextStyle(),
                        ),
                        CachedNetworkImage(height: 100, width: 100, fit: BoxFit.cover, imageUrl: _adminController.getSelectedImage()),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => {_adminController.copyImage()},
                                icon: Icon(
                                  Icons.copy,
                                  color: ContextExtensions(context).iconColor,
                                )),
                            IconButton(
                                onPressed: () => {_adminController.downloadImage()},
                                icon: Icon(
                                  Icons.download,
                                  color: ContextExtensions(context).iconColor,
                                ))
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Texte : ",
                          style: boldTextStyle(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              _adminController.getSelectedText(),
                              style: primaryTextStyle(),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => {_adminController.copyText()},
                                icon: Icon(
                                  Icons.copy,
                                  color: ContextExtensions(context).iconColor,
                                )),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date : ",
                          style: boldTextStyle(),
                        ),
                        Text(
                          _adminController.getSelectedDate(),
                          style: primaryTextStyle(),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => {_adminController.copyDate()},
                                icon: Icon(
                                  Icons.copy,
                                  color: ContextExtensions(context).iconColor,
                                )),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Visibility(
                          visible: !_adminController.isFirstAnecdote(),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                              onPressed: () => {_adminController.showPrevAnecdote()},
                              icon: Icon(
                                Icons.navigate_before,
                                size: 80,
                                color: ContextExtensions(context).iconColor,
                              )),
                        ),
                        Visibility(
                          visible: !_adminController.isLastAnecdote(),
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                              onPressed: () => {_adminController.showNextAnecdote()},
                              icon: Icon(
                                Icons.navigate_next,
                                size: 80,
                                color: ContextExtensions(context).iconColor,
                              )),
                        )
                      ],
                    )
                  ],
                ).marginSymmetric(horizontal: 16),
              ),
            ));
  }
}
