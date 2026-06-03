class GadikAssignmentModel {
  final String id;
  final String judul;
  final String jenisTugas; // Ujian MP/Esai, NKKP, NPKP, NKP, Simulasi Kepemimpinan, NPTT/Taskap
  final String? turunanTugas; // Khusus NKP: 10 Kompetensi
  final DateTime deadline;
  final String targetPokjar;
  final String instruksi;
  final String status; // Belum Mulai, Sedang Mulai, Selesai
  final String createdBy;
  final DateTime createdAt;
  final String? fileName;
  final String? fileUrl;

  const GadikAssignmentModel({
    required this.id,
    required this.judul,
    required this.jenisTugas,
    this.turunanTugas,
    required this.deadline,
    required this.targetPokjar,
    required this.instruksi,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.fileName,
    this.fileUrl,
  });
}
