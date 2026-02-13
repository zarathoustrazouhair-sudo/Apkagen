# AUDIT_TECHNIQUE_SYNDIC_V1

**DATE:** 2024-05-22
**AUDITEUR:** Jules (AI Assistant)
**CONTEXTE:** PROJET FLUTTER (Dart/Riverpod/Drift) - `residence_lamandier_b`
**STATUT:** CRITIQUE

---

## SECTION 1 : ARBORESCENCE & FICHIERS

**NOTE:** Le projet est une application Flutter. L'analyse porte sur le répertoire `lib/` (équivalent `src/main/java`).

### ARBORESCENCE PRINCIPALE (`lib/`)

```text
lib/
├── core/
│   ├── router/ (AppRouter, Guards)
│   ├── theme/ (LuxuryTheme, Palettes, Widgets)
│   ├── network/ (SupabaseConfig)
│   └── services/ (PdfGeneratorService)
├── data/
│   └── local/ (AppDatabase - Drift/SQLite)
├── features/
│   ├── admin/
│   │   └── presentation/ (UserManagementScreen)
│   ├── auth/
│   │   ├── data/ (AuthRepository)
│   │   └── presentation/ (LoginScreen, BlockedUserScreen)
│   ├── blog/
│   │   ├── data/ (BlogRepository)
│   │   └── presentation/ (BlogFeedScreen, CreatePostScreen, PostDetailScreen)
│   ├── dashboard/
│   │   └── presentation/ (CockpitScreen, Widgets: ApartmentGrid, ActiveWidgets)
│   ├── finance/
│   │   ├── data/ (FinanceProvider - Logic)
│   │   └── presentation/ (FinanceScreen, AddTransactionScreen)
│   ├── onboarding/
│   │   └── presentation/ (WizardScreen)
│   ├── residents/
│   │   ├── data/ (ResidentsProvider)
│   │   └── presentation/ (ResidentDetailScreen)
│   ├── settings/
│   │   └── data/ (AppSettingsRepository)
│   └── tasks/ (TaskEntity)
└── presentation/
    └── shells/ (SyndicShell, ResidentShell, ConciergeShell)
```

### FICHIERS "LAYOUTS" (WIDGETS UI)
*Les fichiers suivants définissent l'interface utilisateur. Tous sont connectés au Router ou utilisés comme composants.*

- `lib/features/auth/presentation/login_screen.dart` [UTILISÉ]
- `lib/features/dashboard/presentation/cockpit_screen.dart` [UTILISÉ]
- `lib/features/residents/presentation/resident_detail_screen.dart` [UTILISÉ]
- `lib/features/finance/presentation/finance_screen.dart` [UTILISÉ]
- `lib/features/blog/presentation/blog_feed_screen.dart` [UTILISÉ]
- `lib/features/admin/presentation/user_management_screen.dart` [UTILISÉ]
- `lib/features/onboarding/presentation/wizard_screen.dart` [UTILISÉ - Entry Point]

---

## SECTION 2 : ANALYSE DES FLUX DE DONNÉES (WIRING CHECK)

| ÉCRAN (UI) | VIEWMODEL / PROVIDER | REPOSITORY | DATABASE (DAO) | STATUT |
| :--- | :--- | :--- | :--- | :--- |
| **CockpitScreen** | `residentsProvider`, `db.transactions` (Stream) | DIRECT DB ACCESS | `Users`, `Transactions` | **[WIRED]** (Attention: Accès direct DB dans UI) |
| **LoginScreen** | `appSettingsRepositoryProvider`, `db.users` | `AppSettingsRepository` | `Users` (Drift) | **[WIRED]** |
| **ResidentDetail** | `db.users`, `db.transactions` (Stream) | DIRECT DB ACCESS | `Users`, `Transactions` | **[WIRED]** |
| **FinanceScreen** | `transactionsProvider` | `FinanceProvider` | `Transactions` | **[WIRED]** |
| **BlogFeed** | `blogPostsProvider` | `BlogRepository` | Supabase SDK | **[WIRED]** |
| **UserManagement** | `db.users` (Stream) | DIRECT DB ACCESS | `Users` | **[WIRED]** |

**OBSERVATIONS:**
- **ALERTE ARCHITECTURE:** Trop d'accès directs à `AppDatabase` dans les Widgets (`CockpitActiveWidgets`, `UserManagementScreen`). Cela viole la séparation des couches (MVVM/Repository Pattern). Le Repository est souvent contourné.
- **PAS DE [CRITICAL FAKE]**: Toutes les données proviennent de la base SQLite locale ou de Supabase.

---

## SECTION 3 : DÉTECTION D'ORPHELINS & CODE MORT

### FICHIERS / LOGIQUE SUSPECTS
1.  **Orphelins (Unused Imports):** `flutter analyze` rapporte **133 avertissements**, majoritairement des imports inutilisés (`unused_import`) et du code déprécié (`withOpacity`).
    - *Exemple:* `lib/features/tasks/presentation/tasks_viewmodel.dart` importe `TaskEntity` mais ne semble pas l'utiliser efficacement.
2.  **Code Mort Potentiel (Logique non testée):**
    - `lib/features/incidents/data/incident_repository.dart` : Existe mais aucune UI "IncidentScreen" dédiée n'a été détectée dans le flux principal (intégré dans Cockpit ?).
    - `lib/features/sos/presentation/slide_sos_button.dart` : Semble être un composant isolé. Est-il utilisé ?

### FONCTIONS "TODO"
- Pas de `TODO` critiques détectés explicitement via scan rapide, mais la qualité du code suggère de nombreuses implémentations "MVP" (ex: PIN "0000" hardcodé dans `LoginScreen`).

---

## SECTION 4 : PERFORMANCE & DATABASE (HARD TEST)

### ANALYSE DES INDEX (DRIFT / SQLITE)
- **Table `Users`:** Index sur `id` (PK). **Manque d'index sur `role`**.
    - *Conséquence:* Les filtres "RÉSIDENT" font un **Full Table Scan**.
- **Table `Transactions`:** Index sur `id` (PK). **Manque d'index sur `userId`**.
    - *Conséquence:* L'écran `ResidentDetail` fait un **Full Table Scan** sur la table Transactions pour chaque résident affiché.
    - **VERDICT:** [FAIL] - Performance dégradera rapidement avec >1000 transactions.

### CALCULS FINANCIERS (CRITIQUE)
- **Localisation:** `lib/features/finance/data/finance_provider.dart`
- **Méthode:** `totalBalanceProvider`
- **Problème:**
  ```dart
  // CAUCHEMAR DE PERFORMANCE
  return transactionsAsync.whenData((transactions) {
    // ... loop over ALL transactions in memory ...
  });
  ```
- **Analyse:** Charge l'INTÉGRALITÉ de la table `transactions` en mémoire RAM Dart pour calculer une somme simple.
- **Correction Requise:** Utiliser une requête SQL `SELECT SUM(amount) FROM transactions`.
- **VERDICT:** [CRITICAL FAIL]

---

## SECTION 5 : RAPPORT DE TESTS (UNITAIRES & INTÉGRATION)

### RÉSULTAT DU RUN (`flutter test`)
- **Tests Trouvés:** 1 fichier (`test/core/theme/widgets/financial_mood_icon_test.dart`)
- **Tests Passés:** 1/1
- **Tests Manquants:** TOUT LE RESTE.

### DÉTAIL DES MANQUES [MISSING TESTS]
- **[MISSING]** `LoginScreen` / `AuthRepository` : Aucune vérification de sécurité.
- **[MISSING]** `FinanceProvider` : Calculs financiers non testés (risque d'erreur comptable).
- **[MISSING]** `PdfGeneratorService` : Pas de test de génération.
- **[MISSING]** `Integration` : Aucun test de flux complet.

**VERDICT GLOBAL:** Le projet est fonctionnel mais fragile. La couverture de test est de **~1%**.
