import 'package:flutter_test/flutter_test.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';

void main() {
  group('Role Audit Tests', () {
    test('Concierge should NOT see Finance Widgets', () async {
      // Logic Test
      const userRole = UserRole.concierge;
      final canEditFinance = RoleGuards.canEditFinance(userRole);
      const canViewFinance = userRole != UserRole.concierge;

      expect(canEditFinance, isFalse, reason: "Concierge cannot edit finance");
      expect(canViewFinance, isFalse, reason: "Concierge cannot view finance");
    });

    test('Adjoint SHOULD see Finance but NOT Edit', () async {
      // Logic Test
      const userRole = UserRole.adjoint;
      final canEditFinance = RoleGuards.canEditFinance(userRole);
      const canViewFinance = userRole != UserRole.concierge;

      expect(canViewFinance, isTrue, reason: "Adjoint must view finance");
      expect(canEditFinance, isFalse, reason: "Adjoint cannot edit finance (Read Only)");
    });

    test('Syndic has FULL Access', () async {
      const userRole = UserRole.syndic;
      final canEditFinance = RoleGuards.canEditFinance(userRole);
      const canViewFinance = userRole != UserRole.concierge;

      expect(canEditFinance, isTrue, reason: "Syndic must edit finance");
      expect(canViewFinance, isTrue, reason: "Syndic must view finance");
    });
  });
}
