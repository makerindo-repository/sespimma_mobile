class GadikSubmissionModel {
  final String id;
  final String assignmentId;
  final String serdikName;
  final String serdikNrp;
  final DateTime? submittedAt;
  final String? fileUrl;
  final String? fileName;
  
  // Grading status
  final bool isGraded;
  final double? nilaiAkhir;
  final String? catatanPengajar;
  
  // NKKP & NPKP & NKP & TASKAP Components (Materi, Penulisan, Paparan, Keaktifan)
  final double? scoreMateri;
  final double? scorePenulisan;
  final double? scorePaparan;
  final double? scoreKeaktifan;
  
  // Ujian MP
  final double? scoreUjian;
  
  // NSK
  final double? scoreKeaktifanPerseorangan;
  final double? scoreProdukPerseorangan;
  final double? scoreTataRuang;

  const GadikSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.serdikName,
    required this.serdikNrp,
    this.submittedAt,
    this.fileUrl,
    this.fileName,
    this.isGraded = false,
    this.nilaiAkhir,
    this.catatanPengajar,
    this.scoreMateri,
    this.scorePenulisan,
    this.scorePaparan,
    this.scoreKeaktifan,
    this.scoreUjian,
    this.scoreKeaktifanPerseorangan,
    this.scoreProdukPerseorangan,
    this.scoreTataRuang,
  });
}
