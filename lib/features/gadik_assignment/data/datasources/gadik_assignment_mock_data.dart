import '../models/gadik_assignment_model.dart';
import '../models/gadik_submission_model.dart';

class GadikAssignmentMockData {
  static List<GadikAssignmentModel> assignments = [
    GadikAssignmentModel(
      id: 'GTSK-001',
      judul: 'Ujian Akhir Rumpun Hukum',
      jenisTugas: 'Ujian Mata Pelajaran atau Esai',
      deadline: DateTime.now().add(const Duration(days: 2)),
      targetPokjar: 'Semua Pokjar',
      instruksi: 'Kerjakan soal esai dan kumpulkan format PDF.',
      status: 'Sedang Mulai',
      createdBy: 'Efrianza',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GadikAssignmentModel(
      id: 'GTSK-002',
      judul: 'Tugas NKKP Kelompok 1',
      jenisTugas: 'NKKP (Naskah Kuliah Kerja Profesi)',
      deadline: DateTime.now().subtract(const Duration(hours: 10)),
      targetPokjar: 'Pokjar I',
      instruksi: 'Upload laporan NKKP Bab I sampai Bab V.',
      status: 'Selesai',
      createdBy: 'Efrianza',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GadikAssignmentModel(
      id: 'GTSK-003',
      judul: 'Tugas Integritas Personal',
      jenisTugas: 'NKP (Naskah Karya Perseorangan)',
      turunanTugas: 'Integritas & Etika',
      deadline: DateTime.now().add(const Duration(days: 7)),
      targetPokjar: 'Semua Pokjar',
      instruksi: 'Tulis analisis sesuai 10 Kompetensi Kepemimpinan.',
      status: 'Belum Mulai',
      createdBy: 'Efrianza',
      createdAt: DateTime.now(),
    ),
  ];

  static List<GadikSubmissionModel> submissions = [
    GadikSubmissionModel(
      id: 'SUB-001',
      assignmentId: 'GTSK-002',
      serdikName: 'Ahmad Santoso',
      serdikNrp: '202602003097',
      submittedAt: DateTime.now().subtract(const Duration(hours: 12)),
      fileName: 'NKKP_Pokjar1_Ahmad.pdf',
      fileUrl: 'https://example.com/file',
      isGraded: false,
    ),
    GadikSubmissionModel(
      id: 'SUB-002',
      assignmentId: 'GTSK-002',
      serdikName: 'Budi Raharjo',
      serdikNrp: '202602003098',
      submittedAt: DateTime.now().subtract(const Duration(hours: 11)),
      fileName: 'NKKP_Pokjar1_Budi.pdf',
      fileUrl: 'https://example.com/file',
      isGraded: true,
      nilaiAkhir: 82.20,
      scoreMateri: 82,
      scorePaparan: 80,
      scoreKeaktifan: 85,
      catatanPengajar: 'Materi sangat baik, pertahankan presentasi.',
    ),
  ];
}
