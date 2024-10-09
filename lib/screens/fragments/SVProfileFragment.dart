import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:prokit_socialv/main.dart';
import 'package:prokit_socialv/screens/profile/components/SVProfileHeaderComponent.dart';
import 'package:prokit_socialv/screens/profile/components/SVProfilePostsComponent.dart';
import 'package:prokit_socialv/utils/SVCommon.dart';
import 'package:prokit_socialv/utils/SVConstants.dart';

import '../../utils/SVColors.dart';

class SVProfileFragment extends StatefulWidget {
  const SVProfileFragment({Key? key}) : super(key: key);

  @override
  State<SVProfileFragment> createState() => _SVProfileFragmentState();
}

class _SVProfileFragmentState extends State<SVProfileFragment> {
  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
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
                children: [
                  Text('Nicolas', style: boldTextStyle(size: 20))
                ],
              ),
              Text('@admin', style: secondaryTextStyle(color: svGetBodyColor())),
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Annecdotes', style: secondaryTextStyle(color: svGetBodyColor(), size: 12)),
                      4.height,
                      Text('16', style: boldTextStyle(size: 18)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Mots', style: secondaryTextStyle(color: svGetBodyColor(), size: 12)),
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
      ),
    );
  }
}
