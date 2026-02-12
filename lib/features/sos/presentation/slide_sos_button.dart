import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';

class SecureSosButton extends StatefulWidget {
  final String residentName;

  const SecureSosButton({super.key, required this.residentName});

  @override
  State<SecureSosButton> createState() => _SecureSosButtonState();
}

class _SecureSosButtonState extends State<SecureSosButton> {
  bool _isUnlocked = false;
  double _dragValue = 0.0;
  final double _width = 300.0;
  final double _height = 60.0;

  Future<void> _triggerSos() async {
    // 1. VIBRATION (Haptic Feedback)
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();

    // 2. LOCATION
    String locationString = "Localisation inconnue";

    // Check permissions
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        locationString = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      } catch (e) {
        // Fallback or error handling
        locationString = "Erreur GPS: ${e.toString()}";
      }
    } else {
       locationString = "Permission GPS refusée";
    }

    // 3. WHATSAPP
    final message = Uri.encodeComponent(
      "SOS - URGENCE - ${widget.residentName}\n\n"
      "J'ai besoin d'aide immédiate !\n"
      "Localisation: $locationString"
    );

    // Replace with actual Syndic/Emergency number
    final whatsappUrl = Uri.parse("https://wa.me/212600000000?text=$message");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir WhatsApp")),
        );
      }
    }

    // Reset after action
    setState(() {
      _isUnlocked = false;
      _dragValue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return GestureDetector(
        onTap: _triggerSos,
        child: Container(
          width: _width,
          height: _height * 1.5,
          decoration: BoxDecoration(
            color: AppTheme.errorRed,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorRed.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                "APPUYER POUR ALERTE",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "GLISSER POUR DÉVERROUILLER",
              style: TextStyle(
                color: AppTheme.errorRed.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Positioned(
            left: _dragValue,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragValue += details.delta.dx;
                  if (_dragValue < 0) _dragValue = 0;
                  if (_dragValue > _width - _height) _dragValue = _width - _height;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragValue > (_width - _height) * 0.9) {
                  setState(() {
                    _isUnlocked = true;
                  });
                  HapticFeedback.mediumImpact();
                } else {
                  setState(() => _dragValue = 0);
                }
              },
              child: Container(
                width: _height,
                height: _height,
                decoration: const BoxDecoration(
                  color: AppTheme.errorRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_open, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
