import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';

class ConciergeShell extends StatelessWidget {
  const ConciergeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          'ESPACE CONCIERGE',
          style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Summary
            LuxuryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "TÂCHES DU JOUR",
                    style: TextStyle(color: AppTheme.offWhite.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "3",
                    style: TextStyle(color: AppTheme.gold, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "LISTE DES TÂCHES",
              style: TextStyle(color: AppTheme.offWhite.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Mock Task List
            _buildTaskItem("Arroser les plantes du hall", true),
            _buildTaskItem("Réception colis Apt 5", false),
            _buildTaskItem("Vérifier lumière escalier B", false),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LuxuryCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? const Color(0xFF00E5FF) : AppTheme.gold,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isCompleted ? AppTheme.offWhite.withOpacity(0.5) : AppTheme.offWhite,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
