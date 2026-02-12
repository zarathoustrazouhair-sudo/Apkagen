import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/services/pdf_generator_service.dart';

class ResidentDetailScreen extends ConsumerWidget {
  final int userId;
  const ResidentDetailScreen({super.key, required this.userId});

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Could not launch $launchUri");
      }
    } catch (e) {
      debugPrint("Error launching phone call: $e");
    }
  }

  Future<void> _generateWarning(BuildContext context, User user) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF en cours...')));
      await PdfGeneratorService().generateWarningLetter(
         residentName: user.name,
         debtAmount: user.balance.abs(),
         delayDays: 15,
         apartmentNumber: user.apartmentNumber.toString(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF généré avec succès !'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur PDF: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _generateReceipt(BuildContext context, User user, double amount, int txId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du Reçu en cours...')));
      await PdfGeneratorService().generateReceipt(
        transactionId: txId,
        residentName: user.name,
        lotNumber: user.apartmentNumber ?? 0,
        amount: amount,
        mode: "Virement",
        period: "Mars 2024", // Ideally passed from DB
        oldBalance: user.balance - amount, // Simplified logic
        newBalance: user.balance,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçu généré avec succès !'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur Reçu: $e'), backgroundColor: Colors.red));
      }
    }
  }

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
        stream: (db.select(db.users)..where((t) => t.id.equals(userId))).watchSingleOrNull(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final user = snapshot.data;
          if (user == null) return const Center(child: Text("Utilisateur introuvable", style: TextStyle(color: Colors.red)));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                LuxuryCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: AppTheme.gold, child: Icon(Icons.person, color: AppTheme.darkNavy)),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("Appartement ${user.apartmentNumber}", style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7))),
                              if (user.phoneNumber != null)
                                Text(user.phoneNumber!, style: TextStyle(color: AppTheme.offWhite.withOpacity(0.5), fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Text("${user.balance.toStringAsFixed(2)} DH", style: TextStyle(color: user.balance < 0 ? AppTheme.errorRed : const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(user.phoneNumber),
                            icon: const Icon(Icons.phone, color: AppTheme.darkNavy),
                            label: const Text("APPELER", style: TextStyle(color: AppTheme.darkNavy)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _generateWarning(context, user),
                            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.gold),
                            label: const Text("RELANCE", style: TextStyle(color: AppTheme.gold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkNavy,
                              side: const BorderSide(color: AppTheme.gold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("HISTORIQUE DES TRANSACTIONS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Real Transaction List
                Expanded(
                  child: StreamBuilder<List<Transaction>>(
                    stream: (db.select(db.transactions)..where((t) => t.userId.equals(userId))).watch(),
                    builder: (context, txSnapshot) {
                      if (txSnapshot.hasError) return Text("Erreur: ${txSnapshot.error}", style: const TextStyle(color: Colors.red));
                      if (!txSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final transactions = txSnapshot.data!;
                      if (transactions.isEmpty) return const Center(child: Text("Aucune transaction.", style: TextStyle(color: Colors.grey)));

                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isCredit = tx.type == 'income';

                          return _buildTransactionTile(
                            context,
                            user,
                            "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                            tx.amount,
                            tx.description,
                            isCredit,
                            tx.id
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, User user, String date, double amount, String desc, bool isCredit, int txId) {
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
            Text("${isCredit ? '+' : '-'}$amount DH", style: TextStyle(color: isCredit ? const Color(0xFF00E5FF) : AppTheme.errorRed, fontWeight: FontWeight.bold)),
            if (isCredit)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: AppTheme.gold),
                onPressed: () => _generateReceipt(context, user, amount, txId),
              ),
          ],
        ),
      ),
    );
  }
}
