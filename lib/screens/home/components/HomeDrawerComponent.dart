import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/screens/admin/AdminScreen.dart';
import 'package:gazette/screens/auth/LogInScreen.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/screens/settings/SettingScreen.dart';
import 'package:gazette/screens/fragments/SearchFragment.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gazette/utils/Colors.dart';

class HomeDrawerComponent extends StatefulWidget {
  @override
  State<HomeDrawerComponent> createState() => _HomeDrawerComponentState();
}

class _HomeDrawerComponentState extends State<HomeDrawerComponent> {
  final ProfileController _profileController = Get.put(ProfileController());
  final user = PocketbaseService.to.user!;
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  bool _signingOut = false;
  String? _logoutError;

  void _open(Widget Function() page) {
    Navigator.of(context).pop();
    Get.to(page);
  }

  void _openProfile() {
    _profileController.updateUser(user.id);
    _open(() => ProfileScreen());
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() {
      _signingOut = true;
      _logoutError = null;
    });
    try {
      await PocketbaseService.to.logout();
      if (!mounted) return;
      Get.offAll(() => LogInScreen());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _signingOut = false;
        _logoutError = 'Impossible de vous déconnecter. Réessayez.';
      });
      Get.log('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = [user.firstname.trim(), user.lastname.trim()]
        .where((name) => name.isNotEmpty)
        .toList();
    final name = names.isEmpty ? user.username : names.join(' ');
    final initials = names.isEmpty
        ? (user.username.isEmpty
            ? '?'
            : user.username.characters.first.toUpperCase())
        : names.map((name) => name.characters.first).join().toUpperCase();
    final avatar = user.getResizedAvatar();

    Widget avatarFallback() => Center(
          child: Text(initials,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColorPrimary)),
        );

    return Material(
      color: theme.cardColor,
      child: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_stories_outlined,
                              color: AppColorPrimary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text('Gazette',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700))),
                          IconButton(
                            tooltip: 'Fermer le menu',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColorPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.cardColor),
                                  child: avatar.isEmpty
                                      ? avatarFallback()
                                      : CachedNetworkImage(
                                          imageUrl: avatar,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              avatarFallback(),
                                          errorWidget: (_, __, ___) =>
                                              avatarFallback(),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              if (user.username.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('@${user.username}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ],
                              if (user.admin) ...[
                                const SizedBox(height: 12),
                                Row(children: [
                                  const Icon(Icons.verified_user_outlined,
                                      size: 16, color: AppColorPrimary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                      child: Text('Administrateur',
                                          style: theme.textTheme.labelMedium)),
                                ]),
                              ],
                            ],
                          ),
                        ),
                        const _SectionLabel('Parcourir'),
                        _MenuItem(
                          icon: Icons.search,
                          title: 'Rechercher',
                          subtitle: 'Trouver une anecdote',
                          onTap: _signingOut
                              ? null
                              : () => _open(() => const SearchFragment()),
                        ),
                        const _SectionLabel('Mon compte'),
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Mon profil',
                          subtitle: 'Mes informations et anecdotes',
                          onTap: _signingOut ? null : _openProfile,
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          subtitle: 'Apparence et cache',
                          onTap: _signingOut
                              ? null
                              : () => _open(() => SettingScreen()),
                        ),
                        if (user.admin) ...[
                          const _SectionLabel('Gestion de la gazette'),
                          _MenuItem(
                            icon: Icons.edit_note_outlined,
                            title: 'Administration',
                            subtitle: 'Gérer les anecdotes et publications',
                            onTap: _signingOut
                                ? null
                                : () => _open(() => AdminScreen()),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        if (_logoutError != null)
                          Semantics(
                              liveRegion: true,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(_logoutError!,
                                    style: TextStyle(
                                        color: theme.colorScheme.error)),
                              )),
                        TextButton.icon(
                          onPressed: _signingOut ? null : _signOut,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            minimumSize: const Size.fromHeight(48),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          icon: _signingOut
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.error))
                              : const Icon(Icons.logout, size: 22),
                          label: Text(
                              _signingOut ? 'Déconnexion…' : 'Se déconnecter'),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<PackageInfo>(
                          future: _packageInfo,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData
                                ? 'Gazette · Version ${snapshot.data!.version}'
                                : 'Gazette',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
        child: Text(label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
      );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          enabled: onTap != null,
          onTap: onTap,
          hoverColor: AppColorPrimary.withValues(alpha: 0.06),
          focusColor: AppColorPrimary.withValues(alpha: 0.12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColorPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColorPrimary, size: 22),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
      );
}
