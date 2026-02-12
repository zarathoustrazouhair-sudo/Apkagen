import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/services/pdf_generator_service.dart';

class ResidentDetailScreen extends ConsumerWidget {
  final int userId;
  const ResidentDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("DÉTAIL RÉSIDENT", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<User>(
        stream: (db.select(db.users)..where((t) => t.id.equals(userId))).watchSingle(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                LuxuryCard(
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: AppTheme.gold, child: Icon(Icons.person, color: AppTheme.darkNavy)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Appartement ${user.apartmentNumber}", style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7))),
                        ],
                      ),
                      const Spacer(),
                      Text("${user.balance.toStringAsFixed(2)} DH", style: TextStyle(color: user.balance < 0 ? AppTheme.errorRed : const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("HISTORIQUE DES TRANSACTIONS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Transaction List (Mocked for now as we didn't fully implement Transactions table yet)
                Expanded(
                  child: ListView(
                    children: [
                      _buildTransactionTile(context, user, "12/03/2024", 250.0, "Cotisation Mars", true),
                      _buildTransactionTile(context, user, "10/02/2024", 250.0, "Cotisation Février", true),
                      _buildTransactionTile(context, user, "01/01/2024", -250.0, "Débit Janvier", false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, User user, String date, double amount, String desc, bool isCredit) {
    return Card(
      color: Colors.black26,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red),
        title: Text(desc, style: const TextStyle(color: AppTheme.offWhite)),
        subtitle: Text(date, style: TextStyle(color: AppTheme.offWhite.withOpacity(0.5))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${amount > 0 ? '+' : ''}$amount DH", style: TextStyle(color: isCredit ? const Color(0xFF00E5FF) : AppTheme.errorRed, fontWeight: FontWeight.bold)),
            if (isCredit)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: AppTheme.gold),
                onPressed: () {
                  PdfGeneratorService().generateReceipt(
                    transactionId: 999, // Mock
                    residentName: user.name,
                    lotNumber: user.apartmentNumber ?? 0,
                    amount: amount,
                    mode: "Virement",
                    period: "Mars 2024",
                    oldBalance: user.balance - amount,
                    newBalance: user.balance,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
