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

            // Use real balance if available
            final bool isDebt = resident != null ? resident.balance < 0 : false;

            final Color borderColor = isDebt ? const Color(0xFFFF0040) : const Color(0xFF00E5FF);
            final Color bgColor = resident != null ? AppTheme.darkNavy : Colors.grey.withOpacity(0.1);

            return GestureDetector(
              onTap: () {
                if (resident != null) {
                  context.pushNamed('resident_detail', pathParameters: {'id': resident.id.toString()});
                } else {
                  // Fallback for empty apartments (should be covered by seeding)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Appartement $apartmentNumber : Aucun résident assigné'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AP$apartmentNumber',
                        style: const TextStyle(
                          color: AppTheme.offWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (resident != null)
                        Text(
                          resident.balance < 0 ? 'Dette' : 'OK',
                          style: TextStyle(
                            color: isDebt ? const Color(0xFFFF0040) : Colors.green,
                            fontSize: 8,
                          ),
                        ),
                    ],
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
