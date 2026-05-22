import 'package:flutter/material.dart';
import 'package:sespimma_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class DetailedCompetencies extends StatelessWidget {
  final String category;
  final UserEntity user;

  const DetailedCompetencies({
    super.key,
    required this.category,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    double baseScore = 0.0;
    if (category == 'Mental Kepribadian') {
      baseScore = user.nilaiMental;
    } else if (category == 'Akademik') {
      baseScore = user.nilaiAkademik;
    } else {
      baseScore = user.nilaiJasmani;
    }

    bool isWarning = baseScore > 0 && baseScore < 70.0;

    double calc(double offset) {
      if (baseScore == 0) return 0.0;
      double s = baseScore + offset;
      if (s > 100) return 100.0;
      if (s < 0) return 0.0;
      return s;
    }

    if (category == 'Mental Kepribadian') {
      return Column(
        children: [
          _CompetencyItem(title: 'Moral (20%)', score: calc(isWarning ? -1.0 : 0.5)),
          _CompetencyItem(title: 'Disiplin (15%)', score: calc(isWarning ? -2.0 : -1.0)),
          _CompetencyItem(title: 'Kepemimpinan (20%)', score: calc(isWarning ? 1.5 : 1.2)),
          _CompetencyItem(title: 'Pengendalian Diri (15%)', score: calc(isWarning ? -0.5 : 0.0)),
          _CompetencyItem(title: 'Penampilan (15%)', score: calc(isWarning ? 2.0 : 1.8)),
          _CompetencyItem(title: 'Sosiometri Awal (7.5%)', score: calc(isWarning ? 0.5 : -0.5)),
          _CompetencyItem(title: 'Sosiometri Akhir (7.5%)', score: calc(isWarning ? 1.0 : 0.8)),
        ],
      );
    } else if (category == 'Akademik') {
      return Column(
        children: [
          _CompetencyItem(title: 'Ujian MP (30% - Pelajaran)', score: calc(isWarning ? -1.2 : -0.5)),
          _CompetencyItem(title: 'NKKP (5% - Pelajaran)', score: calc(isWarning ? 2.0 : 2.0)),
          _CompetencyItem(title: 'NPKP (5% - Pelajaran)', score: calc(isWarning ? 1.5 : 1.0)),
          _CompetencyItem(title: 'NKP (60% - Pelajaran)', score: calc(isWarning ? -0.8 : -0.8)),
          _CompetencyItem(title: 'Keaktifan (60% - Simulasi)', score: calc(isWarning ? 2.5 : 1.5)),
          _CompetencyItem(title: 'Produk (20% - Simulasi)', score: calc(isWarning ? 0.5 : 0.0)),
          _CompetencyItem(title: 'Tata Ruang (20% - Simulasi)', score: calc(isWarning ? 1.0 : 0.5)),
          _CompetencyItem(title: 'Materi (40% - Taskap)', score: calc(isWarning ? 3.0 : 0.5)),
          _CompetencyItem(title: 'Menulis (30% - Taskap)', score: calc(isWarning ? 1.0 : -0.2)),
          _CompetencyItem(title: 'Paparan (30% - Taskap)', score: calc(isWarning ? 2.5 : 0.8)),
        ],
      );
    } else {
      return Column(
        children: [
          _CompetencyItem(title: 'Tes Kesehatan Awal', score: calc(isWarning ? -1.5 : -1.2)),
          _CompetencyItem(title: 'Tes Kesehatan Akhir', score: calc(isWarning ? -0.8 : 0.2)),
          _CompetencyItem(title: 'Status Kesehatan', score: calc(isWarning ? 0.0 : 0.5)),
          _CompetencyItem(title: 'Samapta A (Lari 12 Menit)', score: calc(isWarning ? 2.5 : 0.8)),
          _CompetencyItem(title: 'Samapta B (Pull-up)', score: calc(isWarning ? 1.2 : 1.0)),
          _CompetencyItem(title: 'Samapta B (Sit-up)', score: calc(isWarning ? 2.0 : 1.5)),
          _CompetencyItem(title: 'Samapta B (Push-up)', score: calc(isWarning ? 1.5 : 1.2)),
          _CompetencyItem(title: 'Samapta B (Shuttle Run)', score: calc(isWarning ? 0.5 : 0.5)),
        ],
      );
    }
  }
}

class _CompetencyItem extends StatelessWidget {
  final String title;
  final double score;

  const _CompetencyItem({
    required this.title,
    required this.score,
  });

  String get _status {
    if (score == 0) return '-';
    if (score > 85.00) return 'Sangat Memuaskan';
    if (score > 80.00) return 'Memuaskan';
    if (score > 75.00) return 'Baik';
    if (score > 70.00) return 'Cukup';
    return 'Tidak Lulus';
  }

  Color get _borderColor {
    if (score == 0) return Colors.grey.shade100;
    if (score >= 80.0) return Colors.green.shade200;
    if (score >= 70.0) return Colors.amber.shade200;
    return Colors.red.shade200;
  }

  Color get _iconBgColor {
    if (score == 0) return const Color(0xFFF0F4F8);
    if (score >= 80.0) return Colors.green.shade50;
    if (score >= 70.0) return Colors.amber.shade50;
    return Colors.red.shade50;
  }

  Color get _iconColor {
    if (score == 0) return Colors.blueGrey.shade400;
    if (score >= 80.0) return Colors.green.shade700;
    if (score >= 70.0) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  Color get _statusColor {
    if (score == 0) return Colors.blueGrey.shade500;
    if (score >= 80.0) return Colors.green.shade600;
    if (score >= 70.0) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  Color get _scoreColor {
    if (score == 0) return const Color(0xFF001C40);
    if (score >= 80.0) return Colors.green.shade700;
    if (score >= 70.0) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  IconData get _iconData {
    if (score == 0) return AppIcons.minusCircle;
    if (score >= 80.0) return AppIcons.checkCircle;
    return AppIcons.warningCircle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: AppDimensions.radiusLg,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl - 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconData, color: _iconColor, size: AppDimensions.iconMd),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF001C40),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: AppDimensions.fontXs + 2,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  score > 0 ? score.toStringAsFixed(1) : '-',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXl,
                    fontWeight: FontWeight.w800,
                    color: _scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
