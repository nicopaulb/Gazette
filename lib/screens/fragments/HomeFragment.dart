import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/screens/home/components/HomeDrawerComponent.dart';
import 'package:gazette/screens/home/components/PostComponent.dart';
import 'package:gazette/utils/Common.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/models/UserModel.dart';

class HomeFragment extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final User user = PocketbaseService.to.user!;
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'images/gazette/icons/ic_More.png',
            width: 18,
            height: 18,
            fit: BoxFit.cover,
            color: ContextExtensions(context).iconColor,
          ),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text('Accueil', style: boldTextStyle(size: 18)),
        actions: [
          InkWell(
            onTap: () {
              _profileController.updateUser(user.id);
              Get.to(ProfileScreen());
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                imageUrl: user.getResizedAvatar(),
                errorWidget: (context, url, error) => Image.asset(
                  'images/gazette/icons/ic_Profile.png',
                  color: AppColorPrimary,
                ),
              ),
            ),
          ).paddingRight(12),
        ],
      ),
      drawer: Drawer(
        backgroundColor: context.cardColor,
        child: HomeDrawerComponent(),
      ),
      body: PostComponent(),
    );
  }
}
