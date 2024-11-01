import 'package:flutter/material.dart';
import 'package:gazette/main.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeDrawerController extends GetxController {
  @override
  void onInit() {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent);
    });

    super.onInit();
  }
}
