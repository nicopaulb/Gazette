import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  Rxn<String> error = Rxn<String>();
  final usernameTextController = TextEditingController(text: "");
  final passwordTextController = TextEditingController(text: "");
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int tentative = 0;

  @override
  void onInit() {
    passwordTextController.addListener(_onPasswordChange);
    super.onInit();
  }

  Future<int?> onLogin(String username, String password) async {
    int? rv = null;
    isLoading.value = true;
    try {
      await PocketbaseService.to.login(username, password);
    } on ClientException catch (e) {
      switch (e.statusCode) {
        case 0:
          error.value = "Impossible d'accéder à la base de donnée";
        case 400:
          error.value = "Nom d'utilisateur ou mot de passe incorrect";
          tentative++;
          if (tentative > 3) {
            await Future.delayed(Duration(seconds: pow(tentative - 3, 2).round()));
          }
      }
      rv = e.statusCode;
    }
    isLoading.value = false;
    return rv;
  }

  void _onPasswordChange() {
    error.value = null;
  }
}
