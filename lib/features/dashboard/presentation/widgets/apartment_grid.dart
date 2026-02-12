import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/features/residents/data/residents_provider.dart';

class ApartmentGrid extends ConsumerWidget {
  const ApartmentGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsyncValue = ref.watch(residentsProvider);

    return residentsAsyncValue.when(
      data: (residents) {
        // Map apartment number to resident
        final residentMap = {
          for (var r in residents) r.apartmentNumber: r
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            final apartmentNumber = index + 1;
            final resident = residentMap[apartmentNumber];

            // Use real data if available, assuming balance field exists on User
            final bool isDebt;
            if (resident != null) {
               isDebt = (resident.balance) < 0;
            } else {
               isDebt = apartmentNumber % 2 == 0;
            }

            final Color borderColor = isDebt ? const Color(0xFFFF0040) : const Color(0xFF00E5FF);

            return GestureDetector(
              onTap: () {
                if (resident != null) {
                  context.pushNamed('resident_detail', pathParameters: {'id': resident.id.toString()});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No resident found for Apartment $apartmentNumber')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor.withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'AP$apartmentNumber',
                    style: const TextStyle(
                      color: AppTheme.offWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }
}
