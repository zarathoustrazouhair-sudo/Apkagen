import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;

class SyndicMoodWidget extends ConsumerWidget {
  const SyndicMoodWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<Transaction>>(
      stream: db.select(db.transactions).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final txs = snapshot.data!;
        double cash = 0.0;
        for (var tx in txs) {
          if (tx.type == 'income') cash += tx.amount;
          if (tx.type == 'expense') cash -= tx.amount;
        }

        String emoji = "😐";
        String status = "STABLE";
        Color color = Colors.orange;

        if (cash > 50000) {
          emoji = "🤑";
          status = "RICHE";
          color = Colors.greenAccent;
        } else if (cash > 10000) {
          emoji = "😎";
          status = "CONFORT";
          color = Colors.green;
        } else if (cash < 0) {
          emoji = "💀";
          status = "CRITIQUE";
          color = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppPalettes.offBlack.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SANTÉ FINANCIÈRE", style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.7), fontSize: 10)),
                    Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              Text("${cash.toStringAsFixed(0)} DH", style: const TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}
