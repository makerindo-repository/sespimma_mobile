import 'package:flutter/material.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class DetailedCompetencies extends StatelessWidget {
  final String category;
  final FinalRecapModel recap;

  const DetailedCompetencies({
    super.key,
    required this.category,
    required this.recap,
  });

  @override
  Widget build(BuildContext context) {
    if (category == 'Mental Kepribadian') {
      double ns = recap.rawScores['NS'] ?? 0.0;
      double pengamatan = recap.rawScores['NilaiPengamatan'] ?? 0.0;
      double sosiometriAwal = ns;
      double sosiometriAkhir = ns;

      double moral = recap.rawScores['moral_score'] ?? 0.0;
      double disiplin = recap.rawScores['disiplin_score'] ?? 0.0;
      double kepemimpinan = recap.rawScores['kepemimpinan_score'] ?? 0.0;
      double pengendalian = recap.rawScores['pengendalian_score'] ?? 0.0;
      double penampilan = recap.rawScores['penampilan_score'] ?? 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.sm),
          _SectionTitle(title: 'Nilai Pengamatan (70%)', score: pengamatan),
          _CompetencyItem(title: 'Moral (20%)', score: moral),
          _CompetencyItem(title: 'Disiplin (15%)', score: disiplin),
          _CompetencyItem(title: 'Kepemimpinan (20%)', score: kepemimpinan),
          _CompetencyItem(
            title: 'Pengendalian Diri (15%)',
            score: pengendalian,
          ),
          _CompetencyItem(title: 'Penampilan (15%)', score: penampilan),

          const SizedBox(height: AppDimensions.lg),
          _SectionTitle(title: 'Sosiometri (30%)', score: ns),
          _ExpandableCompetencyGroup(
            title: 'Penilaian Sosiometri Peleton (15%)',
            score: ns,
            children: [
              _SubCompetencyItem(
                title: 'Sosiometri Awal Pendidikan',
                score: sosiometriAwal,
              ),
              _SubCompetencyItem(
                title: 'Sosiometri Akhir Pendidikan',
                score: sosiometriAkhir,
              ),
            ],
          ),
        ],
      );
    } else if (category == 'Akademik') {
      double nkkp = recap.rawScores['NMPN'] ?? 0.0;
      double npkp = recap.rawScores['NMPN'] ?? 0.0;
      double nkp = recap.rawScores['NKa'] ?? 0.0;
      double ujianMp = recap.rawScores['NUMP'] ?? 0.0;
      double np =
          (ujianMp * 0.3) + (nkkp * 0.05) + (npkp * 0.05) + (nkp * 0.60);

      double nsk = recap.rawScores['NSK'] ?? 0.0;
      double nt = recap.rawScores['NPa'] ?? 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Nilai Pelajaran (60%)', score: np),
          _CompetencyItem(
            title: 'Ujian Mata Pelajaran atau Esai (30%)',
            score: ujianMp,
          ),
          _ExpandableCompetencyGroup(
            title: 'NKKP (5%)',
            score: nkkp,
            children: [
              _SubCompetencyItem(
                title: 'Materi dan Penulisan (35%)',
                score: nkkp,
              ),
              _SubCompetencyItem(title: 'Paparan (35%)', score: nkkp),
              _SubCompetencyItem(title: 'Keaktifan (30%)', score: nkkp),
            ],
          ),
          _ExpandableCompetencyGroup(
            title: 'NPKP (5%)',
            score: npkp,
            children: [
              _SubCompetencyItem(
                title: 'Materi dan Penulisan (35%)',
                score: npkp,
              ),
              _SubCompetencyItem(title: 'Paparan (35%)', score: npkp),
              _SubCompetencyItem(title: 'Keaktifan (30%)', score: npkp),
            ],
          ),
          _ExpandableCompetencyGroup(
            title: 'NKP (60%)',
            score: nkp,
            children: [
              _SubCompetencyItem(
                title: 'Materi dan Penulisan (50%)',
                score: nkp,
              ),
              _SubCompetencyItem(title: 'Paparan (50%)', score: nkp),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),
          _SectionTitle(title: 'Simulasi Kepemimpinan (10%)', score: nsk),
          _ExpandableCompetencyGroup(
            title: 'Komponen Simulasi',
            score: nsk,
            children: [
              _SubCompetencyItem(
                title: 'Keaktifan Perseorangan (60%)',
                score: nsk,
              ),
              _SubCompetencyItem(
                title: 'Produk Perseorangan (20%)',
                score: nsk,
              ),
              _SubCompetencyItem(
                title: 'Tata Ruang Kelompok (20%)',
                score: nsk,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),
          _SectionTitle(title: 'NPTT atau Taskap (30%)', score: nt),
          _ExpandableCompetencyGroup(
            title: 'Komponen NPTT atau Taskap',
            score: nt,
            children: [
              _SubCompetencyItem(
                title: 'Materi NPTT atau Taskap (40%)',
                score: nt,
              ),
              _SubCompetencyItem(title: 'Penulisan Efektif (30%)', score: nt),
              _SubCompetencyItem(title: 'Paparan dan Diskusi (30%)', score: nt),
            ],
          ),
        ],
      );
    } else {
      double kesehatan = recap.rawScores['NKes'] ?? 0.0;
      double jasmani = recap.rawScores['NJas'] ?? 0.0;

      double kesAwal = recap.rawScores['kes_awal'] ?? 0.0;
      double kesAkhir = recap.rawScores['kes_akhir'] ?? 0.0;
      double kesStatus = recap.rawScores['kes_status'] ?? 0.0;

      double samaptaA = recap.rawScores['NGA'] ?? 0.0;

      double pullUp = recap.rawScores['NGB1'] ?? 0.0;
      double sitUp = recap.rawScores['NGB2'] ?? 0.0;
      double pushUp = recap.rawScores['NGB3'] ?? 0.0;
      double shuttleRun = recap.rawScores['NGB4'] ?? 0.0;

      double samaptaB = (pullUp + sitUp + pushUp + shuttleRun) / 4;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Kesehatan (40%)', score: kesehatan),
          _ExpandableCompetencyGroup(
            title: 'Pemeriksaan dan Riwayat',
            score: kesehatan,
            children: [
              _SubCompetencyItem(
                title: 'Tes Kesehatan Awal (A)',
                score: kesAwal,
              ),
              _SubCompetencyItem(
                title: 'Tes Kesehatan Akhir (B)',
                score: kesAkhir,
              ),
              _SubCompetencyItem(
                title: 'Status Kesehatan Selama Pendidikan (C)',
                score: kesStatus,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),
          _SectionTitle(title: 'Jasmani (60%)', score: jasmani),
          _CompetencyItem(
            title: 'Samapta A (Lari atau Jalan 12 Menit)',
            score: samaptaA,
          ),
          _ExpandableCompetencyGroup(
            title: 'Samapta B',
            score: samaptaB,
            children: [
              _SubCompetencyItem(title: 'Pull Up (1 menit)', score: pullUp),
              _SubCompetencyItem(title: 'Sit Up (1 menit)', score: sitUp),
              _SubCompetencyItem(title: 'Push Up (1 menit)', score: pushUp),
              _SubCompetencyItem(
                title: 'Shuttle Run (6x10m)',
                score: shuttleRun,
              ),
            ],
          ),
        ],
      );
    }
  }
}

class _CompetencyItem extends StatelessWidget {
  final String title;
  final double score;

  const _CompetencyItem({required this.title, required this.score});

  String get _status {
    if (score == 0) return '-';
    if (score > 85.00) return 'Sangat Memuaskan (SM)';
    if (score > 80.00) return 'Memuaskan (M)';
    if (score > 75.00) return 'Baik (B)';
    if (score > 70.00) return 'Cukup (C)';
    return 'Kurang (K)';
  }

  Color get _borderColor {
    if (score == 0) return Colors.grey.shade100;
    if (score > 85.00) return Colors.green.shade200;
    if (score > 80.00) return Colors.lightGreen.shade200;
    if (score > 75.00) return Colors.orange.shade200;
    if (score > 70.00) return Colors.amber.shade200;
    return Colors.red.shade200;
  }

  Color get _iconBgColor {
    if (score == 0) return const Color(0xFFF0F4F8);
    if (score > 85.00) return Colors.green.shade50;
    if (score > 80.00) return Colors.lightGreen.shade50;
    if (score > 75.00) return Colors.orange.shade50;
    if (score > 70.00) return Colors.amber.shade50;
    return Colors.red.shade50;
  }

  Color get _iconColor {
    if (score == 0) return Colors.blueGrey.shade400;
    if (score > 85.00) return Colors.green.shade700;
    if (score > 80.00) return Colors.lightGreen.shade700;
    if (score > 75.00) return Colors.orange.shade700;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  Color get _statusColor {
    if (score == 0) return Colors.blueGrey.shade500;
    if (score > 85.00) return Colors.green.shade600;
    if (score > 80.00) return Colors.lightGreen.shade600;
    if (score > 75.00) return Colors.orange.shade600;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  Color get _scoreColor {
    if (score == 0) return const Color(0xFF001C40);
    if (score > 85.00) return Colors.green.shade700;
    if (score > 80.00) return Colors.lightGreen.shade700;
    if (score > 75.00) return Colors.orange.shade700;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  IconData get _iconData {
    if (score == 0) return AppIcons.minusCircle;
    if (score > 70.00) return AppIcons.checkCircle;
    return AppIcons.warningCircle;
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle = title;
    String? weight;
    if (title.contains('(') && title.contains(')')) {
      final start = title.lastIndexOf('(');
      final end = title.lastIndexOf(')');
      if (start < end && title.substring(start + 1, end).contains('%')) {
        weight = title.substring(start + 1, end);
        displayTitle = title.substring(0, start).trim();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        clipBehavior: Clip.antiAlias,
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
                  child: Icon(
                    _iconData,
                    color: _iconColor,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weight != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF001C40,
                                ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: Text(
                                weight,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF001C40),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                displayTitle,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSm,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF001C40),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          displayTitle,
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
                SizedBox(
                  width: 72,
                  child: Text(
                    score > 0 ? score.toStringAsFixed(2) : '-',
                    style: TextStyle(
                      fontSize: AppDimensions.fontXl,
                      fontWeight: FontWeight.w800,
                      color: _scoreColor,
                    ),
                    textAlign: TextAlign.center,
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

class _ExpandableCompetencyGroup extends StatelessWidget {
  final String title;
  final double score;
  final List<Widget> children;

  const _ExpandableCompetencyGroup({
    required this.title,
    required this.score,
    required this.children,
  });

  String get _status {
    if (score == 0) return '-';
    if (score > 85.00) return 'Sangat Memuaskan (SM)';
    if (score > 80.00) return 'Memuaskan (M)';
    if (score > 75.00) return 'Baik (B)';
    if (score > 70.00) return 'Cukup (C)';
    return 'Kurang (K)';
  }

  Color get _borderColor {
    if (score == 0) return Colors.grey.shade100;
    if (score > 85.00) return Colors.green.shade200;
    if (score > 80.00) return Colors.lightGreen.shade200;
    if (score > 75.00) return Colors.orange.shade200;
    if (score > 70.00) return Colors.amber.shade200;
    return Colors.red.shade200;
  }

  Color get _iconBgColor {
    if (score == 0) return const Color(0xFFF0F4F8);
    if (score > 85.00) return Colors.green.shade50;
    if (score > 80.00) return Colors.lightGreen.shade50;
    if (score > 75.00) return Colors.orange.shade50;
    if (score > 70.00) return Colors.amber.shade50;
    return Colors.red.shade50;
  }

  Color get _iconColor {
    if (score == 0) return Colors.blueGrey.shade400;
    if (score > 85.00) return Colors.green.shade700;
    if (score > 80.00) return Colors.lightGreen.shade700;
    if (score > 75.00) return Colors.orange.shade700;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  Color get _statusColor {
    if (score == 0) return Colors.blueGrey.shade500;
    if (score > 85.00) return Colors.green.shade600;
    if (score > 80.00) return Colors.lightGreen.shade600;
    if (score > 75.00) return Colors.orange.shade600;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  Color get _scoreColor {
    if (score == 0) return const Color(0xFF001C40);
    if (score > 85.00) return Colors.green.shade700;
    if (score > 80.00) return Colors.lightGreen.shade700;
    if (score > 75.00) return Colors.orange.shade700;
    if (score > 70.00) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  IconData get _iconData {
    if (score == 0) return AppIcons.minusCircle;
    if (score > 70.00) return AppIcons.checkCircle;
    return AppIcons.warningCircle;
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle = title;
    String? weight;
    if (title.contains('(') && title.contains(')')) {
      final start = title.lastIndexOf('(');
      final end = title.lastIndexOf(')');
      if (start < end && title.substring(start + 1, end).contains('%')) {
        weight = title.substring(start + 1, end);
        displayTitle = title.substring(0, start).trim();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.xl - 4,
              vertical: AppDimensions.sm,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppDimensions.xl - 4,
              0,
              AppDimensions.xl - 4,
              AppDimensions.md,
            ),
            iconColor: const Color(0xFF001C40),
            collapsedIconColor: Colors.blueGrey.shade400,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconData,
                    color: _iconColor,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (weight != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF001C40,
                                ).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: Text(
                                weight,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF001C40),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                displayTitle,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSm,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF001C40),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          displayTitle,
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
                SizedBox(
                  width: 72,
                  child: Text(
                    score > 0 ? score.toStringAsFixed(2) : '-',
                    style: TextStyle(
                      fontSize: AppDimensions.fontXl,
                      fontWeight: FontWeight.w800,
                      color: _scoreColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            children: [
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: AppDimensions.sm),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SubCompetencyItem extends StatelessWidget {
  final String title;
  final double score;

  const _SubCompetencyItem({required this.title, required this.score});

  Color get _scoreBgColor {
    if (score == 0) return Colors.blueGrey.shade50;
    if (score > 85.00) return Colors.green.shade50;
    if (score > 80.00) return Colors.lightGreen.shade50;
    if (score > 75.00) return Colors.orange.shade50;
    if (score > 70.00) return Colors.amber.shade50;
    return Colors.red.shade50;
  }

  Color get _scoreTextColor {
    if (score == 0) return const Color(0xFF001C40);
    if (score > 85.00) return Colors.green.shade800;
    if (score > 80.00) return Colors.lightGreen.shade800;
    if (score > 75.00) return Colors.orange.shade800;
    if (score > 70.00) return Colors.amber.shade900;
    return Colors.red.shade800;
  }

  Color get _iconColor {
    if (score == 0) return Colors.blueGrey.shade400;
    if (score > 85.00) return Colors.green.shade400;
    if (score > 80.00) return Colors.lightGreen.shade400;
    if (score > 75.00) return Colors.orange.shade400;
    if (score > 70.00) return Colors.amber.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    String displayTitle = title;
    String? weight;
    if (title.contains('(') && title.contains(')')) {
      final start = title.lastIndexOf('(');
      final end = title.lastIndexOf(')');
      if (start < end && title.substring(start + 1, end).contains('%')) {
        weight = title.substring(start + 1, end);
        displayTitle = title.substring(0, start).trim();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  AppIcons.circle,
                  size: AppDimensions.iconXs - 4,
                  color: _iconColor,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Row(
                    children: [
                      if (weight != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF001C40,
                            ).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            weight,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontXs - 1,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF001C40),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                      ],
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: TextStyle(
                            fontSize: AppDimensions.fontSm,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Container(
            width: 72,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _scoreBgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              score > 0 ? score.toStringAsFixed(2) : '-',
              style: TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.w800,
                color: _scoreTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final double score;

  const _SectionTitle({required this.title, required this.score});

  MaterialColor get _color {
    if (score == 0) return Colors.blueGrey;
    if (score > 85.00) return Colors.green;
    if (score > 80.00) return Colors.lightGreen;
    if (score > 75.00) return Colors.orange;
    if (score > 70.00) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    String displayTitle = title;
    String? weight;
    if (title.contains('(') && title.contains(')')) {
      final start = title.lastIndexOf('(');
      final end = title.lastIndexOf(')');
      if (start < end && title.substring(start + 1, end).contains('%')) {
        weight = title.substring(start + 1, end);
        displayTitle = title.substring(0, start).trim();
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xs,
        AppDimensions.sm,
        AppDimensions.xs,
        AppDimensions.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (weight != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001C40).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      weight,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontXs,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF001C40),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                ],
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF001C40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              score.toStringAsFixed(2),
              style: TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.w800,
                color: score == 0 ? const Color(0xFF001C40) : color.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
