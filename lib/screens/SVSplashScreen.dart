import 'package:flutter/material.dart';
import 'package:gazette/screens/SVDashboardScreen.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/screens/auth/LogInScreen.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/services/PocketBaseService.dart';

class SVSplashScreen extends StatefulWidget {
  const SVSplashScreen({Key? key}) : super(key: key);

  @override
  State<SVSplashScreen> createState() => _SVSplashScreenState();
}

class _SVSplashScreenState extends State<SVSplashScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent);
    await Future.delayed(Duration(seconds: 1));
    finish(context);
    if (PocketbaseService.to.isAuth) {
      Get.off(SVDashboardScreen());
    } else {
      Get.off(LogInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: svGetScaffoldColor(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Image.asset(
                  'images/gazette/logo.png',
                  //height: context.height(),
                  width: ContextExtensions(context).width(),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            //your widgets here...
          ],
        ));
  }
}
