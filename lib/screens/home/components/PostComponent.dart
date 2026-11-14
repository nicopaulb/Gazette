import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/screens/home/components/FeedPostCard.dart';
import 'package:gazette/screens/home/components/HomeStatsComponent.dart';
import 'package:get/get.dart';

class PostComponent extends StatelessWidget {
  final AnecdoteController _controller = Get.put(AnecdoteController());

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: RefreshIndicator(
            onRefresh: _controller.refreshFeed,
            child: GetBuilder<AnecdoteController>(
                builder: (_) => Obx(() {
                      final posts =
                          _controller.anecdotes.toList(growable: false);
                      final loading = _controller.isLoading.value;
                      final loadingMore = _controller.isLoadingMore.value;
                      final error = _controller.loadError.value;
                      final moreError = _controller.moreError.value;
                      return CustomScrollView(
                        key: const PageStorageKey('home-feed'),
                        controller: _controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                              child:
                                  HomeStatsComponent(controller: _controller)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                            sliver: SliverToBoxAdapter(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Le fil de la Gazette',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                              ],
                            )),
                          ),
                          if (loading)
                            SliverToBoxAdapter(
                                child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: LinearProgressIndicator(
                                  semanticsLabel: posts.isEmpty
                                      ? 'Chargement des anecdotes'
                                      : 'Actualisation du fil'),
                            )),
                          if (error != null)
                            SliverToBoxAdapter(
                                child: RecoveryMessage(
                                    message: error,
                                    onRetry: _controller.loadFirstAnecdotes)),
                          if (posts.isEmpty && !loading && error == null)
                            SliverToBoxAdapter(
                                child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 24, 24, 40),
                              child: Column(children: [
                                Icon(Icons.auto_stories_outlined,
                                    size: 44,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text('Les souvenirs arrivent bientôt',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                const Text(
                                    'Les anecdotes apparaîtront ici une fois publiées dans une gazette.',
                                    textAlign: TextAlign.center),
                              ]),
                            )),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                key: ValueKey(posts[index].id),
                                padding: const EdgeInsets.only(bottom: 20),
                                child: FeedPostCard(anecdote: posts[index]),
                              ),
                              childCount: posts.length,
                            )),
                          ),
                          SliverToBoxAdapter(
                              child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: loadingMore
                                ? const Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                            semanticsLabel:
                                                'Chargement de la suite')))
                                : moreError != null
                                    ? RecoveryMessage(
                                        message: moreError,
                                        onRetry: _controller.loadMoreAnecdotes)
                                    : posts.isNotEmpty &&
                                            error == null &&
                                            !loading
                                        ? _controller.canLoadMore
                                            ? Center(
                                                child: OutlinedButton.icon(
                                                    onPressed: _controller
                                                        .loadMoreAnecdotes,
                                                    icon: const Icon(
                                                        Icons.expand_more),
                                                    label: const Text(
                                                        'Voir plus d’anecdotes')))
                                            : Text(
                                                'Vous avez parcouru tous les souvenirs.',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant))
                                        : const SizedBox.shrink(),
                          )),
                        ],
                      );
                    })),
          ),
        ),
      );
}
