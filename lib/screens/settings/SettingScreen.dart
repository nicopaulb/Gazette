import 'package:flutter/material.dart';
import 'package:gazette/controllers/SettingController.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingScreen extends StatelessWidget {
  final SettingController _settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
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
                      activeColor: AppColorPrimary,
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 6, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Supprimer les données en cache", style: boldTextStyle(size: 14)),
                    IconButton(
                        onPressed: () => {_settingController.clearCache()},
                        icon: Icon(
                          Icons.delete,
                          color: ContextExtensions(context).iconColor,
                        ))
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
