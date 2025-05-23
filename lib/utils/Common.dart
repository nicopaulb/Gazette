import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/main.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Constants.dart';

Widget robotoText({required String text, Color? color, FontStyle? fontStyle, Function? onTap, TextAlign? textAlign}) {
  return Text(
    text,
    style: secondaryTextStyle(
      fontFamily: fontRoboto,
      color: color ?? getBodyColor(),
      fontStyle: fontStyle ?? FontStyle.normal,
    ),
    textAlign: textAlign ?? TextAlign.center,
  ).onTap(onTap, splashColor: Colors.transparent, highlightColor: Colors.transparent);
}

Color getBodyColor() {
  if (appStore.isDarkMode)
    return BodyDark;
  else
    return BodyWhite;
}

Color getScaffoldColor() {
  if (appStore.isDarkMode)
    return appBackgroundColorDark;
  else
    return AppLayoutBackground;
}
