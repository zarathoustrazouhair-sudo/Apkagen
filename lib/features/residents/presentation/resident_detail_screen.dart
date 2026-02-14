import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/services/pdf_generator_service.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';

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

  Future<void> _sendWhatsApp(String? phoneNumber, String residentName, double balance) async {
      if (phoneNumber == null || phoneNumber.isEmpty) return;
      // Format number (assume 06... -> 2126...)
      // Simple logic for now
      String formatted = phoneNumber.replaceAll(' ', '');
      if (formatted.startsWith('0')) {
        formatted = '212${formatted.substring(1)}';
      }

      final message = "Bonjour $residentName, sauf erreur, vous devez ${balance.abs()} DH à la résidence L'Amandier B.";
      final url = "https://wa.me/$formatted?text=${Uri.encodeComponent(message)}";
      final uri = Uri.parse(url);

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
           debugPrint("Could not launch WhatsApp");
        }
      } catch(e) {
         debugPrint("Error WhatsApp: $e");
      }
  }

  Future<void> _generateWarning(BuildContext context, PdfGeneratorService pdfService, User user) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF en cours...')));
      await pdfService.generateWarningLetter(
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

  Future<void> _generateReceipt(BuildContext context, PdfGeneratorService pdfService, User user, double amount, int txId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du Reçu en cours...')));
      await pdfService.generateReceipt(
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

  void _showEditDialog(BuildContext context, WidgetRef ref, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    // Add Email if schema supports it, for now Name/Phone

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        title: const Text("Modifier Résident", style: TextStyle(color: AppTheme.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LuxuryTextField(label: "Nom Complet", controller: nameCtrl),
            const SizedBox(height: 16),
            LuxuryTextField(label: "Téléphone", controller: phoneCtrl, keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
            onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
                UsersCompanion(
                  name: drift.Value(nameCtrl.text),
                  phoneNumber: drift.Value(phoneCtrl.text),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              // StreamBuilder handles refresh automatically
            },
            child: const Text("ENREGISTRER", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final settingsRepo = ref.watch(appSettingsRepositoryProvider);
    final pdfService = PdfGeneratorService(settingsRepo);
    final userRole = ref.watch(userRoleProvider);
    final isSyndic = userRole == UserRole.syndic;

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("DÉTAIL RÉSIDENT", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (isSyndic)
            // Ideally we pass the user object, but here we are in build context where user is async.
            // We can only show the button, logic needs user data.
            // We'll handle it inside the StreamBuilder or use a state variable if we want it in AppBar.
            // Better: Put the edit button inside the body or next to the name card.
            // Let's put a placeholder here that is disabled until data loads?
            // Or simpler: put it in the LuxuryCard below.
            const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            context.push('/finance/add');
        },
        backgroundColor: AppTheme.gold,
        icon: const Icon(Icons.add, color: AppTheme.darkNavy),
        label: const Text("ENCAISSEMENT", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<User?>(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(user.name, style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 18))),
                                    if (isSyndic)
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppTheme.gold, size: 20),
                                        onPressed: () => _showEditDialog(context, ref, user),
                                      ),
                                  ],
                                ),
                                Text("Appartement ${user.apartmentNumber}", style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7))),
                                if (user.phoneNumber != null)
                                  Text(user.phoneNumber!, style: TextStyle(color: AppTheme.offWhite.withOpacity(0.5), fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("${user.balance.toStringAsFixed(2)} DH", style: TextStyle(color: user.balance < 0 ? AppTheme.errorRed : const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons Row
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(user.phoneNumber),
                            icon: const Icon(Icons.phone, color: AppTheme.darkNavy, size: 18),
                            label: const Text("APPELER", style: TextStyle(color: AppTheme.darkNavy)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
                          ),
                           ElevatedButton.icon(
                            onPressed: () => _sendWhatsApp(user.phoneNumber, user.name, user.balance),
                            icon: const Icon(Icons.chat, color: Colors.white, size: 18), // WhatsAppish
                            label: const Text("WHATSAPP", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _generateWarning(context, pdfService, user),
                            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.gold, size: 18),
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
                            pdfService,
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

  Widget _buildTransactionTile(BuildContext context, PdfGeneratorService pdfService, User user, String date, double amount, String desc, bool isCredit, int txId) {
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
                onPressed: () => _generateReceipt(context, pdfService, user, amount, txId),
              ),
          ],
        ),
      ),
    );
  }
}
