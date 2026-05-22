import 'package:flutter/material.dart';
import 'package:sespimma_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class AiInsightCard extends StatelessWidget {
  final String category;
  final UserEntity user;

  const AiInsightCard({super.key, required this.category, required this.user});

  @override
  Widget build(BuildContext context) {
    double score = 0.0;
    if (category == 'Mental Kepribadian') {
      score = user.nilaiMental;
    } else if (category == 'Akademik') {
      score = user.nilaiAkademik;
    } else {
      score = user.nilaiJasmani;
    }

    bool isWarning = score > 0 && score < 70.0;
    bool isExcellent = score >= 85.0;

    String insight = _getInsight(isWarning, isExcellent);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl - 4),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        border: Border.all(
          color: isWarning ? Colors.red.shade100 : Colors.blue.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: isWarning ? Colors.red.shade100 : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.sparkleFill,
              color: isWarning ? Colors.red.shade700 : Colors.blue.shade700,
              size: AppDimensions.iconSm,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi',
                  style: TextStyle(
                    color: isWarning
                        ? Colors.red.shade900
                        : Colors.blue.shade900,
                    fontSize: AppDimensions.fontSm,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  insight,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: AppDimensions.fontXs + 2,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInsight(bool isWarning, bool isExcellent) {
    if (category == 'Akademik') {
      if (isWarning) {
        return 'Berdasarkan analisis tren Akademik Anda, terdapat penurunan performa pada pemahaman NPTT / Taskap. AI menyarankan Anda untuk mengikuti sesi pendalaman materi ekstra bersama Mentor / Pengasuh.';
      }
      if (isExcellent) {
        return 'Performa Akademik Anda sangat luar biasa! Anda menunjukkan pemahaman konseptual yang tajam. Pertahankan ritme belajar ini untuk bisa meraih predikat Lulusan Terbaik.';
      }
      return 'Nilai Akademik Anda berada pada kondisi stabil dan baik. Tetap jaga fokus belajar, terutama pada simulasi kepemimpinan kontemporer untuk mendongkrak nilai ke tingkat maksimal.';
    } else if (category == 'Mental Kepribadian') {
      if (isWarning) {
        return 'Sistem mendeteksi adanya indikator kedisiplinan dan pengendalian diri yang perlu diperhatikan (EWS). Mohon untuk segera berkonsultasi secara intensif dengan Pengasuh.';
      }
      if (isExcellent) {
        return 'Karakter dan kepemimpinan Anda dinilai sangat inspiratif oleh rekan se-Pokjar (Sosiometri tinggi). Anda adalah role model yang baik dalam aspek Mental Kepribadian.';
      }
      return 'Aspek Mental Kepribadian Anda masuk kategori baik. Terus tingkatkan inisiatif dan interaksi positif Anda (Sosiometri) dengan rekan sejawat agar penilaian karakter semakin optimal.';
    } else {
      if (isWarning) {
        return 'Evaluasi Jasmani Anda saat ini berada di bawah standar minimum kelulusan. Segera perbaiki pola latihan fisik harian dan perhatikan asupan gizi untuk menghindari risiko kesehatan.';
      }
      if (isExcellent) {
        return 'Kondisi fisik dan Kesamaptaan Anda sangat prima! Ketahanan lari 12 menit Anda berada jauh di atas rata-rata Serdik lain. Pertahankan rutinitas olahraga mandiri Anda.';
      }
      return 'Nilai Jasmani Anda mencukupi standar dan stabil. Tambahkan porsi latihan kardio secara bertahap setiap sore untuk meningkatkan poin secara progresif pada Kesamaptaan A.';
    }
  }
}
