import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/tasks/presentation/tasks_viewmodel.dart';

class ReminderRow extends ConsumerWidget {
  const ReminderRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskCountAsync = ref.watch(activeTaskCountProvider);

    return Row(
      children: [
        Expanded(
          child: LuxuryCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TÂCHES",
                      style: TextStyle(
                        color: AppTheme.offWhite.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    taskCountAsync.when(
                      data: (count) => Text(
                        "$count",
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                      loading: () => const SizedBox(
                          height: 24, width: 24, child: CircularProgressIndicator()),
                      error: (_, __) => const Text("?"),
                    ),
                  ],
                ),
                Icon(Icons.checklist, color: AppTheme.gold.withOpacity(0.8)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LuxuryCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INCIDENTS",
                      style: TextStyle(
                        color: AppTheme.offWhite.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "2",
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                      ),
                    ),
                  ],
                ),
                Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed.withOpacity(0.8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
