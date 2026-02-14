import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

class PdfGeneratorService {
  final AppSettingsRepository _settingsRepo;
  final String _residenceName = "Résidence L'Amandier B";
  final String _syndicName = "M. Abdelati KENBOUCHI";

  PdfGeneratorService(this._settingsRepo);

  // New Feature: Hall State Sheet (A4 Landscape)
  Future<void> generateHallState(List<User> users, DateTime month) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";
    final monthStr = "${month.month}/${month.year}";

    final cachetPath = await _settingsRepo.getSetting('cachet_path');
    pw.MemoryImage? cachetImage;
    if (cachetPath != null && File(cachetPath).existsSync()) {
      cachetImage = pw.MemoryImage(File(cachetPath).readAsBytesSync());
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          double totalDebt = 0.0;
          for (var u in users) {
            if (u.balance < 0) totalDebt += u.balance.abs();
          }

          return pw.Column(
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(_residenceName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text("SITUATION AU $dateStr", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text("ÉTAT DES COTISATIONS - PÉRIODE $monthStr", style: pw.TextStyle(fontSize: 16, decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 20),

              // Table
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Appartement', 'Propriétaire', 'Statut', 'Solde (DH)'],
                data: users.map((u) {
                  final isDebt = u.balance < 0;
                  final status = isDebt ? 'IMPAYÉ' : 'PAYÉ';
                  // Note: PdfColors doesn't support withValues/opacity easily in logic, sticking to core colors

                  return [
                    "AP ${u.apartmentNumber ?? '-'}",
                    u.name,
                    status,
                    u.balance.toStringAsFixed(2),
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // Footer: Total & Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.red, width: 2),
                      color: PdfColors.red50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("TOTAL À RECOUVRER", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                        pw.Text("${totalDebt.toStringAsFixed(2)} DH", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                      ],
                    ),
                  ),
                  pw.Column(
                    children: [
                      pw.Text("Le Syndic", style: const pw.TextStyle(fontSize: 12)),
                      if (cachetImage != null)
                        pw.Container(width: 80, height: 80, child: pw.Image(cachetImage))
                      else
                        pw.SizedBox(height: 50),
                      pw.Text(_syndicName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save(), name: "Etat_Cotisations_$monthStr.pdf");
  }

  // REDESIGNED RECEIPT (Section 5)
  Future<void> generateReceipt({
    required int transactionId,
    required String residentName,
    required int lotNumber,
    required double amount,
    required String mode,
    required String period,
    required double oldBalance,
    required double newBalance,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";

    final cachetPath = await _settingsRepo.getSetting('cachet_path');
    pw.MemoryImage? cachetImage;
    if (cachetPath != null && File(cachetPath).existsSync()) {
      cachetImage = pw.MemoryImage(File(cachetPath).readAsBytesSync());
    }

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(_residenceName.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.SizedBox(height: 10),
              pw.Text("QUITTANCE DE PAIEMENT", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              pw.Text("N° R-$transactionId", style: const pw.TextStyle(fontSize: 12, color: PdfColors.red)),
              pw.SizedBox(height: 20),

              // Date Row
              pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Casablanca, le $dateStr")),
              pw.SizedBox(height: 20),

              // Main Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black),
                children: [
                  pw.TableRow(children: [
                    _tableCell("Reçu de :", isHeader: true),
                    _tableCell("$residentName (Appartement $lotNumber)"),
                  ]),
                  pw.TableRow(children: [
                    _tableCell("Somme de :", isHeader: true),
                    _tableCell("${amount.toStringAsFixed(2)} DH"),
                  ]),
                  pw.TableRow(children: [
                    _tableCell("Mode de règlement :", isHeader: true),
                    _tableCell(mode),
                  ]),
                  pw.TableRow(children: [
                    _tableCell("Motif :", isHeader: true),
                    _tableCell("Cotisation / Charge - Période: $period"),
                  ]),
                ]
              ),

              pw.SizedBox(height: 20),

              // Balance Info
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey200,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Ancien Solde: $oldBalance DH"),
                    pw.Text("Nouveau Solde: $newBalance DH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Pour le Syndic,", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                      if (cachetImage != null)
                         pw.Container(width: 60, height: 60, child: pw.Image(cachetImage))
                      else
                         pw.SizedBox(height: 40),
                      pw.Text(_syndicName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Visa", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text("Généré par L'Amandier App", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            ],
          ),
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (format) => doc.save(), name: "Quittance_$transactionId.pdf");
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)
      ),
    );
  }

  // Legacy (preserved for compatibility if called elsewhere)
  Future<void> generateWarningLetter({
    required String residentName,
    required double debtAmount,
    required int delayDays,
    String? apartmentNumber,
  }) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";

    final cachetPath = await _settingsRepo.getSetting('cachet_path');
    pw.MemoryImage? cachetImage;
    if (cachetPath != null && File(cachetPath).existsSync()) {
      cachetImage = pw.MemoryImage(File(cachetPath).readAsBytesSync());
    }

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader("MISE EN DEMEURE (Loi 18-00)"),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Casablanca, le $dateStr", style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.SizedBox(height: 20),
            pw.Text("M./Mme $residentName", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            if (apartmentNumber != null)
              pw.Text("Appartement N° $apartmentNumber", style: const pw.TextStyle(fontSize: 10)),

            pw.SizedBox(height: 20),
            pw.Text("Objet : Relance pour impayés", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline, fontSize: 12)),
            pw.SizedBox(height: 10),

            pw.Paragraph(
              text: "Sauf erreur, nous constatons un impayé de :",
              style: const pw.TextStyle(fontSize: 10),
            ),
             pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "${debtAmount.toStringAsFixed(2)} DH",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red900
                )
              ),
            ),
            pw.SizedBox(height: 5),

            pw.Paragraph(
              text: "Nous vous mettons en demeure de régulariser sous $delayDays jours. Sinon, le dossier sera transmis à notre avocat pour recouvrement judiciaire.",
              style: const pw.TextStyle(fontSize: 10),
            ),

            pw.SizedBox(height: 30),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Le Syndic", style: const pw.TextStyle(fontSize: 10)),
                  if (cachetImage != null)
                     pw.Container(
                       width: 80,
                       height: 80,
                       child: pw.Image(cachetImage),
                     )
                  else
                     pw.SizedBox(height: 40),
                  pw.Text(_syndicName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),

            pw.Spacer(),
            pw.Divider(),
            pw.Center(child: pw.Text(_residenceName, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: "Mise_en_demeure_$residentName.pdf",
    );
  }

  pw.Widget _buildHeader(String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(_residenceName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
          ],
        ),
      ],
    );
  }
}
