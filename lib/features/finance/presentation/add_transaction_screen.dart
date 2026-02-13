import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/services/pdf_generator_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController(text: "250");
  final _descriptionController = TextEditingController(text: "Cotisation Mensuelle");
  User? _selectedUser;
  String _selectedMode = "Espèces";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("NOUVEAU PAIEMENT", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Dropdown
                  StreamBuilder<List<User>>(
                    stream: (db.select(db.users)..where((t) => t.role.equals('resident'))).watch(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      return DropdownButtonFormField<User>(
                        dropdownColor: AppTheme.darkNavy,
                        value: _selectedUser,
                        items: snapshot.data!.map((user) {
                          return DropdownMenuItem(
                            value: user,
                            child: Text("${user.name} (Apt ${user.apartmentNumber})", style: const TextStyle(color: AppTheme.offWhite)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedUser = val),
                        decoration: const InputDecoration(labelText: "RÉSIDENT"),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    label: "MONTANT (DH)",
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                   const SizedBox(height: 16),
                  LuxuryTextField(
                    label: "DESCRIPTION",
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppTheme.darkNavy,
                    value: _selectedMode,
                    items: ["Espèces", "Chèque", "Virement"].map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode, style: const TextStyle(color: AppTheme.offWhite)));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMode = val!),
                    decoration: const InputDecoration(labelText: "MODE DE PAIEMENT"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LuxuryButton(
              label: "VALIDER & IMPRIMER",
              icon: Icons.print,
              isLoading: _isLoading,
              onPressed: () => _processTransaction(db),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processTransaction(AppDatabase db) async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un résident.')));
      return;
    }

    final amountInput = double.tryParse(_amountController.text);
    if (amountInput == null || amountInput <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un montant valide.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final txData = await db.transaction<Map<String, dynamic>>(() async {
        // 1. Re-fetch user to get latest balance (Defensive)
        final freshUser = await (db.select(db.users)..where((t) => t.id.equals(_selectedUser!.id))).getSingle();
        final currentBalance = freshUser.balance;
        final newBalance = currentBalance + amountInput; // Adding credit reduces debt or increases positive balance

        // 2. Insert Transaction Record
        final txId = await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            amount: amountInput,
            date: DateTime.now(),
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : "Paiement",
            userId: drift.Value(freshUser.id),
            type: 'income',
          ),
        );

        // 3. Update User Balance (Atomic Update)
        await (db.update(db.users)..where((t) => t.id.equals(freshUser.id))).write(
          UsersCompanion(balance: drift.Value(newBalance)),
        );

        return {
          'txId': txId,
          'oldBalance': currentBalance,
          'newBalance': newBalance,
          'user': freshUser,
        };
      });

      if (mounted) {
        _showSuccessDialog(
          amountInput,
          txData['newBalance'],
          txData['txId'],
          txData['oldBalance'],
          txData['user']
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur Critique Transaction: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(double amount, double newBalance, int txId, double oldBalance, User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        title: const Text("Paiement Enregistré", style: TextStyle(color: AppTheme.gold)),
        content: const Text("La transaction a été sécurisée et enregistrée avec succès.", style: TextStyle(color: AppTheme.offWhite)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("FERMER", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
            icon: const Icon(Icons.print, color: AppTheme.darkNavy),
            label: const Text("IMPRIMER REÇU", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
            onPressed: () {
              // Generate PDF
              PdfGeneratorService().generateReceipt(
                transactionId: txId,
                residentName: user.name,
                lotNumber: user.apartmentNumber ?? 0,
                amount: amount,
                mode: _selectedMode,
                period: "${DateTime.now().month}/${DateTime.now().year}",
                oldBalance: oldBalance,
                newBalance: newBalance,
              );
            },
          ),
        ],
      ),
    );
  }
}
