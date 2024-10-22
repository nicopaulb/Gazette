import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';

class SVPostComponent extends StatefulWidget {
  @override
  State<SVPostComponent> createState() => _SVPostComponentState();
}

class _SVPostComponentState extends State<SVPostComponent> {
  final AnecdoteController _anecdoteController = Get.put(AnecdoteController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => _anecdoteController.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : _anecdoteController.anecdotes.isEmpty
            ? const Center(
                child: Text("Erreur lors de la récuparation des anecdotes"))
            : ListView.builder(
                itemCount: _anecdoteController.anecdotes.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: radius(SVAppCommonRadius),
                        color: context.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      _anecdoteController.getUserAvatar(index),
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(SVAppCommonRadius),
                                12.width,
                                Text(_anecdoteController.getUserName(index),
                                    style: boldTextStyle()),
                              ],
                            ).paddingSymmetric(horizontal: 16),
                            Row(
                              children: [
                                Text(_anecdoteController.getDate(index),
                                    style: secondaryTextStyle(
                                        color: svGetBodyColor(), size: 12)),
                              ],
                            ).paddingSymmetric(horizontal: 16),
                          ],
                        ),
                        16.height,
                        svRobotoText(
                                text: _anecdoteController.getText(index),
                                textAlign: TextAlign.start)
                            .paddingSymmetric(horizontal: 16),
                        16.height,
                        CachedNetworkImage(
                          imageUrl: _anecdoteController.getImage(index),
                          height: 300,
                          width: ContextExtensions(context).width() - 32,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(SVAppCommonRadius).center(),
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ));
  }
}
