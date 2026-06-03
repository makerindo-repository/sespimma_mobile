// lib/features/assessment/data/models/jasmani_grading_data.dart

class JasmaniGradingData {
  final String noSerdik;
  double? nilaiA;
  double? nilaiB1; // Pull Up
  double? nilaiB2; // Sit Up
  double? nilaiB3; // Push Up
  double? nilaiB4; // Shuttle Run

  JasmaniGradingData({
    required this.noSerdik,
    this.nilaiA,
    this.nilaiB1,
    this.nilaiB2,
    this.nilaiB3,
    this.nilaiB4,
  });

  bool get isSamaptaBComplete =>
      nilaiB1 != null && nilaiB2 != null && nilaiB3 != null && nilaiB4 != null;

  double get nilaiB {
    return ((nilaiB1 ?? 0) + (nilaiB2 ?? 0) + (nilaiB3 ?? 0) + (nilaiB4 ?? 0)) / 4;
  }

  double getNilaiJasmani(String golongan) {
    if (nilaiA == null) return 0.0;
    if (golongan == 'GOL IV') {
      return nilaiA!;
    }
    return (nilaiA! + nilaiB) / 2;
  }

  // Static mock repository
  static final Map<String, JasmaniGradingData> _records = {};

  static JasmaniGradingData getJasmaniData(String noSerdik) {
    if (!_records.containsKey(noSerdik)) {
      _records[noSerdik] = JasmaniGradingData(noSerdik: noSerdik);
    }
    return _records[noSerdik]!;
  }

  static void saveJasmaniData(JasmaniGradingData data) {
    _records[data.noSerdik] = data;
  }
}
