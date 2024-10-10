import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';

class SVPostOptionsComponent extends StatefulWidget {
  @override
  State<SVPostOptionsComponent> createState() => _SVPostOptionsComponentState();
}

class _SVPostOptionsComponentState extends State<SVPostOptionsComponent> {
  List<String> list = [
    'images/gazette/posts/post_one.png',
    'images/gazette/posts/post_two.png',
    'images/gazette/posts/post_three.png',
    'images/gazette/postImage.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: svGetScaffoldColor(),
        borderRadius: radiusOnly(
            topRight: SVAppContainerRadius, topLeft: SVAppContainerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: 62,
                  width: 52,
                  color: context.cardColor,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Image.asset('images/gazette/icons/ic_CameraPost.png',
                      height: 22, width: 22, fit: BoxFit.cover),
                ),
                HorizontalList(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Image.asset(list[index],
                        height: 62, width: 52, fit: BoxFit.cover);
                  },
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('images/gazette/icons/ic_Video.png',
                  height: 32, width: 32, fit: BoxFit.cover),
              //Image.asset('images/gazette/icons/ic_CameraPost.png', height: 32, width: 32, fit: BoxFit.cover),
              Image.asset('images/gazette/icons/ic_Voice.png',
                  height: 32, width: 32, fit: BoxFit.cover),
              Image.asset('images/gazette/icons/ic_Location.png',
                  height: 32, width: 32, fit: BoxFit.cover),
              Image.asset('images/gazette/icons/ic_Paper.png',
                  height: 32, width: 32, fit: BoxFit.cover),
            ],
          ),
        ],
      ),
    );
  }
}
