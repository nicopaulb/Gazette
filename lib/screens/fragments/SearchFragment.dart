import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/Common.dart';

class SearchFragment extends StatelessWidget {
  // @override
  // void initState() {
  //   super.initState();
  //   afterBuildCreated(() {
  //     setStatusBarColor(GetScaffoldColor());
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        iconTheme: IconThemeData(color: context.iconColor),
        leadingWidth: 30,
        // title: Container(
        //   decoration:
        //       BoxDecoration(color: context.cardColor, borderRadius: radius(8)),
        //   child: AppTextField(
        //     textFieldType: TextFieldType.NAME,
        //     decoration: InputDecoration(
        //       border: InputBorder.none,
        //       hintText: 'Search Here',
        //       hintStyle: secondaryTextStyle(color: GetBodyColor()),
        //       prefixIcon: Image.asset('images/gazette/icons/ic_Search.png',
        //               height: 16,
        //               width: 16,
        //               fit: BoxFit.cover,
        //               color: GetBodyColor())
        //           .paddingAll(16),
        //     ),
        //   ),
        // ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('En construction ;)', style: boldTextStyle()).paddingAll(16).center(),
            // ListView.separated(
            //   padding: EdgeInsets.all(16),
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemBuilder: (context, index) {
            //     return SearchCardComponent(element: list[index]).onTap(() {
            //       ProfileScreen().launch(context);
            //     });
            //   },
            //   separatorBuilder: (BuildContext context, int index) {
            //     return Divider(height: 20);
            //   },
            //   itemCount: list.length,
            // ),
          ],
        ),
      ),
    );
  }
}
