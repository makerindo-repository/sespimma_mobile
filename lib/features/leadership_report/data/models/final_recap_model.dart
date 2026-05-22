class FinalRecapModel {
  final String id;
  final String name;
  final String nrp;
  final String pokjar;
  final double academicScore;
  final double mentalScore;
  final double physicalScore;
  final String tanggalLahir;
  final String jenisKelamin;
  final int sanksiKesehatan;
  final Map<String, double> rawScores;

  FinalRecapModel({
    required this.id,
    required this.name,
    required this.nrp,
    required this.pokjar,
    required this.academicScore,
    required this.mentalScore,
    required this.physicalScore,
    this.tanggalLahir = '1985-01-01',
    this.jenisKelamin = 'Laki-laki',
    this.sanksiKesehatan = 0,
    this.rawScores = const {},
  });

  double get average {
    return (academicScore * 0.7) + (mentalScore * 0.2) + (physicalScore * 0.1);
  }

  String get predicate {
    final double score = average;
    if (score > 90.00) return 'ISTIMEWA / BERITA ACARA';
    if (score > 85.00) return 'Sangat Memuaskan (SM)';
    if (score > 80.00) return 'Memuaskan (M)';
    if (score > 75.00) return 'Baik (B)';
    if (score >= 70.00) return 'Cukup (C)';
    return 'Kurang (K) / TIDAK LULUS';
  }

  factory FinalRecapModel.fromJson(Map<String, dynamic> json) {
    return FinalRecapModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nrp: json['nrp'] as String? ?? '',
      pokjar: json['pokjar'] as String? ?? '',
      academicScore: (json['academic_score'] as num?)?.toDouble() ?? 0.0,
      mentalScore: (json['mental_score'] as num?)?.toDouble() ?? 0.0,
      physicalScore: (json['physical_score'] as num?)?.toDouble() ?? 0.0,
      tanggalLahir: json['tanggal_lahir'] as String? ?? '1985-01-01',
      jenisKelamin: json['jenis_kelamin'] as String? ?? 'Laki-laki',
      sanksiKesehatan: json['sanksi_kesehatan'] as int? ?? 0,
      rawScores: (json['raw_scores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nrp': nrp,
      'pokjar': pokjar,
      'academic_score': academicScore,
      'mental_score': mentalScore,
      'physical_score': physicalScore,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'sanksi_kesehatan': sanksiKesehatan,
      'raw_scores': rawScores,
    };
  }

  FinalRecapModel copyWith({
    String? id,
    String? name,
    String? nrp,
    String? pokjar,
    double? academicScore,
    double? mentalScore,
    double? physicalScore,
    String? tanggalLahir,
    String? jenisKelamin,
    int? sanksiKesehatan,
    Map<String, double>? rawScores,
  }) {
    return FinalRecapModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nrp: nrp ?? this.nrp,
      pokjar: pokjar ?? this.pokjar,
      academicScore: academicScore ?? this.academicScore,
      mentalScore: mentalScore ?? this.mentalScore,
      physicalScore: physicalScore ?? this.physicalScore,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      sanksiKesehatan: sanksiKesehatan ?? this.sanksiKesehatan,
      rawScores: rawScores ?? this.rawScores,
    );
  }
}
