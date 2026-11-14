import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperViewerController.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:gazette/screens/profile/screens/ProfileScreen.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({super.key, required this.anecdote});
  final Anecdote anecdote;

  void _openPhoto(BuildContext context, String name) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
                tooltip: 'Fermer la photo',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close)),
            title: Text('Photo de $name', style: const TextStyle(fontSize: 16)),
          ),
          body: SafeArea(
            child: Column(children: [
              Expanded(
                  child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                trackpadScrollCausesScale: true,
                child: SizedBox.expand(
                    child: _FeedPhoto(
                        url: anecdote.imageUri ?? '',
                        fit: BoxFit.contain,
                        onDark: true)),
              )),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Zoomez pour voir les détails',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = anecdote.user;
    final parts = [user?.firstname.trim() ?? '', user?.lastname.trim() ?? '']
        .where((part) => part.isNotEmpty)
        .toList();
    final name = parts.isNotEmpty
        ? parts.join(' ')
        : (user?.username.isNotEmpty == true
            ? user!.username
            : 'Un membre de la Gazette');
    final initials =
        parts.map((part) => part.characters.first).join().toUpperCase();
    final date = anecdote.date == null
        ? 'Date non renseignée'
        : DateFormat.yMMMMd('fr_FR').format(anecdote.date!);
    final gazette = anecdote.newspaper;

    Widget avatarFallback() => Center(
        child: initials.isEmpty
            ? const Icon(Icons.person_outline, color: AppColorPrimary)
            : Text(initials,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColorPrimary)));

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: anecdote.userId.isEmpty
                ? null
                : () {
                    Get.put(ProfileController()).updateUser(anecdote.userId);
                    Get.to(() => ProfileScreen());
                  },
            hoverColor: AppColorPrimary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(children: [
                ExcludeSemantics(
                    child: Container(
                  width: 44,
                  height: 44,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorPrimary.withValues(alpha: 0.1)),
                  child: CachedNetworkImage(
                    imageUrl: user?.getResizedAvatar() ?? '',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => avatarFallback(),
                    errorWidget: (_, __, ___) => avatarFallback(),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(date,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ])),
                if (anecdote.userId.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SelectableText(anecdote.text,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
          ),
          Tooltip(
            message: 'Agrandir la photo',
            child: InkWell(
              onTap: () => _openPhoto(context, name),
              child: Semantics(
                label: 'Photo de $name. Agrandir la photo',
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(fit: StackFit.expand, children: [
                    _FeedPhoto(
                        url: anecdote.getResizedImage(1000, 1000, true),
                        fit: BoxFit.cover),
                    Positioned(
                        top: 12,
                        right: 12,
                        child: IgnorePointer(
                            child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.open_in_full,
                              color: Colors.white, size: 18),
                        ))),
                  ]),
                ),
              ),
            ),
          ),
          if (gazette != null && gazette.pdfUri?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColorPrimary,
                        minimumSize: const Size(48, 48)),
                    icon: const Icon(Icons.newspaper_outlined, size: 20),
                    label: Text('Lire la gazette n° ${gazette.number}'),
                    onPressed: () {
                      Get.put(NewspaperViewerController()).newspaper = gazette;
                      Get.to(() => NewspaperViewerScreen());
                    },
                  )),
            ),
        ],
      ),
    );
  }
}

class _FeedPhoto extends StatefulWidget {
  const _FeedPhoto({required this.url, required this.fit, this.onDark = false});
  final String url;
  final BoxFit fit;
  final bool onDark;

  @override
  State<_FeedPhoto> createState() => _FeedPhotoState();
}

class _FeedPhotoState extends State<_FeedPhoto> {
  int _attempt = 0;
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    _retrying = true;
    try {
      await CachedNetworkImage.evictFromCache(widget.url);
    } catch (e) {
      Get.log('Photo cache eviction error: $e');
    } finally {
      _retrying = false;
      if (mounted) setState(() => _attempt++);
    }
  }

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        key: ValueKey('${widget.url}:$_attempt'),
        imageUrl: widget.url,
        fit: widget.fit,
        progressIndicatorBuilder: (_, __, progress) => Center(
            child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
              value: progress.progress,
              color: widget.onDark ? Colors.white : AppColorPrimary,
              semanticsLabel: 'Chargement de la photo'),
        )),
        errorWidget: (_, __, ___) {
          final message = RecoveryMessage(
              message: 'Photo indisponible pour le moment.', onRetry: _retry);
          return Center(
              child: SingleChildScrollView(
                  child: widget.onDark
                      ? Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                  primary: Colors.white)),
                          child: message)
                      : message));
        },
      );
}
