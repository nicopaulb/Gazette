import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gazette/controllers/ProfileController.dart';
import 'package:gazette/models/AnecdoteModel.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/services/PocketBaseService.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                tooltip: 'Actualiser le profil',
                onPressed:
                    _controller.isLoading.value ? null : _controller.reload,
                icon: const Icon(Icons.refresh),
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(
                    semanticsLabel: 'Chargement du profil'));
          }
          if (_controller.profileError.value != null) {
            return Center(
                child: RecoveryMessage(
                    message: _controller.profileError.value!,
                    onRetry: _controller.reload));
          }
          final user = _controller.selectedUser.value;
          if (user == null) {
            return const Center(
                child: RecoveryMessage(message: 'Aucun profil sélectionné.'));
          }
          final isOwnProfile = user.id == PocketbaseService.to.user?.id;
          final initials = [user.firstname.trim(), user.lastname.trim()]
              .where((part) => part.isNotEmpty)
              .map((part) => part.characters.first)
              .join()
              .toUpperCase();
          final hasAnecdoteError = _controller.anecdotesError.value != null;
          final count = NumberFormat.decimalPattern('fr_FR');
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: RefreshIndicator(
                onRefresh: _controller.reload,
                child: CustomScrollView(
                  key: ValueKey(user.id),
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColorPrimary.withValues(
                                        alpha: 0.16)),
                              ),
                              child: Column(children: [
                                ExcludeSemantics(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColorPrimary.withValues(
                                            alpha: 0.12)),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: _controller.getAvatar(),
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            _AvatarFallback(initials),
                                        errorWidget: (_, __, ___) =>
                                            _AvatarFallback(initials),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(_controller.getName(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                if (user.username.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(_controller.getUsername(),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant)),
                                ],
                              ]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _ProfileStat(
                                    value: hasAnecdoteError
                                        ? '—'
                                        : count.format(
                                            _controller.getAnecdotesCount()),
                                    label: 'Anecdotes publiées',
                                    icon: Icons.auto_stories_outlined,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: _ProfileStat(
                                    value: hasAnecdoteError
                                        ? '—'
                                        : count.format(_controller
                                            .getAnecdotesWordsCount()),
                                    label: 'Mots partagés',
                                    icon: Icons.notes_outlined,
                                  )),
                                ]),
                            const SizedBox(height: 28),
                            Text('Anecdotes publiées',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    if (hasAnecdoteError)
                      SliverToBoxAdapter(
                          child: RecoveryMessage(
                              message: _controller.anecdotesError.value!,
                              onRetry: _controller.reload))
                    else if (_controller.anecdotes.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                          child: Column(children: [
                            const Icon(Icons.auto_stories_outlined,
                                size: 40, color: AppColorPrimary),
                            const SizedBox(height: 12),
                            Text('Les souvenirs arrivent bientôt',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                                isOwnProfile
                                    ? 'Vos anecdotes apparaîtront ici une fois publiées dans une gazette.'
                                    : 'Ce profil n’a pas encore d’anecdote publiée.',
                                textAlign: TextAlign.center),
                          ]),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            final anecdote = _controller.anecdotes[index];
                            final date = _date(anecdote);
                            return Semantics(
                              button: true,
                              onTap: () => _openAnecdote(context, anecdote),
                              label:
                                  'Lire l’anecdote du $date : ${anecdote.text}',
                              child: ExcludeSemantics(
                                child: Material(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        _openAnecdote(context, anecdote),
                                    child:
                                        Stack(fit: StackFit.expand, children: [
                                      _AnecdoteImage(
                                          url: _controller
                                              .getAnecdoteImage(index),
                                          fit: BoxFit.cover),
                                      Positioned.fill(
                                          child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.8)
                                        ],
                                      )))),
                                      Positioned(
                                          left: 12,
                                          right: 12,
                                          bottom: 12,
                                          child: Row(children: [
                                            Expanded(
                                                child: Text(date,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.arrow_outward,
                                                color: Colors.white, size: 18),
                                          ])),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          }, childCount: _controller.anecdotes.length),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _date(Anecdote anecdote) => anecdote.date == null
      ? 'Date non renseignée'
      : DateFormat.yMMMd('fr_FR').format(anecdote.date!);

  void _openAnecdote(BuildContext context, Anecdote anecdote) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Row(children: [
              Expanded(
                  child: Text(_date(anecdote),
                      style: Theme.of(context).textTheme.titleMedium)),
              IconButton(
                  tooltip: 'Fermer l’anecdote',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _AnecdoteImage(
                      url: anecdote.imageUri ?? '', fit: BoxFit.contain)),
            ),
            const SizedBox(height: 20),
            SelectableText(anecdote.text,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback(this.initials);
  final String initials;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColorPrimary.withValues(alpha: 0.1),
        child: Center(
            child: initials.isEmpty
                ? const Icon(Icons.person_outline,
                    color: AppColorPrimary, size: 36)
                : Text(initials,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColorPrimary))),
      );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColorPrimary, size: 22),
          const SizedBox(height: 12),
          FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

class _AnecdoteImage extends StatelessWidget {
  const _AnecdoteImage({required this.url, required this.fit});
  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Center(
            child: Tooltip(
                message: 'Image indisponible',
                child: Icon(Icons.broken_image_outlined, size: 36))),
      );
}
