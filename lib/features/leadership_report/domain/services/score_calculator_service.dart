import 'package:sespimma_mobile/features/assessment/data/models/korsis_inbox_mock_data.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/core/utils/scoring_calculator.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/assignment/data/models/tugas_model.dart';
import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';
import 'package:sespimma_mobile/features/assessment/data/models/health_monitoring_data.dart';

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

    double moral = 80.0;
    double disiplin = 80.0;
    double kepemimpinan = 80.0;
    double pengendalian = 80.0;
    double penampilan = 80.0;

    for (var item in KorsisInboxMockData.items) {
      if (item.nosis == serdikData['no_serdik'] &&
          (item.status == 'approved' || item.status == 'disetujui') &&
          !item.isIzin) {
        
        String aspect = '';
        if (item.rewardPunishmentId != null) {
          final rule = RewardPunishmentData.rules.firstWhere(
            (r) => r.id == item.rewardPunishmentId,
            orElse: () => RewardPunishmentItem(
                id: '', type: '', aspect: 'MORAL', description: '', point: 0),
          );
          aspect = rule.aspect;
        } else {
          aspect = 'MORAL'; // Fallback
        }

        if (item.isReward) {
          dynamicReward += item.points;
          if (aspect == 'MORAL') moral += item.points;
          if (aspect == 'DISIPLIN') disiplin += item.points;
          if (aspect == 'KEPEMIMPINAN') kepemimpinan += item.points;
          if (aspect == 'PENGENDALIAN DIRI') pengendalian += item.points;
          if (aspect == 'PENAMPILAN') penampilan += item.points;
        } else {
          dynamicPunishment += item.points.abs();
          if (aspect == 'MORAL') moral -= item.points.abs();
          if (aspect == 'DISIPLIN') disiplin -= item.points.abs();
          if (aspect == 'KEPEMIMPINAN') kepemimpinan -= item.points.abs();
          if (aspect == 'PENGENDALIAN DIRI') pengendalian -= item.points.abs();
          if (aspect == 'PENAMPILAN') penampilan -= item.points.abs();
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
        'NUMP': _getDouble(raw, 'NUMP'),
        'NKKP': nkkp,
        'NPKP': npkp,
        'NKP': nkp,
        'NP': np,
        'nsk_keaktifan': keaktifan,
        'nsk_produk': produk,
        'nsk_tata_ruang': tataRuang,
        'NSK': nsk,
        'nt_materi': nam,
        'nt_penulisan': nkm,
        'nt_paparan': nkp2,
        'NT': nt,
        'NA': na,
        'NilaiPengamatan': nilaiPengamatan,
        'NS': ns,
        'NK': nk,
        'NKes': nkes,
        'NJas': njas,
        'NKJ': nkj,
        'moral_score': moral,
        'disiplin_score': disiplin,
        'kepemimpinan_score': kepemimpinan,
        'pengendalian_score': pengendalian,
        'penampilan_score': penampilan,
        'kes_awal': kesA,
        'kes_akhir': kesB,
        'kes_status': kesC,
        'NGA': nga,
        'NGB1': ngb1,
        'NGB2': ngb2,
        'NGB3': ngb3,
        'NGB4': ngb4,
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
    // Dynamically calculate actual score from PimpinanMockData and KorsisInboxMockData
    // We will find submissions by this serdik
    final submissions = PimpinanMockData.sharedTaskSubmissions
        .where((sub) => sub['noSerdik'] == noSerdik)
        .toList();

    double sumNump = 0;
    int countNump = 0;
    double sumNkkp = 0;
    int countNkkp = 0;
    double sumNpkp = 0;
    int countNpkp = 0;
    double sumNkp = 0;
    int countNkp = 0;
    List<double> nkpTasks = [];

    for (var sub in submissions) {
      if (sub['status'] == 'Dinilai') {
        double score = (sub['score'] as num?)?.toDouble() ?? 0.0;
        final task = PimpinanMockData.sharedTasks.firstWhere(
          (t) => t.id == sub['taskId'],
          orElse: () => TugasModel(
            id: '',
            judul: '',
            deskripsi: '',
            mapel: '',
            deadline: DateTime.now(),
            status: '',
            createdBy: '',
            createdByName: '',
          ),
        );
        
        final mapelLower = task.mapel.toLowerCase();
        if (mapelLower.contains('nump')) {
          sumNump += score;
          countNump++;
        } else if (mapelLower.contains('nkkp')) {
          sumNkkp += score;
          countNkkp++;
        } else if (mapelLower.contains('npkp')) {
          sumNpkp += score;
          countNpkp++;
        } else if (mapelLower.contains('nkp')) {
          sumNkp += score;
          countNkp++;
          nkpTasks.add(score);
        }
      }
    }

    double nmpn = countNump > 0 ? (sumNump / countNump) : 0.0;
    double nump = countNump > 0 ? (sumNump / countNump) : 0.0;

    double rewardMental = 0.0;
    double punishmentMental = 0.0;
    for (var item in KorsisInboxMockData.items) {
      if (item.nosis == noSerdik && item.status == 'disetujui' && !item.isIzin) {
        if (item.isReward) {
          rewardMental += item.points;
        } else {
          punishmentMental += item.points;
        }
      }
    }


    final healthData = HealthMonitoringData.getHealthData(noSerdik);

    int totalMinus = 0;
    for (var r in healthData.records) {
      totalMinus += r.minusPoints;
    }

    // Default other components to 0.0 if not filled
    return {
      'NMPN': nmpn,
      'NPa': countNkkp > 0 ? (sumNkkp / countNkkp) : 0.0,
      'NKa': countNpkp > 0 ? (sumNpkp / countNpkp) : 0.0,
      'NKP': countNkp > 0 ? (sumNkp / countNkp) : 0.0,
      'NUMP': nump,

      'keaktifan_sk': 0.0,
      'produk_sk': 0.0,
      'tataruang_sk': 0.0,

      'NAm': 0.0,
      'NKm': 0.0,
      'NKp': 0.0,

      'reward_mental': rewardMental,
      'punishment_mental': punishmentMental,
      'NS': 0.0,

      'kes_awal': healthData.nilaiA ?? 0.0,
      'kes_akhir': healthData.nilaiB ?? 0.0,
      'kes_pengurangan': totalMinus.toDouble(),

      'NGA': 0.0,
      'NGB1': 0.0,
      'NGB2': 0.0,
      'NGB3': 0.0,
      'NGB4': 0.0,

      'NKP_tasks': nkpTasks,
    };
  }
}
