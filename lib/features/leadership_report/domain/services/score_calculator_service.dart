import 'package:sespimma_mobile/features/assessment/data/models/korsis_inbox_mock_data.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/core/utils/scoring_calculator.dart';

class ScoreCalculatorService {
  static List<FinalRecapModel> generateRealReports() {
    return SerdikRealData.records.map((serdik) {
      final String noSerdik = serdik['no_serdik'] ?? '';

      final raw = generateSimulatedScores(noSerdik);

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

    double nkkp = ScoringCalculator.hitungNKKPatauNPKP(
      nmpn: nmpn,
      npa: npa,
      nka: nka,
    );
    double npkp = ScoringCalculator.hitungNKKPatauNPKP(
      nmpn: nmpn,
      npa: npa,
      nka: nka,
    );

    List<double> nkpTasks =
        (raw['NKP_tasks'] as List<dynamic>?)
            ?.map((e) => e as double)
            .toList() ??
        [];
    double nkp = nkpTasks.isEmpty
        ? ScoringCalculator.hitungNKP(nmpn: nmpn, npa: npa)
        : nkpTasks.reduce((a, b) => a + b) / nkpTasks.length;

    double np = ScoringCalculator.hitungNP(
      nump: nump,
      nkkp: nkkp,
      npkp: npkp,
      nkp: nkp,
    );

    double keaktifan = _getDouble(raw, 'keaktifan_sk');
    double produk = _getDouble(raw, 'produk_sk');
    double tataRuang = _getDouble(raw, 'tataruang_sk');
    double nsk = ScoringCalculator.hitungNSK(
      keaktifan: keaktifan,
      produk: produk,
      tataRuang: tataRuang,
    );

    double nam = _getDouble(raw, 'NAm');
    double nkm = _getDouble(raw, 'NKm');
    double nkp2 = _getDouble(raw, 'NKp');
    double nt = ScoringCalculator.hitungNT(nam: nam, nkm: nkm, nkp: nkp2);

    double na = ScoringCalculator.hitungNA(np: np, nsk: nsk, nt: nt);

    double dynamicReward = 0.0;
    double dynamicPunishment = 0.0;

    for (var item in KorsisInboxMockData.items) {
      if (item.nosis == serdikData['no_serdik'] &&
          item.status == 'approved' &&
          !item.isIzin) {
        if (item.isReward) {
          dynamicReward += item.points;
        } else {
          dynamicPunishment += item.points;
        }
      }
    }

    double reward = _getDouble(raw, 'reward_mental') + dynamicReward;
    double punishment =
        _getDouble(raw, 'punishment_mental') + dynamicPunishment;
    double nilaiPengamatan = 80.0 + reward - punishment;

    double ns = _getDouble(raw, 'NS');

    double nk = ScoringCalculator.hitungNK(
      nilaiPengamatan: nilaiPengamatan,
      nilaiSosiometri: ns,
    );

    double kesA = _getDouble(raw, 'kes_awal');
    double kesB = _getDouble(raw, 'kes_akhir');
    double kesC = 80.0 - _getDouble(raw, 'kes_pengurangan');
    double nkes = ScoringCalculator.hitungNKes(
      tesAwal: kesA,
      tesAkhir: kesB,
      statusKesehatan: kesC,
    );

    double nga = _getDouble(raw, 'NGA');
    double ngb1 = _getDouble(raw, 'NGB1');
    double ngb2 = _getDouble(raw, 'NGB2');
    double ngb3 = _getDouble(raw, 'NGB3');
    double ngb4 = _getDouble(raw, 'NGB4');
    double ngb = ScoringCalculator.hitungNGB(
      ngb1: ngb1,
      ngb2: ngb2,
      ngb3: ngb3,
      ngb4: ngb4,
    );
    double njas = ScoringCalculator.hitungNJas(nga: nga, ngb: ngb);

    double nkj = ScoringCalculator.hitungNKJ(nKes: nkes, nJas: njas);

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

  static Map<String, dynamic> generateSimulatedScores(String noSerdik) {
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

      'NKP_tasks': List.generate(10, (i) => sim(80, (21 + i) % 31)),
    };
  }
}
