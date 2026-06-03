// lib/core/utils/scoring_calculator.dart

/// Kelas utilitas untuk menghitung seluruh komponen nilai Serdik (Akademik, Mental Kepribadian, Kesjas, dan NAK).
/// Sesuai dengan pedoman penilaian Sespimma.
class ScoringCalculator {
  // ==========================================
  // A. AKADEMIK (Bobot 70% dari NAK)
  // ==========================================

  /// STEP 1 & 2: Hitung Nilai NKKP / NPKP
  /// Komponen: Materi & Penulisan (35%), Paparan (35%), Keaktifan (30%)
  static double hitungNKKPatauNPKP({
    required double nmpn, // Nilai Materi & Penulisan
    required double npa,  // Nilai Paparan
    required double nka,  // Nilai Keaktifan
  }) {
    return ((nmpn * 35) + (npa * 35) + (nka * 30)) / 100;
  }

  /// STEP 3: Hitung Nilai NKP
  /// Komponen: Materi & Penulisan (50%), Paparan (50%)
  static double hitungNKP({
    required double nmpn,
    required double npa,
  }) {
    return ((nmpn * 50) + (npa * 50)) / 100;
  }

  /// STEP 4: Hitung Nilai Pelajaran (NP)
  static double hitungNP({
    required double nump, // Ujian MP/Esai
    required double nkkp,
    required double npkp,
    required double nkp,
  }) {
    return ((nump * 30) + (nkkp * 5) + (npkp * 5) + (nkp * 60)) / 100;
  }

  /// STEP 5: Hitung Nilai Simulasi Kepemimpinan (NSK)
  static double hitungNSK({
    required double keaktifan,  // 60%
    required double produk,     // 20%
    required double tataRuang,  // 20%
  }) {
    return ((keaktifan * 60) + (produk * 20) + (tataRuang * 20)) / 100;
  }

  /// STEP 6: Hitung Nilai NPTT/TASKAP (NT)
  static double hitungNT({
    required double nam, // Materi (40%)
    required double nkm, // Penulisan (30%)
    required double nkp, // Paparan (30%)
  }) {
    return ((nam * 40) + (nkm * 30) + (nkp * 30)) / 100;
  }

  /// STEP 7: Hitung Nilai Akademik Akhir (NA)
  static double hitungNA({
    required double np,  // 60%
    required double nsk, // 10%
    required double nt,  // 30%
  }) {
    return ((np * 60) + (nsk * 10) + (nt * 30)) / 100;
  }

  // ==========================================
  // B. MENTAL KEPRIBADIAN (Bobot 20% dari NAK)
  // ==========================================

  /// STEP 3: Hitung Nilai Sosiometri (NS)
  static double hitungSosiometri({
    required double totalNilai,
    required int jumlahSerdikPeleton,
  }) {
    if (jumlahSerdikPeleton == 0) return 0.0;
    return totalNilai / jumlahSerdikPeleton;
  }

  /// STEP 4: Hitung Nilai Kepribadian Akhir (NK)
  static double hitungNK({
    required double nilaiPengamatan, // Nilai awal (80) + Akumulasi Harian (Reward/Punishment)
    required double nilaiSosiometri,
  }) {
    return ((nilaiPengamatan * 7) + (nilaiSosiometri * 3)) / 10;
  }

  // ==========================================
  // C. KESEHATAN & JASMANI (Bobot 10% dari NAK)
  // ==========================================

  /// STEP 1: Hitung Nilai Kesehatan (N.Kes)
  static double hitungNKes({
    required double tesAwal,
    required double tesAkhir,
    required double statusKesehatan, // 80 - deduksi berobat/rawat
  }) {
    return (tesAwal + tesAkhir + statusKesehatan) / 3;
  }

  /// STEP 2b: Hitung Nilai Samapta B (NGB)
  static double hitungNGB({
    required double ngb1, // Pull Up
    required double ngb2, // Sit Up
    required double ngb3, // Push Up
    required double ngb4, // Shuttle Run
  }) {
    return (ngb1 + ngb2 + ngb3 + ngb4) / 4;
  }

  /// STEP 2c: Hitung Nilai Jasmani Akhir (N.Jas)
  static double hitungNJas({
    required double nga, // Nilai Samapta A (Lari 12 menit - dari tabel)
    required double ngb, // Nilai Samapta B
  }) {
    return (nga + ngb) / 2;
  }

  /// STEP 3: Hitung Nilai Kesjas Akhir (N.KJ)
  static double hitungNKJ({
    required double nKes,
    required double nJas,
  }) {
    return ((nKes * 4) + (nJas * 6)) / 10;
  }

  // ==========================================
  // D. NILAI AKHIR KESELURUHAN (NAK)
  // ==========================================

  /// STEP FINAL: Hitung NAK
  static double hitungNAK({
    required double na,  // Nilai Akademik (70%)
    required double nk,  // Nilai Kepribadian (20%)
    required double nkj, // Nilai Kesjas (10%)
  }) {
    return ((na * 70) + (nk * 20) + (nkj * 10)) / 100;
  }

  /// Mengembalikan informasi Klasifikasi berdasarkan NAK dan syarat kelulusan
  static Map<String, dynamic> dapatkanKlasifikasi({
    required double nak,
    required double na,
    required double nk,
    required double nkj,
  }) {
    bool isLulus = (na >= 70 && nk >= 70 && nkj >= 70);
    String status = isLulus ? 'LULUS' : 'TIDAK LULUS';

    String kode = '-';
    String klasifikasi = '-';
    String range = '-';

    if (nak >= 85.01) { // Asumsi range tertinggi
      kode = 'A';
      klasifikasi = 'SANGAT MEMUASKAN (SM)';
      range = '85.01 - 100';
    } else if (nak >= 80.01) {
      kode = 'B';
      klasifikasi = 'MEMUASKAN (M)';
      range = '80.01 - 85.00';
    } else if (nak >= 75.01) {
      kode = 'C';
      klasifikasi = 'BAIK (B)';
      range = '75.01 - 80.00';
    } else if (nak >= 70.00) {
      kode = 'D';
      klasifikasi = 'CUKUP (C)';
      range = '70.00 - 75.00';
    } else {
      kode = 'E';
      klasifikasi = 'KURANG (K)';
      range = '< 70.00';
    }

    // Jika nilai tidak memenuhi syarat per bidang, status menjadi tidak lulus meskipun rata-rata cukup
    if (!isLulus) {
      status = 'TIDAK LULUS (Nilai Bidang < 70)';
    }

    return {
      'nak': nak,
      'kode': kode,
      'klasifikasi': klasifikasi,
      'range': range,
      'status': status,
      'is_lulus': isLulus,
    };
  }
}
