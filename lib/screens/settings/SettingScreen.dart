import 'package:flutter/material.dart';
import 'package:gazette/controllers/SettingController.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingScreen extends StatelessWidget {
  bool isSwitched1 = false;
  bool isSwitched2 = false;
  bool isSwitched3 = false;
  final SettingController _settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: svGetScaffoldColor(),
      appBar: AppBar(
        backgroundColor: svGetScaffoldColor(),
        title: Text('Paramètres', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ContextExtensions(context).iconColor),
      ),
      body: SafeArea(
        child: Container(
          color: context.scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 6, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Mode sombre", style: boldTextStyle(size: 14)),
                    Switch(
                      onChanged: (value) {
                        _settingController.setDarkMode(value);
                      },
                      value: _settingController.isDarkMode(),
                      activeColor: SVAppColorPrimary,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
