import 'package:flutter/material.dart';
import 'package:gazette/main.dart';
import 'package:gazette/services/StorageService.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingController extends GetxController {
  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });

    super.onInit();
  }

  void setDarkMode(bool enabled) {
    appStore.toggleDarkMode(value: enabled);
  }

  bool isDarkMode() {
    return appStore.isDarkMode;
  }

  void clearCache() {
    StorageService.to.clear();
  }
}
