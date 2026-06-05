import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';
import 'package:sespimma_mobile/features/assessment/data/models/korsis_inbox_mock_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';

class EligibilityStatus {
  final bool isEligible;
  final String? message;

  EligibilityStatus(this.isEligible, [this.message]);
}

class RewardPunishmentEligibility {
  static EligibilityStatus checkEligibility(String nosis, RewardPunishmentItem item) {
    // History check logic
    // Using KorsisInboxMockData as the mock history source
    final history = KorsisInboxMockData.items.where((i) => i.nosis == nosis).toList();

    // KATEGORI 1: MAKSIMAL 3x SELAMA PENDIDIKAN
    if (['R_M_04', 'R_M_05', 'R_M_06', 'R_M_07'].contains(item.id)) {
      int count = history.where((i) => i.rewardPunishmentId == item.id).length;
      if (count >= 3) {
        return EligibilityStatus(false, "Batas maksimal (3x) sudah tercapai untuk reward ini");
      }
    }

    // KATEGORI 2: MAKSIMAL 2x PER MINGGU
    if (item.id == 'R_K_05') {
      final now = DateTime.now();
      // Calculate start of current week (assuming Monday is start)
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      int count = history.where((i) {
        return i.rewardPunishmentId == item.id && i.timestamp.isAfter(weekStart);
      }).length;

      if (count >= 2) {
        return EligibilityStatus(false, "Batas maksimal (2x/minggu) sudah tercapai minggu ini");
      }
    }

    // KATEGORI 3: KONDISI WAKTU KHUSUS
    if (item.id == 'R_D_01') {
      // Selama Satu Bulan Tidak Ada Pelanggaran Disiplin
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));
      bool hasPunishment = history.any((i) {
        return i.rewardPunishmentId != null &&
               i.rewardPunishmentId!.startsWith('P_D_') &&
               i.timestamp.isAfter(monthAgo);
      });

      if (hasPunishment) {
        return EligibilityStatus(false, "Serdik memiliki catatan pelanggaran disiplin dalam 30 hari terakhir");
      }
    }

    // Check Senat role for R_K_01 and R_D_03
    // Simulate senat role based on mock data (since we don't have is_senat field)
    // We will assume a Serdik is senat if they have a specific jabatan that contains "senat"
    // Or we mock it by checking if nosis ends with '1' (e.g. 1 out of 10 serdiks)
    final bool isSenat = _isSenat(nosis);

    if (item.id == 'R_K_01') {
      // Hanya untuk Senat
      if (!isSenat) {
        return EligibilityStatus(false, "Reward ini khusus untuk perangkat senat");
      }
    }

    // KATEGORI 4: KONDISI KHUSUS NON-SENAT
    if (item.id == 'R_D_03') {
      // Hanya untuk non-Senat
      if (isSenat) {
        return EligibilityStatus(false, "Reward ini hanya untuk serdik non-senat");
      }
    }

    return EligibilityStatus(true);
  }

  static bool _isSenat(String nosis) {
    final serdik = SerdikRealData.records.firstWhere(
      (s) => s['no_serdik'] == nosis,
      orElse: () => {},
    );
    
    // In our mock, let's say anyone with 'Kanit' or 'Wakasat' in jabatan is Senat, 
    // or just end with '01'/'02' for simulation.
    // Let's use nosis ending in '1' for mock senat simulation to have some variety
    if (serdik.isNotEmpty) {
      if (serdik['jabatan'] != null && serdik['jabatan'].toString().toLowerCase().contains('senat')) {
        return true;
      }
    }
    // Mock simulation
    return nosis.endsWith('1');
  }
}
