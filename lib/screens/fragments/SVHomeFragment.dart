import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:gazette/screens/home/components/SVHomeDrawerComponent.dart';
import 'package:gazette/screens/home/components/SVPostComponent.dart';
import 'package:gazette/utils/SVCommon.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/models/UserModel.dart';

class SVHomeFragment extends StatefulWidget {
  @override
  State<SVHomeFragment> createState() => _SVHomeFragmentState();
}

class _SVHomeFragmentState extends State<SVHomeFragment> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  User user = PocketbaseService.to.user!;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(svGetScaffoldColor());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: svGetScaffoldColor(),
      appBar: AppBar(
        backgroundColor: svGetScaffoldColor(),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'images/gazette/icons/ic_More.png',
            width: 18,
            height: 18,
            fit: BoxFit.cover,
            color: context.iconColor,
          ),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text('Home', style: boldTextStyle(size: 18)),
        actions: [
          IconButton(
            icon: CachedNetworkImage(
                    imageUrl: user.getResizedAvatar(100, 100),
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover)
                .paddingTop(12),
            onPressed: () {
              ProfileScreen().launch(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: context.cardColor,
        child: SVHomeDrawerComponent(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            16.height,
            SVPostComponent(),
            16.height,
          ],
        ),
      ),
    );
  }
}
