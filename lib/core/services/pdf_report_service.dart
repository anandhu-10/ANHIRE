import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportService {
  /// Generates a complete Placement Readiness Report PDF and returns the bytes.
  Future<Uint8List> generateCompleteReport({
    required String studentName,
    required String registerNumber,
    required String collegeName,
    required String branch,
    required String preferredRole,
    required double cgpa,
    required int resumeScore,
    required int aptitudeScore,
    required int interviewScore,
    required double roadmapProgress, // 0.0 to 1.0
    required int readinessScore,
    required String readinessLevel, // Beginner, Intermediate, Advanced, Placement Ready
    required List<String> missingSkills,
    required List<String> recommendations,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "ANHIRE - Placement Readiness Report",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text(
                        "AI-Powered Placement Preparation Analytics",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    DateTime.now().toString().substring(0, 10),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.grey300, thickness: 1.5),
              pw.SizedBox(height: 16),

              // Student Profile Section
              pw.Text(
                "STUDENT PROFILE",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      _tableCell("Full Name", isHeader: true),
                      _tableCell(studentName),
                      _tableCell("Reg Number", isHeader: true),
                      _tableCell(registerNumber),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell("College", isHeader: true),
                      _tableCell(collegeName),
                      _tableCell("Branch/CGPA", isHeader: true),
                      _tableCell("$branch / $cgpa"),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell("Target Job Role", isHeader: true),
                      _tableCell(preferredRole),
                      _tableCell("Report Status", isHeader: true),
                      _tableCell("Completed"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Placement Readiness Score Block
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "OVERALL PLACEMENT READINESS SCORE",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          readinessLevel.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _getLevelColor(readinessLevel),
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      "$readinessScore / 100",
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Module Scores
              pw.Text(
                "MODULE BREAKDOWN",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _scoreCard("Resume Score", "$resumeScore%", "Weight: 30%"),
                  _scoreCard("Aptitude Score", "$aptitudeScore%", "Weight: 30%"),
                  _scoreCard("Mock Interview", "$interviewScore%", "Weight: 30%"),
                  _scoreCard("Roadmap Completion", "${(roadmapProgress * 100).toInt()}%", "Weight: 10%"),
                ],
              ),
              pw.SizedBox(height: 20),

              // Skill Gap Analysis
              pw.Text(
                "SKILL GAP ANALYSIS (Missing Competencies)",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              missingSkills.isEmpty
                  ? pw.Text(
                      "No critical skill gaps identified. Student meets all criteria for target role.",
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700),
                    )
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: missingSkills.map((skill) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 5,
                                height: 5,
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.red600,
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Text(skill, style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              pw.SizedBox(height: 20),

              // Recommendations
              pw.Text(
                "RECOMMENDED ACTIONS & LEARNING PLAN",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: recommendations.map((rec) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("- ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(rec, style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "This report is generated dynamically by ANHIRE placement platform.",
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              )
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _scoreCard(String title, String score, String sub) {
    return pw.Container(
      width: 110,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            score,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            sub,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  PdfColor _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return PdfColors.red700;
      case 'intermediate':
        return PdfColors.orange700;
      case 'advanced':
        return PdfColors.blue700;
      case 'placement ready':
        return PdfColors.green700;
      default:
        return PdfColors.blue700;
    }
  }

  /// Downloads or prints the generated PDF report.
  Future<void> printReport(Uint8List pdfBytes, String filename) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: filename,
    );
  }
}
