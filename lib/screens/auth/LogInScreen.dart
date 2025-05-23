import 'package:flutter/material.dart';
import 'package:gazette/controllers/LoginController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:gazette/screens/DashboardScreen.dart';

class LogInScreen extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      body: Center(
        child: Container(
          height: height,
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/gazette/logo.png', width: width, fit: BoxFit.fill),
              Form(
                  key: _loginController.formKey,
                  child: Container(
                    margin: EdgeInsets.all(24),
                    decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(4)),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _loginController.usernameTextController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nom d'utilisateur requis";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          maxLength: 16,
                          style: secondaryTextStyle(),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            hintText: "Nom d'utilisateur",
                            hintStyle: TextStyle(color: hintTextColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.red, width: 0.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        SizedBox(height: 16),
                        Obx(() => TextFormField(
                              controller: _loginController.passwordTextController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Mot de passe requis";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              onFieldSubmitted: (value) async {
                                if (_loginController.formKey.currentState!.validate()) {
                                  if (await _loginController.onLogin(
                                          _loginController.usernameTextController.text, _loginController.passwordTextController.text) ==
                                      null) {
                                    Get.off(DashboardScreen());
                                  }
                                }
                              },
                              maxLength: 16,
                              style: secondaryTextStyle(),
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                hintText: "Mot de passe",
                                hintStyle: TextStyle(color: hintTextColor),
                                errorText: _loginController.error.value,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: Colors.red, width: 0.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: hintTextColor, width: 0.0),
                                ),
                                border: InputBorder.none,
                              ),
                            )),
                        SizedBox(height: 26),
                        Obx(() => _loginController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                children: <Widget>[
                                  Expanded(
                                      child: TextButton(
                                    style: ButtonStyle(
                                        fixedSize: WidgetStatePropertyAll(Size.fromHeight(70)),
                                        foregroundColor: WidgetStatePropertyAll<Color>(whiteColor),
                                        backgroundColor: WidgetStatePropertyAll<Color>(AppColorPrimary),
                                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: AppColorPrimary)))),
                                    onPressed: () async {
                                      if (_loginController.formKey.currentState!.validate()) {
                                        if (await _loginController.onLogin(
                                                _loginController.usernameTextController.text, _loginController.passwordTextController.text) ==
                                            null) {
                                          Get.off(DashboardScreen());
                                        }
                                      }
                                    },
                                    child: Text("Connexion", style: primaryTextStyle(size: 20, color: whiteColor)),
                                    // decoration: BoxDecoration(
                                    //     color: AppColorPrimary,
                                    //     borderRadius: radius(8))),
                                  )),
                                ],
                              ))
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
