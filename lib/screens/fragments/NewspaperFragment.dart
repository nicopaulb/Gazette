import 'package:flutter/material.dart';
import 'package:gazette/controllers/NewspaperController.dart';
import 'package:gazette/models/NewspaperModel.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/screens/newspaper/NewspaperViewerScreen.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Common.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewspaperFragment extends StatelessWidget {
  final NewspaperController _controller = Get.put(NewspaperController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text('Gazettes',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
              tooltip: 'Actualiser les gazettes',
              onPressed: _controller.isLoading.value
                  ? null
                  : _controller.loadNewspapers,
              icon: const Icon(Icons.refresh))),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: RefreshIndicator(
          onRefresh: _controller.loadNewspapers,
          child: Obx(() {
            final loading = _controller.isLoading.value;
            final error = _controller.loadError.value;
            final downloadError = _controller.downloadError.value;
            final gazettes = _controller.newspapers.toList(growable: false);
            return CustomScrollView(
              key: const PageStorageKey('gazette-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (loading && gazettes.isEmpty)
                  const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: CircularProgressIndicator(
                              semanticsLabel: 'Chargement des gazettes'))),
                if (loading && gazettes.isNotEmpty)
                  const SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: LinearProgressIndicator(
                              semanticsLabel: 'Actualisation des gazettes'))),
                if (error != null)
                  SliverToBoxAdapter(
                      child: RecoveryMessage(
                          message: error, onRetry: _controller.loadNewspapers)),
                if (downloadError != null)
                  SliverToBoxAdapter(
                      child: RecoveryMessage(message: downloadError)),
                if (!loading && gazettes.isEmpty && error == null)
                  const SliverFillRemaining(
                      hasScrollBody: false,
                      child: RecoveryMessage(
                          message:
                              'Aucune gazette disponible pour le moment.')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    final gazette = gazettes[index];
                    final year = gazette.date?.year;
                    final showYear =
                        index == 0 || gazettes[index - 1].date?.year != year;
                    return Column(
                        key: ValueKey(gazette.id),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showYear)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
                              child: Text(year?.toString() ?? 'Sans date',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _GazetteCard(
                                gazette: gazette,
                                latest: index == 0,
                                onRead: () {
                                  _controller.startNewspaperViewer(index);
                                  Get.to(() => NewspaperViewerScreen());
                                },
                                onDownload: () => _controller.download(index),
                              )),
                        ]);
                  }, childCount: gazettes.length)),
                ),
              ],
            );
          }),
        ),
      ))),
    );
  }
}

class _GazetteCard extends StatelessWidget {
  const _GazetteCard(
      {required this.gazette,
      required this.latest,
      required this.onRead,
      required this.onDownload});
  final Newspaper gazette;
  final bool latest;
  final VoidCallback onRead;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = gazette.pdfUri?.isNotEmpty == true;
    final date = gazette.date == null
        ? 'Date non renseignée'
        : DateFormat.yMMMM('fr_FR').format(gazette.date!);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: latest
            ? Border.all(color: AppColorPrimary.withValues(alpha: 0.3))
            : null,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 480;
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (latest) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Dernière gazette',
                        style: TextStyle(
                            color: AppColorPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(children: [
                  if (wide) ...[
                    ExcludeSemantics(
                        child: Container(
                      width: 64,
                      height: 84,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColorPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.newspaper_outlined,
                                size: 24, color: AppColorPrimary),
                            const SizedBox(height: 6),
                            FittedBox(
                                child: Text('${gazette.number}',
                                    style: const TextStyle(
                                        color: AppColorPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700))),
                          ]),
                    )),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Gazette n° ${gazette.number}',
                            style: (wide
                                    ? theme.textTheme.titleLarge
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(date,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ])),
                ]),
                if (gazette.anecdoteCount != null ||
                    gazette.userCount != null) ...[
                  const SizedBox(height: 16),
                  Wrap(spacing: 20, runSpacing: 8, children: [
                    if (gazette.anecdoteCount != null)
                      _GazetteMetric(
                          icon: Icons.auto_stories_outlined,
                          text:
                              '${gazette.anecdoteCount} ${gazette.anecdoteCount == 1 ? 'anecdote' : 'anecdotes'}'),
                    if (gazette.userCount != null)
                      _GazetteMetric(
                          icon: Icons.people_outline,
                          text:
                              '${gazette.userCount} ${gazette.userCount == 1 ? 'participant' : 'participants'}'),
                  ]),
                ],
                if (!available)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text('PDF indisponible',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))),
              ])),
          const SizedBox(width: 16),
          SizedBox(
            width: wide ? 164 : 116,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: available ? onRead : null,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColorPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12)),
                    icon: wide
                        ? const Icon(Icons.menu_book_outlined, size: 20)
                        : null,
                    label: const Text('Lire'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: available ? onDownload : null,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12)),
                    icon: wide
                        ? const Icon(Icons.download_outlined, size: 20)
                        : null,
                    label:
                        const Text('Télécharger', textAlign: TextAlign.center),
                  ),
                ]),
          ),
        ]);
      }),
    );
  }
}

class _GazetteMetric extends StatelessWidget {
  const _GazetteMetric({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
            size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ]);
}
