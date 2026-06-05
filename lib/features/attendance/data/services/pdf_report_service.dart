import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sespimma_mobile/features/attendance/domain/models/map_tile_mode.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<void> generateAndDownloadReport({
    required String pokjar,
    required DateTime date,
  }) async {
    final pdf = pw.Document();
    
    // Load Unicode fonts to prevent Helvetica errors
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Dapatkan data serdik berdasarkan pokjar
    final listSerdik = SerdikRealData.records
        .where((s) => pokjar.isEmpty || s['kelompok_kelas'] == pokjar)
        .toList();

    // Sorting by name just in case
    listSerdik.sort((a, b) => (a['nama'] ?? '').compareTo(b['nama'] ?? ''));

    final DateFormat formatHariTanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final String hariTanggalStr = formatHariTanggal.format(date);
    
    // Tanggal Lembang
    final String tglLembangStr = DateFormat('dd MMMM', 'id_ID').format(date).toUpperCase();
    final String tahunStr = DateFormat('yyyy').format(date);

    // Hitung rekap
    int total = listSerdik.length;
    int hadir = total - 3;
    int kurang = 3;
    int sakit = 1;
    int ijin = 1;
    int tk = 1;

    // Ambil daftar zona dari manajemen zona Korsis
    final List<AttendanceZone> zones = AttendanceZones.activeZones.isEmpty
        ? List.generate(
            10,
            (i) => AttendanceZone(
              id: 'dummy_$i',
              name: 'Zona $i',
              latitude: 0,
              longitude: 0,
              radiusMeters: 10,
              activityName: 'Kegiatan ${i + 1}',
              creator: 'Korsis',
              startTime: date,
              endTime: date.add(const Duration(hours: 2)),
              deadline: date.add(const Duration(hours: 1)),
              cutoffTime: date.add(const Duration(hours: 1)),
            ),
          )
        : AttendanceZones.activeZones;

    for (final zone in zones) {
      final String startStr = DateFormat('HH.mm').format(zone.startTime);
      final String endStr = DateFormat('HH.mm').format(zone.endTime);
      final String pukulStr = '$startStr s/d $endStr WIB';
      final String giatStr = zone.activityName;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              _buildHeader(pokjar, hariTanggalStr, giatStr, pukulStr, fontRegular, fontBold),
              pw.SizedBox(height: 12),
              _buildTitle(tahunStr, fontBold),
              pw.SizedBox(height: 12),
              _buildTable(listSerdik, fontRegular, fontBold),
              pw.SizedBox(height: 16),
              _buildFooter(tglLembangStr, tahunStr, total, hadir, kurang, sakit, ijin, tk, fontRegular, fontBold),
            ];
          },
        ),
      );
    }

    // Format nama file
    final String formatTgl = DateFormat('ddMMyyyy').format(date);
    String numPokjar = 'I';
    if (pokjar.contains('1')) numPokjar = 'I';
    if (pokjar.contains('2')) numPokjar = 'II';
    if (pokjar.contains('3')) numPokjar = 'III';
    if (pokjar.contains('4')) numPokjar = 'IV';
    if (pokjar.contains('5')) numPokjar = 'V';

    final String filename = '${numPokjar}_LAPORAN_ABSENSI_HARIAN_$formatTgl.pdf';

    // Munculkan dialog share/save file bawaan OS
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  static pw.Widget _buildHeader(String pokjar, String hariTanggal, String giat, String pukul, pw.Font fontRegular, pw.Font fontBold) {
    String numPokjar = 'I';
    if (pokjar.contains('1')) numPokjar = 'I';
    if (pokjar.contains('2')) numPokjar = 'II';
    if (pokjar.contains('3')) numPokjar = 'III';
    if (pokjar.contains('4')) numPokjar = 'IV';
    if (pokjar.contains('5')) numPokjar = 'V';

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('SESPIM LEMDIKLAT POLRI', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  pw.Text('SEKOLAH STAF DAN PIMPINAN PERTAMA', style: pw.TextStyle(font: fontRegular, fontSize: 10, decoration: pw.TextDecoration.underline)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 80, child: pw.Text('Hari/Tanggal', style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                    pw.Text(':', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.SizedBox(width: 8),
                    pw.Text(hariTanggal, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ]
                ),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 80, child: pw.Text('Giat', style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                    pw.Text(':', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.SizedBox(width: 8),
                    pw.Text(giat, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ]
                ),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 80, child: pw.Text('Pukul', style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                    pw.Text(':', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.SizedBox(width: 8),
                    pw.Text(pukul, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ]
                ),
              ]
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('POKJAR', style: pw.TextStyle(font: fontBold, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(numPokjar, style: pw.TextStyle(font: fontBold, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ]
        ),
      ]
    );
  }

  static pw.Widget _buildTitle(String tahun, pw.Font fontBold) {
    return pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text('ABSENSI PESERTA DIDIK', style: pw.TextStyle(font: fontBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text('SESPIMMA POLRI ANGKATAN KE-75 T.A. $tahun', style: pw.TextStyle(font: fontBold, fontSize: 12, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
        ]
      ),
    );
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> listSerdik, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(120),
      },
      children: [
        // Header row
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              alignment: pw.Alignment.center,
              child: pw.Text('NO', style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              alignment: pw.Alignment.center,
              child: pw.Text('NAMA', style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              alignment: pw.Alignment.center,
              child: pw.Text('NO SERDIK', style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              alignment: pw.Alignment.center,
              child: pw.Text('DETEKSI SISTEM', style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Sub-header row (1, 2, 3, 4)
        pw.TableRow(
          children: [
            pw.Container(padding: const pw.EdgeInsets.symmetric(vertical: 2), alignment: pw.Alignment.center, child: pw.Text('1', style: pw.TextStyle(font: fontRegular, fontSize: 9))),
            pw.Container(padding: const pw.EdgeInsets.symmetric(vertical: 2), alignment: pw.Alignment.center, child: pw.Text('2', style: pw.TextStyle(font: fontRegular, fontSize: 9))),
            pw.Container(padding: const pw.EdgeInsets.symmetric(vertical: 2), alignment: pw.Alignment.center, child: pw.Text('3', style: pw.TextStyle(font: fontRegular, fontSize: 9))),
            pw.Container(padding: const pw.EdgeInsets.symmetric(vertical: 2), alignment: pw.Alignment.center, child: pw.Text('4', style: pw.TextStyle(font: fontRegular, fontSize: 9))),
          ]
        ),
        // Data rows
        ...List.generate(listSerdik.length, (index) {
          final serdik = listSerdik[index];
          String nama = serdik['nama_lengkap'] ?? '';
          String noSerdik = serdik['no_serdik'] ?? '';
          
          // Random mock status for display purposes if not in DB
          // Ideally this comes from the backend sync, but for PDF layout validation
          // we use dummy logic or Hadir
          String status = 'HADIR';
          if (index == 2) status = 'SAKIT';
          if (index == 5) status = 'IZIN';
          if (index == 8) status = 'TK';

          // If name is too long, we scale the font size down instead of wrapping.
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                alignment: pw.Alignment.center,
                child: pw.Text('${index + 1}.', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  nama,
                  style: pw.TextStyle(
                    font: fontRegular, 
                    fontSize: nama.length > 35 ? 6 : (nama.length > 25 ? 7 : 9),
                  ),
                  maxLines: 1,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                alignment: pw.Alignment.center,
                child: pw.Text(noSerdik, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                alignment: pw.Alignment.center,
                child: pw.Text(status, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              ),
            ]
          );
        }),
      ]
    );
  }

  static pw.Widget _buildFooter(String tglLembang, String tahun, int total, int hadir, int kurang, int sakit, int ijin, int tk, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Bagian Kiri Bawah
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.SizedBox(width: 80, child: pw.Text('DANTON', style: pw.TextStyle(font: fontRegular, fontSize: 10))),
                pw.SizedBox(width: 60),
                pw.Text('DANKI HARIAN', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              ]
            ),
            pw.SizedBox(height: 40), // Spasi TTD
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('KET.', style: pw.TextStyle(font: fontRegular, fontSize: 10, decoration: pw.TextDecoration.underline)),
                    pw.SizedBox(height: 4),
                    _buildKetRow('JUMLAH', total.toString(), fontRegular),
                    _buildKetRow('HADIR', hadir.toString(), fontRegular),
                    _buildKetRow('KURANG', kurang.toString(), fontRegular),
                  ]
                ),
                pw.SizedBox(width: 60),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('KET KURANG:', style: pw.TextStyle(font: fontRegular, fontSize: 10, decoration: pw.TextDecoration.underline)),
                    pw.SizedBox(height: 4),
                    _buildKetKurangRow('SAKIT', sakit.toString(), fontRegular),
                    _buildKetKurangRow('IJIN', ijin.toString(), fontRegular),
                    _buildKetKurangRow('TK', tk.toString(), fontRegular),
                  ]
                ),
              ]
            ),
          ]
        ),
        // Bagian Kanan Bawah
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('LEMBANG, $tglLembang $tahun', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.Text('KAKORSIS', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
            pw.SizedBox(height: 35), // Spasi TTD
            pw.Text('SUPRAYITNO, S.H.,S.I.K.', style: pw.TextStyle(font: fontRegular, fontSize: 10, decoration: pw.TextDecoration.underline)),
            pw.Text('KOMBES POL NRP. 70012128', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
          ]
        ),
      ]
    );
  }

  static pw.Widget _buildKetRow(String label, String value, pw.Font fontRegular) {
    return pw.Row(
      children: [
        pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
        pw.Text(':', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
      ]
    );
  }

  static pw.Widget _buildKetKurangRow(String label, String value, pw.Font fontRegular) {
    return pw.Row(
      children: [
        pw.SizedBox(width: 40, child: pw.Text(label, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
        pw.Text(':', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
        pw.SizedBox(width: 8),
        pw.SizedBox(width: 20, child: pw.Text(value, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
        pw.Text('an.', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
      ]
    );
  }
}
