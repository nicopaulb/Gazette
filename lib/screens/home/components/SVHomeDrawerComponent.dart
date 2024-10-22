import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/screens/auth/LogInScreen.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
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
  List<SVDrawerModel> options = getDrawerOptions();
  User user = PocketbaseService.to.user!;

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        50.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
            )
          ],
        ).paddingOnly(left: 16, right: 8, bottom: 20, top: 20),
        20.height,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((e) {
            int index = options.indexOf(e);
            return SettingItemWidget(
              decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? SVAppColorPrimary.withAlpha(30)
                      : context.cardColor),
              title: e.title.validate(),
              titleTextStyle: boldTextStyle(size: 14),
              leading: Image.asset(e.image.validate(),
                  height: 22,
                  width: 22,
                  fit: BoxFit.cover,
                  color: SVAppColorPrimary),
              onTap: () async {
                selectedIndex = index;
                setState(() {});
                switch (selectedIndex) {
                  case 0:
                    finish(context);
                    ProfileScreen().launch(context);
                    break;
                  case 2:
                    await PocketbaseService.to.logout();
                    finish(context);
                    LogInScreen().launch(context);
                    break;
                  default:
                    finish(context);
                    break;
                }
              },
            );
          }).toList(),
        ).expand(),
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
