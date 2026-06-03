import 'package:sespimma_mobile/features/leadership_ews/data/models/ews_model.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/features/assignment/data/models/tugas_model.dart';
import 'package:sespimma_mobile/features/leadership_report/domain/services/score_calculator_service.dart';

class PimpinanMockData {
  static const String pimpinanNrp = '75060001';
  static const String pimpinanName =
      'KOMBES POL. FAJAR NUGROHO, S.H., S.I.K., M.H.';
  static const String pimpinanJabatan = 'KA SESPIMMA LEMDIKLAT POLRI';

  static int attendanceReportCount = 158;

  static final List<Map<String, dynamic>> customActivities = [];

  static final List<FinalRecapModel> sharedReportData =
      ScoreCalculatorService.generateRealReports();

  static final List<EwsModel> sharedEwsData = sharedReportData.map((report) {
    return EwsModel(
      id: report.id,
      name: report.name,
      nrp: report.nrp,
      pokjar: report.pokjar,
      averageScore: report.average,
      violationCount: report.average < 72.0 ? 6 : 0,
    );
  }).toList();

  static List<Map<String, dynamic>> getPokjarAverages() {
    final Map<String, List<double>> pokjarGrades = {};
    for (var report in sharedReportData) {
      if (!pokjarGrades.containsKey(report.pokjar)) {
        pokjarGrades[report.pokjar] = [];
      }
      pokjarGrades[report.pokjar]!.add(report.average);
    }

    return pokjarGrades.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return {'name': e.key, 'average': avg};
    }).toList();
  }

  static Map<String, double> getGlobalComponentAverages() {
    if (sharedReportData.isEmpty) {
      return {'akademik': 0, 'mental': 0, 'jasmani': 0};
    }

    double totalAkad = 0;
    double totalMent = 0;
    double totalJasm = 0;

    for (var r in sharedReportData) {
      totalAkad += r.academicScore;
      totalMent += r.mentalScore;
      totalJasm += r.physicalScore;
    }

    final count = sharedReportData.length;
    return {
      'akademik': totalAkad / count,
      'mental': totalMent / count,
      'jasmani': totalJasm / count,
    };
  }

  static final List<Map<String, dynamic>> serdikAttendanceHistory = [
    {
      'id': 'att_001',
      'title': 'Apel Pagi Siswa',
      'date': _getFormattedDate(0),
      'time': '07:05 WIB',
      'dateTime': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'Hadir',
      'type': 'hadir',
      'method': 'Geofencing',
      'verification': 'Valid',
      'location': 'Lapangan Apel Utama Sespimma',
      'device': 'Samsung Galaxy S23 Ultra',
      'image': 'assets/images/avatar.png',
    },
    {
      'id': 'att_002',
      'title': 'Kelas Kepemimpinan',
      'date': _getFormattedDate(0),
      'time': '08:30 WIB',
      'dateTime': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'Hadir',
      'type': 'hadir',
      'method': 'QR Code',
      'verification': 'Valid',
      'location': 'Gedung Pancasila (Ruang 104)',
      'device': 'Samsung Galaxy S23 Ultra',
      'image': 'assets/images/avatar.png',
    },
    {
      'id': 'att_003',
      'title': 'Diskusi Kelompok (POKJAR)',
      'date': _getFormattedDate(1),
      'time': '10:00 WIB',
      'dateTime': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Hadir',
      'type': 'hadir',
      'method': 'Manual',
      'verification': 'Valid',
      'location': 'Ruang Diskusi',
      'device': '-',
      'image': 'assets/images/avatar.png',
    },
    {
      'id': 'att_004',
      'title': 'Apel Pagi Siswa',
      'date': _getFormattedDate(2),
      'time': '07:15 WIB',
      'dateTime': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Telat',
      'type': 'telat',
      'method': 'Geofencing',
      'verification': 'Valid',
      'location': 'Gerbang Utama Sespimma',
      'device': 'Samsung Galaxy S23 Ultra',
      'image': 'assets/images/avatar.png',
    },
    {
      'id': 'att_005',
      'title': 'Kelas Manajemen',
      'date': _getFormattedDate(3),
      'time': '08:30 WIB',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Izin',
      'type': 'izin',
      'method': 'Pengajuan Surat',
      'verification': 'Valid',
      'location': '-',
      'device': '-',
      'image': '',
      'attachment': 'Surat_Sakit.pdf',
    },
    {
      'id': 'att_006',
      'title': 'Olahraga Bersama',
      'date': _getFormattedDate(4),
      'time': '06:00 WIB',
      'dateTime': DateTime.now().subtract(const Duration(days: 4)),
      'status': 'Alpha',
      'type': 'alpha',
      'method': '-',
      'verification': 'Tidak Valid',
      'location': '-',
      'device': '-',
      'image': '',
    },
  ];

  static final List<Map<String, dynamic>> sharedTaskSubmissions = [
    {
      'taskId': 'TSK-003',
      'name': 'Serdik Riza Aribowo',
      'nrp': '82030911',
      'pokjar': 'POKJAR 1',
      'status': 'sudah',
      'file': 'Ujian_MP_Jawaban_Riza.pdf',
      'time': 'Hari ini, 08:30 WIB',
    },
    {
      'taskId': 'TSK-003',
      'name': 'Serdik Eko Chandra',
      'nrp': '84050322',
      'pokjar': 'POKJAR 1',
      'status': 'sudah',
      'file': 'jawaban_ujian_eko.pdf',
      'time': 'Hari ini, 09:15 WIB',
    },
    {
      'taskId': 'TSK-003',
      'name': 'Serdik Daffa Yape',
      'nrp': '88020111',
      'pokjar': 'POKJAR 2',
      'status': 'dinilai',
      'file': 'ujian_mp_daffa.pdf',
      'time': 'Kemarin, 14:30 WIB',
      'score': 88.5,
    },
    {
      'taskId': 'TSK-003',
      'name': 'Serdik Andi Wijaya',
      'nrp': '85110433',
      'pokjar': 'POKJAR 2',
      'status': 'belum',
      'file': null,
      'time': '-',
    },
    {
      'taskId': 'TSK-004',
      'name': 'Serdik Sari Pertiwi',
      'nrp': '83070255',
      'pokjar': 'POKJAR 3',
      'status': 'dinilai',
      'file': 'Resume_Kuliah_Sari.pdf',
      'time': '3 hari lalu, 10:00 WIB',
      'score': 92.5,
    },
    {
      'taskId': 'TSK-001',
      'name': 'Serdik Riza Aribowo',
      'nrp': '82030911',
      'pokjar': 'POKJAR 1',
      'status': 'sudah',
      'file': 'NKP_Analisis_Integritas_Riza.pdf',
      'time': 'Hari ini, 09:00 WIB',
    },
    {
      'taskId': 'TSK-001',
      'name': 'Serdik Eko Chandra',
      'nrp': '84050322',
      'pokjar': 'POKJAR 1',
      'status': 'sudah',
      'file': 'nkp_eko_chandra.pdf',
      'time': 'Hari ini, 10:15 WIB',
    },
    {
      'taskId': 'TSK-002',
      'name': 'Serdik Daffa Yape',
      'nrp': '88020111',
      'pokjar': 'POKJAR 2',
      'status': 'sudah',
      'file': 'taskap_daffa.pdf',
      'time': 'Kemarin, 16:45 WIB',
    },
    {
      'taskId': 'TSK-002',
      'name': 'Serdik Andi Wijaya',
      'nrp': '85110433',
      'pokjar': 'POKJAR 2',
      'status': 'belum',
      'file': null,
      'time': '-',
    },
  ];

  static List<Map<String, dynamic>> getSubmissionsForTask(String taskId) {
    return sharedTaskSubmissions.where((s) => s['taskId'] == taskId).toList();
  }

  static final Set<String> ratedSerdikForAssessment = {};

  static final List<TugasModel> sharedTasks = [
    TugasModel(
      id: 'TSK-001',
      judul: 'Naskah Karya Perseorangan (NKP) - Analisis Integritas',
      deskripsi:
          'Buatlah naskah analisis komprehensif mengenai implementasi integritas kepolisian di lapangan.',
      mapel: 'NKP (Naskah Karya Perseorangan)',
      deadline: DateTime.now().add(const Duration(minutes: 59)),
      status: 'Aktif',
      createdBy: '80101234',
      createdByName: 'KOMPOL Reza Mahendra',
    ),
    TugasModel(
      id: 'TSK-002',
      judul: 'Naskah Program Transformasi Teknis (Taskap)',
      deskripsi:
          'Kumpulkan draf lengkap naskah program transformasi teknis organisasi untuk ditinjau oleh Patun.',
      mapel: 'NKKP (Naskah Kuliah Kerja Profesi)',
      deadline: DateTime.now().add(const Duration(hours: 23, minutes: 15)),
      status: 'Aktif',
      createdBy: '80102222',
      createdByName: 'KOMPOL Budi Prakoso',
    ),
    TugasModel(
      id: 'TSK-003',
      judul: 'Ujian MP - Pengendalian Diri & Emosi',
      deskripsi:
          'Kumpulkan berkas lembar jawaban ujian MP / Esai tentang pengendalian diri dan emosi kepemimpinan.',
      mapel: 'Ujian MP / Esai',
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Selesai',
      createdBy: '80101234',
      createdByName: 'KOMPOL Reza Mahendra',
    ),
    TugasModel(
      id: 'TSK-004',
      judul: 'Resume Kuliah Umum - Transparansi Digital SESPIMMA',
      deskripsi:
          'Resume materi kuliah umum tentang transparansi digital di lingkungan Polri.',
      mapel: 'Sistem Informasi Publik',
      deadline: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Selesai',
      createdBy: '80101234',
      createdByName: 'KOMPOL Reza Mahendra',
    ),
  ];

  static String _getFormattedDate(int daysAgo) {
    final target = DateTime.now().subtract(Duration(days: daysAgo));
    const months = [
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
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final dayIndex = target.weekday == 7 ? 0 : target.weekday;
    return '${days[dayIndex]}, ${target.day} ${months[target.month - 1]} ${target.year}';
  }
}
