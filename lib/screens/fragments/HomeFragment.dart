import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/screens/home/components/HomeDrawerComponent.dart';
import 'package:gazette/screens/home/components/PostComponent.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';

class HomeFragment extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final user = PocketbaseService.to.user!;
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: getScaffoldColor(),
        appBar: AppBar(
          backgroundColor: getScaffoldColor(),
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          elevation: 0,
          leading: IconButton(
            tooltip: 'Ouvrir le menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text('Accueil',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              tooltip: 'Actualiser le fil',
              icon: const Icon(Icons.refresh),
              onPressed: () => Get.find<AnecdoteController>().refreshFeed(),
            ),
            IconButton(
              tooltip: 'Mon profil',
              onPressed: () {
                _profileController.updateUser(user.id);
                Get.to(() => ProfileScreen());
              },
              icon: ClipOval(
                  child: CachedNetworkImage(
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                imageUrl: user.getResizedAvatar(),
                placeholder: (_, __) => const Icon(
                    Icons.account_circle_outlined,
                    color: AppColorPrimary,
                    size: 32),
                errorWidget: (_, __, ___) => const Icon(
                    Icons.account_circle_outlined,
                    color: AppColorPrimary,
                    size: 32),
              )),
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: Drawer(
          semanticLabel: 'Menu principal',
          backgroundColor: Theme.of(context).cardColor,
          child: HomeDrawerComponent(),
        ),
        body: PostComponent(),
      );
}
