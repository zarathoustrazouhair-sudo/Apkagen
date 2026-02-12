import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';

class BlockedUserScreen extends StatelessWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Stark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: AppTheme.errorRed),
              const SizedBox(height: 24),
              Text(
                "ACCÈS RESTREINT",
                style: AppTheme.luxuryTheme.textTheme.displayMedium?.copyWith(
                  color: AppTheme.errorRed,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Votre accès à l'application a été suspendu par le Syndic.",
                style: TextStyle(color: AppTheme.offWhite, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LuxuryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      "MONTANT DÛ",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "2,500.00 DH", // Mock value, in real app pass as arg
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 32),
                    const Text(
                      "RIB POUR RÉGULARISATION",
                      style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(
                      "123 456 78901234567890 12",
                      style: TextStyle(
                        color: AppTheme.offWhite,
                        fontFamily: 'Courier',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
