import 'package:flutter/material.dart';
import 'package:gazette/controllers/AnecdoteController.dart';
import 'package:gazette/screens/components/RecoveryMessage.dart';
import 'package:gazette/utils/Colors.dart';
import 'package:gazette/utils/Constants.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeStatsComponent extends StatelessWidget {
  const HomeStatsComponent({super.key, required this.controller});

  final AnecdoteController controller;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppCommonRadius),
        ),
        child: Obx(() {
          if (controller.isLoadingStats.value) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Semantics(
                label: 'Chargement des statistiques',
                child: const LinearProgressIndicator(),
              ),
            );
          }
          if (controller.statsError.value != null) {
            return RecoveryMessage(
              message: controller.statsError.value!,
              onRetry: controller.loadPublishedStats,
            );
          }
          final stats = controller.publishedStats.value;
          if (stats == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 480 ? 3 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 20) / columns;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: width,
                    child: _Statistic(
                      icon: Icons.auto_stories_outlined,
                      count: stats.total,
                      label: 'Anecdotes publiées au total',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _Statistic(
                      icon: Icons.newspaper_outlined,
                      count: stats.latestEditionCount,
                      label: 'Dans la dernière gazette',
                      detail: stats.latestEditionNumber == null
                          ? 'Aucune gazette disponible'
                          : 'Gazette n° ${stats.latestEditionNumber}',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _Statistic(
                      icon: Icons.library_books_outlined,
                      count: stats.editionCount,
                      label: 'Gazettes parues',
                    ),
                  ),
                ],
              );
            }),
          );
        }),
      );
}

class _Statistic extends StatelessWidget {
  const _Statistic(
      {required this.icon,
      required this.count,
      required this.label,
      this.detail});

  final IconData icon;
  final int count;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColorPrimary, size: 24),
            const SizedBox(height: 8),
            Text(NumberFormat.decimalPattern('fr_FR').format(count),
                style: boldTextStyle(size: 30)),
            const SizedBox(height: 4),
            Text(label, style: primaryTextStyle(size: 14)),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Text(detail!, style: secondaryTextStyle(size: 12)),
            ],
          ],
        ),
      );
}
