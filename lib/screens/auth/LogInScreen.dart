import 'package:flutter/material.dart';
import 'package:gazette/controllers/LoginController.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/screens/SVDashboardScreen.dart';

class LogInScreen extends StatelessWidget {
  final _usernameTextController = TextEditingController(text: "");
  final _passwordTextController = TextEditingController(text: "");
  final LoginController _loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: svGetScaffoldColor(),
      body: Container(
        height: height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/gazette/logo.png', width: width),
            //    Text("Authentification", style: boldTextStyle(size: 30)),
            Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: context.scaffoldBackgroundColor,
                      borderRadius: radius(4)),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameTextController,
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
                            borderSide: const BorderSide(
                                color: hintTextColor, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                                color: hintTextColor, width: 0.0),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordTextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Mot de passe requis";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        maxLength: 16,
                        style: secondaryTextStyle(),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                          hintText: "Mot de passe",
                          hintStyle: TextStyle(color: hintTextColor),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                                color: hintTextColor, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                                color: hintTextColor, width: 0.0),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 26),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  String? error =
                                      await _loginController.onLogin(
                                          _usernameTextController.text,
                                          _passwordTextController.text);
                                  if (error != null) {
                                    printInfo(info: error);
                                  } else {
                                    SVDashboardScreen()
                                        .launch(context, isNewTask: true);
                                  }
                                }
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  height: width / 8,
                                  child: Text("Connexion",
                                      style: primaryTextStyle(
                                          size: 20, color: whiteColor)),
                                  decoration: BoxDecoration(
                                      color: SVAppColorPrimary,
                                      borderRadius: radius(8))),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
