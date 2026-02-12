import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';

class AppParametersScreen extends ConsumerStatefulWidget {
  const AppParametersScreen({super.key});

  @override
  ConsumerState<AppParametersScreen> createState() => _AppParametersScreenState();
}

class _AppParametersScreenState extends ConsumerState<AppParametersScreen> {
  late TextEditingController _feeController;
  late TextEditingController _syndicNameController;

  @override
  void initState() {
    super.initState();
    _feeController = TextEditingController();
    _syndicNameController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final fee = await repo.getSetting('monthly_fee');
    final name = await repo.getSetting('syndic_name');

    if (mounted) {
      setState(() {
        _feeController.text = fee ?? '250.0';
        _syndicNameController.text = name ?? 'Syndic';
      });
    }
  }

  Future<void> _saveSettings() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.saveSetting('monthly_fee', _feeController.text);
    await repo.saveSetting('syndic_name', _syndicNameController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres sauvegardés')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          "PARAMÈTRES RÉSIDENCE",
          style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.gold,
            fontSize: 18,
          ),
        ),
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
                  LuxuryTextField(
                    label: "COTISATION MENSUELLE (DH)",
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  LuxuryTextField(
                    label: "NOM DU SYNDIC",
                    controller: _syndicNameController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LuxuryButton(
              label: "SAUVEGARDER CONFIGURATION",
              onPressed: _saveSettings,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}
