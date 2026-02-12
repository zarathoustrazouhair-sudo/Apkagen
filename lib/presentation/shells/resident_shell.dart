import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/blog/presentation/blog_feed_screen.dart';

class ResidentShell extends ConsumerStatefulWidget {
  const ResidentShell({super.key});

  @override
  ConsumerState<ResidentShell> createState() => _ResidentShellState();
}

class _ResidentShellState extends ConsumerState<ResidentShell> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MyApartmentScreen(),
    const BlogFeedScreen(),
    const Center(child: Text("Documents", style: TextStyle(color: AppTheme.gold))),
    const Center(child: Text("Profile", style: TextStyle(color: AppTheme.gold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.darkNavy,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'MON APPART',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'ACTUALITÉS',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              activeIcon: Icon(Icons.folder),
              label: 'DOCS',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }
}

class MyApartmentScreen extends StatelessWidget {
  const MyApartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          'MON APPARTEMENT',
          style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            const Text(
              "Bonjour, M. Amrani",
              style: TextStyle(
                color: AppTheme.offWhite,
                fontSize: 24,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 24),

            // Balance Card
            LuxuryCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SOLDE ACTUEL",
                        style: TextStyle(
                          color: AppTheme.offWhite.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "0.00 DH",
                        style: TextStyle(
                          color: const Color(0xFF00E5FF), // Cyan for OK
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SOS Button (Slide Action Placeholder)
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.5)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sos, color: AppTheme.errorRed),
                    const SizedBox(width: 8),
                    Text(
                      "SOS URGENCES",
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 32),

             // Recent Blog Posts Preview (Header)
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   "DERNIÈRES ACTUALITÉS",
                   style: TextStyle(
                     color: AppTheme.offWhite.withOpacity(0.8),
                     fontSize: 14,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 TextButton(
                   onPressed: () {},
                   child: const Text("Voir tout", style: TextStyle(color: AppTheme.gold)),
                 ),
               ],
             ),
             // Note: In a real app, we'd list a few items here.
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Report Incident
        },
        backgroundColor: AppTheme.gold,
        label: const Text("SIGNALER INCIDENT", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.build, color: AppTheme.darkNavy),
      ),
    );
  }
}
