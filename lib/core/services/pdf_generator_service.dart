import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';

class PdfGeneratorService {
  final AppSettingsRepository _settingsRepo;
  final String _residenceName = "Résidence L'Amandier B";
  final String _syndicName = "M. Abdelati KENBOUCHI";

  PdfGeneratorService(this._settingsRepo);

  Future<void> generateFinancialReport(List<dynamic> users, List<dynamic> transactions, double monthlyFee) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Keep landscape A4 for tables
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader("RAPPORT FINANCIER GLOBAL"),
              pw.SizedBox(height: 20),

              // TABLE
              pw.TableHelper.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
                cellAlignment: pw.Alignment.centerLeft,
                headers: <String>['Appartement', 'Résident', 'Solde (DH)', 'Statut'],
                data: users.map((user) {
                  // user is expected to be a Drift Row or similar
                  final balance = (user.balance as num).toDouble();
                  final status = balance < 0 ? 'EN RETARD' : 'À JOUR';

                  return [
                    user.apartmentNumber?.toString() ?? '-',
                    user.name,
                    balance.toStringAsFixed(2),
                    status
                  ];
                }).toList(),
              ),

              // FOOTER
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Généré par le système Amandier B - God Mode"),
                  pw.Text("Total Trésorerie: ${users.fold(0.0, (sum, u) => sum + (u.balance as num)).toStringAsFixed(2)} DH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // FINANCE_RECU
  Future<void> generateReceipt({
    required int transactionId,
    required String residentName,
    required int lotNumber,
    required double amount,
    required String mode, // Chèque/Espèces
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
      pageFormat: PdfPageFormat.a5, // A5 Format as requested
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader("REÇU DE PAIEMENT N° $transactionId"),
            pw.SizedBox(height: 20),
            _buildInfoRow("DATE", dateStr),
            _buildInfoRow("SYNDIC", _syndicName),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _buildInfoRow("REÇU DE", "$residentName (Lot $lotNumber)"),
            _buildInfoRow("MONTANT", "$amount DH"),
            _buildInfoRow("MODE", mode),
            _buildInfoRow("OBJET", "Cotisation $period"),
            pw.SizedBox(height: 15),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Ancien: $oldBalance DH", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("->"),
                  pw.Text("Nouveau: $newBalance DH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Signature du Syndic:", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                if (cachetImage != null)
                   pw.Container(
                     width: 80,
                     height: 80,
                     child: pw.Image(cachetImage),
                   ),
              ]
            ),
            pw.SizedBox(height: 20),
          ],
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  // OPS_MISE_EN_DEMEURE - ENHANCED
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
      pageFormat: PdfPageFormat.a5, // A5 Format
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
                     pw.SizedBox(height: 40), // Placeholder
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

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 150, child: pw.Text("$label :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
