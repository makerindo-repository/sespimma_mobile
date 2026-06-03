import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';

class ScoreCalculatorService {
  static List<FinalRecapModel> generateRealReports() {
    return SerdikRealData.records.map((serdik) {
      final String noSerdik = serdik['no_serdik'] ?? '';

      final raw = _generateSimulatedScores(noSerdik);

      return calculateFinalRecap(serdik, raw);
    }).toList();
  }

  static FinalRecapModel calculateFinalRecap(
    Map<String, dynamic> serdikData,
    Map<String, dynamic> raw,
  ) {
    double nmpn = _getDouble(raw, 'NMPN');
    double npa = _getDouble(raw, 'NPa');
    double nka = _getDouble(raw, 'NKa');
    double nump = _getDouble(raw, 'NUMP');

    double nkkp = (nmpn * 35 + npa * 35 + nka * 30) / 100;

    double npkp = (nmpn * 35 + npa * 35 + nka * 30) / 100;

    double nkp = (nmpn * 50 + npa * 50) / 100;

    double np = (nump * 30 + nkkp * 5 + npkp * 5 + nkp * 60) / 100;

    double keaktifan = _getDouble(raw, 'keaktifan_sk');
    double produk = _getDouble(raw, 'produk_sk');
    double tataRuang = _getDouble(raw, 'tataruang_sk');
    double nsk = (keaktifan * 60 + produk * 20 + tataRuang * 20) / 100;

    double nam = _getDouble(raw, 'NAm');
    double nkm = _getDouble(raw, 'NKm');
    double nkp2 = _getDouble(raw, 'NKp');
    double nt = (nam * 40 + nkm * 30 + nkp2 * 30) / 100;

    double na = (np * 60 + nsk * 10 + nt * 30) / 100;

    double reward = _getDouble(raw, 'reward_mental');
    double punishment = _getDouble(raw, 'punishment_mental');
    double nilaiPengamatan = 80.0 + reward - punishment;

    double ns = _getDouble(raw, 'NS');

    double nk = (nilaiPengamatan * 7 + ns * 3) / 10;

    double kesA = _getDouble(raw, 'kes_awal');
    double kesB = _getDouble(raw, 'kes_akhir');
    double kesC = 80.0 - _getDouble(raw, 'kes_pengurangan');
    double nkes = (kesA + kesB + kesC) / 3;

    double nga = _getDouble(raw, 'NGA');
    double ngb1 = _getDouble(raw, 'NGB1');
    double ngb2 = _getDouble(raw, 'NGB2');
    double ngb3 = _getDouble(raw, 'NGB3');
    double ngb4 = _getDouble(raw, 'NGB4');
    double ngb = (ngb1 + ngb2 + ngb3 + ngb4) / 4;
    double njas = (nga + ngb) / 2;

    double nkj = (nkes * 4 + njas * 6) / 10;

    return FinalRecapModel(
      id: serdikData['no_serdik'] ?? '',
      name: serdikData['nama_lengkap'] ?? '',
      nrp: serdikData['nrp'] ?? '',
      nosis: serdikData['no_serdik'] ?? '',
      pangkat: serdikData['pangkat'] ?? '',
      pokjar: _formatPokjar(serdikData['kelompok_kelas'] ?? ''),
      academicScore: na,
      mentalScore: nk,
      physicalScore: nkj,
      tanggalLahir: serdikData['tanggal_lahir'] ?? '1985-01-01',
      jenisKelamin: serdikData['jenis_kelamin'] ?? 'Pria',
      rawScores: {
        'NKKP': nkkp,
        'NPKP': npkp,
        'NKP': nkp,
        'NP': np,
        'NSK': nsk,
        'NT': nt,
        'NA': na,
        'NilaiPengamatan': nilaiPengamatan,
        'NS': ns,
        'NK': nk,
        'NKes': nkes,
        'NJas': njas,
        'NKJ': nkj,
      },
    );
  }

  static double _getDouble(Map<String, dynamic> raw, String key) {
    if (!raw.containsKey(key)) return 0.0;
    return (raw[key] as num).toDouble();
  }

  static String _formatPokjar(String pokjar) {
    String p = pokjar.toUpperCase().trim();
    if (p.endsWith(' 1')) return 'POKJAR I';
    if (p.endsWith(' 2')) return 'POKJAR II';
    if (p.endsWith(' 3')) return 'POKJAR III';
    if (p.endsWith(' 4')) return 'POKJAR IV';
    if (p.endsWith(' 5')) return 'POKJAR V';
    return p;
  }

  static Map<String, dynamic> _generateSimulatedScores(String noSerdik) {
    int hash = noSerdik.hashCode;

    double sim(double base, int varianceIndex) {
      double offset = ((hash >> varianceIndex) % 15) - 5;
      return base + offset;
    }

    return {
      'NMPN': sim(80, 0),
      'NPa': sim(80, 1),
      'NKa': sim(80, 2),
      'NUMP': sim(80, 3),

      'keaktifan_sk': sim(80, 4),
      'produk_sk': sim(80, 5),
      'tataruang_sk': sim(80, 6),

      'NAm': sim(82, 7),
      'NKm': sim(82, 8),
      'NKp': sim(82, 9),

      'reward_mental': ((hash >> 10) % 3).toDouble(),
      'punishment_mental': ((hash >> 11) % 2).toDouble(),
      'NS': sim(82, 12),

      'kes_awal': sim(80, 13),
      'kes_akhir': sim(81, 14),
      'kes_pengurangan': ((hash >> 15) % 3).toDouble(),

      'NGA': sim(82, 16),
      'NGB1': sim(82, 17),
      'NGB2': sim(82, 18),
      'NGB3': sim(82, 19),
      'NGB4': sim(82, 20),
    };
  }
}
