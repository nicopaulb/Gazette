import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/HomeDrawerController.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/screens/admin/AdminScreen.dart';
import 'package:gazette/screens/auth/LogInScreen.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/screens/settings/SettingScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gazette/models/SVDrawerModels.dart';
import 'package:gazette/utils/SVColors.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/models/UserModel.dart';

class SVHomeDrawerComponent extends StatefulWidget {
  @override
  State<SVHomeDrawerComponent> createState() => _SVHomeDrawerComponentState();
}

class _SVHomeDrawerComponentState extends State<SVHomeDrawerComponent> {
  final ProfileController _profileController = Get.put(ProfileController());
  final HomeDrawerController _homeDrawerController =
      Get.put(HomeDrawerController());
  final user = PocketbaseService.to.user!;
  int selectedIndex = -1;

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        50.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                finish(context);
                _profileController.updateUser(user.id);
                ProfileScreen().launch(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CachedNetworkImage(
                          imageUrl: user.getResizedAvatar(100, 100),
                          height: 62,
                          width: 62,
                          fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(8),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user.firstname, style: boldTextStyle(size: 18)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ).paddingOnly(left: 16, right: 8, bottom: 20, top: 20),
        20.height,
        Column(mainAxisSize: MainAxisSize.min, children: [
          SettingItemWidget(
            decoration: BoxDecoration(color: context.cardColor),
            title: "Profil",
            titleTextStyle: boldTextStyle(size: 14),
            leading: Image.asset('images/gazette/icons/ic_Profile.png',
                height: 22,
                width: 22,
                fit: BoxFit.cover,
                color: SVAppColorPrimary),
            onTap: () {
              finish(context);
              _profileController.updateUser(user.id);
              ProfileScreen().launch(context);
            },
          ),
          SettingItemWidget(
            decoration: BoxDecoration(color: context.cardColor),
            title: "Paramètres",
            titleTextStyle: boldTextStyle(size: 14),
            leading: Image.asset('images/gazette/icons/ic_Settings.png',
                height: 22,
                width: 22,
                fit: BoxFit.cover,
                color: SVAppColorPrimary),
            onTap: () {
              finish(context);
              SettingScreen().launch(context);
            },
          ),
          GetBuilder<HomeDrawerController>(
              builder: (_) => user.admin
                  ? SettingItemWidget(
                      decoration: BoxDecoration(color: context.cardColor),
                      title: "Administration",
                      titleTextStyle: boldTextStyle(size: 14),
                      leading: Image.asset(
                          'images/gazette/icons/ic_Document.png',
                          height: 22,
                          width: 22,
                          fit: BoxFit.cover,
                          color: SVAppColorPrimary),
                      onTap: () {
                        finish(context);
                        AdminScreen().launch(context);
                      },
                    )
                  : Container()),
          SettingItemWidget(
            decoration: BoxDecoration(color: context.cardColor),
            title: "Se déconnecter",
            titleTextStyle: boldTextStyle(size: 14),
            leading: Image.asset('images/gazette/icons/ic_Logout.png',
                height: 22,
                width: 22,
                fit: BoxFit.cover,
                color: SVAppColorPrimary),
            onTap: () async {
              await PocketbaseService.to.logout();
              finish(context);
              LogInScreen().launch(context);
            },
          ),
        ]).expand(),
        Divider(indent: 16, endIndent: 16),
        SnapHelperWidget<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          onSuccess: (data) =>
              Text(data.version, style: boldTextStyle(color: svGetBodyColor())),
        ),
        20.height,
      ],
    );
  }
}
