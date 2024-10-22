import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/main.dart';
import 'package:gazette/screens/profile/components/SVProfileHeaderComponent.dart';
import 'package:gazette/screens/profile/components/SVProfilePostsComponent.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/utils/SVConstants.dart';

import '../../../utils/SVColors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: svGetScaffoldColor(),
      appBar: AppBar(
        backgroundColor: svGetScaffoldColor(),
        title: Text('Profile', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.iconColor),
        actions: [
          Switch(
            onChanged: (val) {
              appStore.toggleDarkMode(value: val);
            },
            value: appStore.isDarkMode,
            activeColor: SVAppColorPrimary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SVProfileHeaderComponent(),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Nicolas', style: boldTextStyle(size: 20))],
            ),
            Text('@admin', style: secondaryTextStyle(color: svGetBodyColor())),
            24.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Annecdotes',
                        style: secondaryTextStyle(
                            color: svGetBodyColor(), size: 12)),
                    4.height,
                    Text('16', style: boldTextStyle(size: 18)),
                  ],
                ),
                Column(
                  children: [
                    Text('Mots',
                        style: secondaryTextStyle(
                            color: svGetBodyColor(), size: 12)),
                    4.height,
                    Text('1k', style: boldTextStyle(size: 18)),
                  ],
                )
              ],
            ),
            16.height,
            SVProfilePostsComponent(),
            16.height,
          ],
        ),
      ),
    );
  }
}
