import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_screen.dart';
import 'package:residence_lamandier_b/features/auth/presentation/login_screen.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/presentation/shells/concierge_shell.dart';
import 'package:residence_lamandier_b/presentation/shells/resident_shell.dart';
import 'package:residence_lamandier_b/presentation/shells/syndic_shell.dart';
import 'package:residence_lamandier_b/features/auth/presentation/blocked_user_screen.dart';
import 'package:residence_lamandier_b/features/residents/presentation/resident_detail_screen.dart';
import 'package:residence_lamandier_b/features/finance/presentation/finance_screen.dart';
import 'package:residence_lamandier_b/features/finance/presentation/add_transaction_screen.dart';

// Role Provider
// In production, this would come from a secure Auth State (e.g., Supabase Auth + Local DB)
final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.syndic);
final isBlockedProvider = StateProvider<bool>((ref) => false); // Mock blocked state

final appRouterProvider = Provider<GoRouter>((ref) {
  final role = ref.watch(userRoleProvider);
  final isBlocked = ref.watch(isBlockedProvider);
  final settingsRepo = ref.watch(appSettingsRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
       // Global Block Check
       if (isBlocked) return '/blocked';

       // On Root access, determine flow
       if (state.uri.toString() == '/') {
         final isSetup = await settingsRepo.isSetupCompleted();
         if (!isSetup) {
           return '/wizard';
         } else {
           return '/login';
         }
       }
       return null;
    },
    routes: [
      GoRoute(
        path: '/blocked',
        builder: (context, state) => const BlockedUserScreen(),
      ),
      GoRoute(
        path: '/wizard',
        builder: (context, state) => const WizardScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/syndic',
        builder: (context, state) {
          // GUARD: Strict Access Control
          if (role != UserRole.syndic && role != UserRole.adjoint) {
             // If navigating manually, redirect to login if role lost
             return const LoginScreen();
          }
          return const SyndicShell();
        },
      ),
      GoRoute(
        path: '/resident',
        builder: (context, state) {
          // GUARD: Strict Access Control
          if (role != UserRole.resident && role != UserRole.syndic) {
             return const LoginScreen();
          }
          return const ResidentShell();
        },
      ),
      GoRoute(
        path: '/concierge',
        builder: (context, state) {
          if (role != UserRole.concierge && role != UserRole.syndic) {
             return const LoginScreen();
          }
          return const ConciergeShell();
        },
      ),
      GoRoute(
        name: 'resident_detail',
        path: '/resident_detail/:id',
        builder: (context, state) {
           final id = int.parse(state.pathParameters['id']!);
           return ResidentDetailScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddTransactionScreen(),
          ),
        ],
      ),
    ],
  );
});
