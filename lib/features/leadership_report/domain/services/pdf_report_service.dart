import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/final_recap_model.dart';

class PdfReportService {
  static Future<void> generateLeadershipReport({
    required List<FinalRecapModel> data,
    required String pokjar,
  }) async {
    final pdf = pw.Document();

    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontRegular = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildHeader(fontBold, fontRegular),
            pw.SizedBox(height: 20),
            _buildTitle(fontBold, pokjar),
            pw.SizedBox(height: 20),
            _buildTable(data, fontBold, fontRegular),
            pw.SizedBox(height: 30),
            _buildSummary(data, fontBold, fontRegular),
            pw.SizedBox(height: 40),
            _buildFooter(fontBold, fontRegular),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Kepemimpinan_${pokjar.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildHeader(pw.Font bold, pw.Font regular) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'KEPOLISIAN NEGARA REPUBLIK INDONESIA',
          style: pw.TextStyle(font: bold, fontSize: 10),
        ),
        pw.Text(
          'LEMBAGA PENDIDIKAN DAN PELATIHAN',
          style: pw.TextStyle(font: bold, fontSize: 10),
        ),
        pw.Container(width: 200, child: pw.Divider(thickness: 1)),
      ],
    );
  }

  static pw.Widget _buildTitle(pw.Font bold, String pokjar) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'LAPORAN HASIL EVALUASI AKHIR SERDIK',
            style: pw.TextStyle(font: bold, fontSize: 14),
          ),
          pw.Text(
            'SESPIMMA POLRI ANGKATAN KE-75',
            style: pw.TextStyle(font: bold, fontSize: 12),
          ),
          pw.Text(
            'WILAYAH MONITORING: ${pokjar.toUpperCase()}',
            style: pw.TextStyle(font: bold, fontSize: 11),
          ),
          pw.SizedBox(height: 5),
          pw.Container(width: 300, child: pw.Divider(thickness: 2)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
    List<FinalRecapModel> data,
    pw.Font bold,
    pw.Font regular,
  ) {
    final headers = [
      'NO',
      'NAMA / NRP',
      'POKJAR',
      'AKD',
      'MENTAL',
      'JAS',
      'RATA2',
      'STATUS',
    ];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: List.generate(data.length, (index) {
        final item = data[index];
        final isLulus = item.average >= 70.0;
        return [
          '${index + 1}',
          '${item.name}\n${item.nrp}',
          item.pokjar,
          item.academicScore.toStringAsFixed(1),
          item.mentalScore.toStringAsFixed(1),
          item.physicalScore.toStringAsFixed(1),
          item.average.toStringAsFixed(1),
          isLulus ? 'LULUS' : 'TIDAK LULUS',
        ];
      }),
      headerStyle: pw.TextStyle(
        font: bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: pw.TextStyle(font: regular, fontSize: 8),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FixedColumnWidth(35),
        4: const pw.FixedColumnWidth(35),
        5: const pw.FixedColumnWidth(35),
        6: const pw.FixedColumnWidth(40),
        7: const pw.FixedColumnWidth(60),
      },
      cellAlignment: pw.Alignment.center,
      cellAlignments: {1: pw.Alignment.centerLeft},
    );
  }

  static pw.Widget _buildSummary(
    List<FinalRecapModel> data,
    pw.Font bold,
    pw.Font regular,
  ) {
    final int lulus = data.where((r) => r.average >= 70.0).length;
    final int tidakLulus = data.length - lulus;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'RINGKASAN KELULUSAN:',
              style: pw.TextStyle(font: bold, fontSize: 10),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Total Serdik Terpilih : ${data.length} Orang',
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
            pw.Text(
              'Memenuhi Syarat (Lulus) : $lulus Orang',
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
            pw.Text(
              'Peringatan Khusus      : $tidakLulus Orang',
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Font bold, pw.Font regular) {
    final date = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dateStr = '${date.day} ${months[date.month - 1]} ${date.year}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          children: [
            pw.Text(
              'Lembang, $dateStr',
              style: pw.TextStyle(font: regular, fontSize: 10),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'KA SESPIMMA LEMDIKLAT POLRI',
              style: pw.TextStyle(font: bold, fontSize: 10),
            ),
            pw.SizedBox(height: 60),
            pw.Container(width: 150, child: pw.Divider(thickness: 1)),
            pw.Text(
              'INSPEKTUR JENDERAL POLISI',
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }
}
