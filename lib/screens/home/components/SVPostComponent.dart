import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/models/SVPostModel.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';

class SVPostComponent extends StatefulWidget {
  @override
  State<SVPostComponent> createState() => _SVPostComponentState();
}

class _SVPostComponentState extends State<SVPostComponent> {
  List<SVPostModel> postList = getPosts();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: postList.length,
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
                      Image.asset(
                        postList[index].profileImage.validate(),
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(SVAppCommonRadius),
                      12.width,
                      Text(postList[index].name.validate(),
                          style: boldTextStyle()),
                    ],
                  ).paddingSymmetric(horizontal: 16),
                  Row(
                    children: [
                      Text('${postList[index].time.validate()}',
                          style: secondaryTextStyle(
                              color: svGetBodyColor(), size: 12)),
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ],
              ),
              16.height,
              postList[index].description.validate().isNotEmpty
                  ? svRobotoText(
                          text: postList[index].description.validate(),
                          textAlign: TextAlign.start)
                      .paddingSymmetric(horizontal: 16)
                  : Offstage(),
              postList[index].description.validate().isNotEmpty
                  ? 16.height
                  : Offstage(),
              Image.asset(
                postList[index].postImage.validate(),
                height: 300,
                width: context.width() - 32,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(SVAppCommonRadius).center(),
            ],
          ),
        );
      },
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }
}
