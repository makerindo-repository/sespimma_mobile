// lib/features/assessment/data/models/health_monitoring_data.dart

class HealthRecord {
  final String id;
  final String type;
  final String description;
  final String? photoPath;
  final int minusPoints;
  final DateTime timestamp;
  final String medisName;

  HealthRecord({
    required this.id,
    required this.type,
    required this.description,
    this.photoPath,
    required this.minusPoints,
    required this.timestamp,
    required this.medisName,
  });
}

class SerdikHealthData {
  final String noSerdik;
  double? nilaiA;
  double? nilaiB;
  int baseNilaiC = 80;
  List<HealthRecord> records = [];

  SerdikHealthData({
    required this.noSerdik,
    this.nilaiA,
    this.nilaiB,
  });

  int get currentNilaiC {
    int totalMinus = 0;
    for (var r in records) {
      totalMinus += r.minusPoints;
    }
    return baseNilaiC - totalMinus;
  }

  double get nilaiAkhir {
    // According to formula: N.KES = (A + B + C) / 3
    // But if A and B are null, we treat them as 0 for the formula or what?
    // Usually if a test is not done, we just use 0.
    double a = nilaiA ?? 0.0;
    double b = nilaiB ?? 0.0;
    double c = currentNilaiC.toDouble();
    return (a + b + c) / 3;
  }
}

class HealthMonitoringData {
  static final Map<String, SerdikHealthData> _data = {};

  static SerdikHealthData getHealthData(String noSerdik) {
    if (!_data.containsKey(noSerdik)) {
      _data[noSerdik] = SerdikHealthData(noSerdik: noSerdik);
    }
    return _data[noSerdik]!;
  }

  static void updateNilaiA(String noSerdik, double score) {
    getHealthData(noSerdik).nilaiA = score;
  }

  static void updateNilaiB(String noSerdik, double score) {
    getHealthData(noSerdik).nilaiB = score;
  }

  static void addHealthRecord(
    String noSerdik,
    String type,
    String description,
    String medisName,
    int minusPoints, {
    String? photoPath,
  }) {
    final record = HealthRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      description: description,
      photoPath: photoPath,
      minusPoints: minusPoints,
      timestamp: DateTime.now(),
      medisName: medisName,
    );
    getHealthData(noSerdik).records.insert(0, record);
  }
}
