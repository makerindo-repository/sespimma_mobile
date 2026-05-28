import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/assessment/presentation/pages/patun_academic_ews_history_screen.dart';

class PatunAcademicDetailScreen extends StatelessWidget {
  final Map<String, dynamic> serdik;

  const PatunAcademicDetailScreen({super.key, required this.serdik});

  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final name = serdik['nama_lengkap'] ?? '-';
    final noSerdik = serdik['no_serdik'] ?? '-';
    final pangkat = serdik['pangkat'] ?? '-';
    final double score = (serdik['_mock_score'] as double?) ?? 0.0;
    final String status = serdik['_mock_status'] ?? '-';
    final String? profilePhoto =
        serdik['profile_photo'] ?? serdik['profilePhoto'];

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Keterangan Akademik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(
                    name,
                    pangkat,
                    noSerdik,
                    status,
                    score,
                    profilePhoto,
                  ),
                  _buildEWSSection(context, status, score),
                  _buildAcademicScores(score, status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    String name,
    String pangkat,
    String noSerdik,
    String status,
    double score,
    String? profilePhoto,
  ) {
    Color statusColor;
    if (status == 'Aman') {
      statusColor = Colors.green.shade600;
    } else if (status == 'Warning') {
      statusColor = Colors.orange.shade600;
    } else {
      statusColor = Colors.red.shade600;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xl,
        vertical: AppDimensions.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _lightGrey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
              image: DecorationImage(
                image: (profilePhoto != null && profilePhoto.isNotEmpty)
                    ? FileImage(File(profilePhoto)) as ImageProvider
                    : const AssetImage('assets/images/default_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontXl,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  '$pangkat • No. Serdik: $noSerdik',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade500,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppDimensions.fontXs,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              score > 0 ? score.toStringAsFixed(1) : '-',
              style: TextStyle(
                fontSize: AppDimensions.fontXxl,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDynamicEWSActivities(
    String status,
    double score,
  ) {
    if (status == 'Aman') return [];

    final now = DateTime.now();

    String formatTimeStr(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    }

    String getDateStr(DateTime dt) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }

    final d1 = DateTime(now.year, now.month, now.day, 8, 30);
    final d2 = DateTime(now.year, now.month, now.day - 1, 9, 15);
    final d3 = DateTime(now.year, now.month, now.day - 3, 14, 10);

    if (status == 'Kritis') {
      return [
        {
          'title': 'Peringatan Kritis Akademik',
          'desc':
              'Nilai Ujian Esai Manajemen (${score.toStringAsFixed(1)}). Segera laksanakan penugasan ulang.',
          'sender': 'Sistem Akademik',
          'time': formatTimeStr(d1),
          'dateStr': getDateStr(d1),
          'dateTime': d1,
          'isCritical': true,
          'point': -score,
        },
        {
          'title': 'Peringatan Sistem',
          'desc':
              'Nilai akumulasi mingguan menurun drastis di bawah standar kelulusan.',
          'sender': 'Sistem Akademik',
          'time': formatTimeStr(d3),
          'dateStr': getDateStr(d3),
          'dateTime': d3,
          'isCritical': false,
          'point': -10.0,
        },
      ];
    } else {
      return [
        {
          'title': 'Peringatan Sistem',
          'desc':
              'Nilai Akademik (${score.toStringAsFixed(1)}) mendekati batas bawah. Perlu pemantauan.',
          'sender': 'Sistem Akademik',
          'time': formatTimeStr(d2),
          'dateStr': getDateStr(d2),
          'dateTime': d2,
          'isCritical': false,
          'point': -5.0,
        },
      ];
    }
  }

  Widget _buildEWSCard(
    BuildContext context,
    String title,
    String desc,
    String sender,
    String time,
    bool isCritical,
  ) {
    final iconColor = isCritical
        ? const Color(0xFFD32F2F)
        : const Color(0xFFF57C00);
    final bgColor = isCritical
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFFFF3E0);
    const iconData = AppIcons.warningCircleFill;
    final subtitle = '$desc - $sender';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(
                iconData,
                color: iconColor,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontLg,
                            fontWeight: FontWeight.w700,
                            color: _primaryNavy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Text(
                          isCritical ? 'Kritis' : 'Perhatian',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSm,
                            fontWeight: FontWeight.w700,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs / 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllActivities(
    BuildContext context,
    List<Map<String, dynamic>> activities,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PatunAcademicEwsHistoryScreen(initialActivities: activities),
      ),
    );
  }

  Widget _buildEWSSection(BuildContext context, String status, double score) {
    if (status == 'Aman') return const SizedBox.shrink();

    final activities = _getDynamicEWSActivities(status, score);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.xl,
        AppDimensions.xl,
        AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _primaryNavy,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  const Text(
                    'EARLY WARNING SYSTEM',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w800,
                      color: _primaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (activities.length > 1)
                TextButton(
                  onPressed: () => _showAllActivities(context, activities),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...activities
              .take(2)
              .map(
                (act) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: _buildEWSCard(
                    context,
                    (act['title'] as String?) ?? 'Early Warning System',
                    (act['desc'] as String?) ?? '-',
                    (act['sender'] as String?) ?? 'Sistem',
                    (act['time'] as String?) ?? '-',
                    (act['isCritical'] as bool?) ?? false,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildAcademicScores(double baseScore, String status) {
    double base = baseScore == 0 ? 0.0 : baseScore;

    double nkkpMateri = base == 0 ? 0 : (base + 0.5).clamp(0, 100);
    double nkkpPaparan = base == 0 ? 0 : (base - 0.2).clamp(0, 100);
    double nkkpKeaktifan = base == 0 ? 0 : (base + 0.8).clamp(0, 100);
    double nkkp =
        ((nkkpMateri * 35) + (nkkpPaparan * 35) + (nkkpKeaktifan * 30)) / 100;

    double npkpMateri = base == 0 ? 0 : (base + 0.1).clamp(0, 100);
    double npkpPaparan = base == 0 ? 0 : (base - 0.5).clamp(0, 100);
    double npkpKeaktifan = base == 0 ? 0 : (base + 0.4).clamp(0, 100);
    double npkp =
        ((npkpMateri * 35) + (npkpPaparan * 35) + (npkpKeaktifan * 30)) / 100;

    double nkpMateri = base == 0 ? 0 : (base - 0.8).clamp(0, 100);
    double nkpPaparan = base == 0 ? 0 : (base - 0.4).clamp(0, 100);
    double nkp = ((nkpMateri * 50) + (nkpPaparan * 50)) / 100;

    double ujianMp = base == 0 ? 0 : (base + 1.2).clamp(0, 100);
    double np = ((ujianMp * 30) + (nkkp * 5) + (npkp * 5) + (nkp * 60)) / 100;

    double nskAktif = base == 0 ? 0 : (base + 2.5).clamp(0, 100);
    double nskProduk = base == 0 ? 0 : (base + 1.5).clamp(0, 100);
    double nskRuang = base == 0 ? 0 : (base + 1.8).clamp(0, 100);
    double nsk = ((nskAktif * 60) + (nskProduk * 20) + (nskRuang * 20)) / 100;

    double ntMateri = base == 0 ? 0 : (base + 1.5).clamp(0, 100);
    double ntPenulisan = base == 0 ? 0 : (base + 0.5).clamp(0, 100);
    double ntPaparan = base == 0 ? 0 : (base + 2.0).clamp(0, 100);
    double nt = ((ntMateri * 40) + (ntPenulisan * 30) + (ntPaparan * 30)) / 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        0,
        AppDimensions.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.md,
              top: AppDimensions.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _primaryNavy,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                const Text(
                  'SELURUH NILAI AKADEMIK',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _buildScoreGroup('Nilai Pelajaran', '60%', np, [
            _buildScoreItem('Ujian Mata Pelajaran / Esai', '30%', ujianMp),
            _buildScoreGroup2('NKKP', '5%', nkkp, [
              _buildSubScoreItem('Materi & Penulisan', '35%', nkkpMateri),
              _buildSubScoreItem('Paparan', '35%', nkkpPaparan),
              _buildSubScoreItem('Keaktifan', '30%', nkkpKeaktifan),
            ]),
            _buildScoreGroup2('NPKP', '5%', npkp, [
              _buildSubScoreItem('Materi & Penulisan', '35%', npkpMateri),
              _buildSubScoreItem('Paparan', '35%', npkpPaparan),
              _buildSubScoreItem('Keaktifan', '30%', npkpKeaktifan),
            ]),
            _buildScoreGroup2('NKP', '60%', nkp, [
              _buildSubScoreItem('Materi & Penulisan', '50%', nkpMateri),
              _buildSubScoreItem('Paparan', '50%', nkpPaparan),
            ]),
          ]),
          const SizedBox(height: AppDimensions.md),
          _buildScoreGroup('Simulasi Kepemimpinan', '10%', nsk, [
            _buildSubScoreItem('Keaktifan Perseorangan', '60%', nskAktif),
            _buildSubScoreItem('Produk Perseorangan', '20%', nskProduk),
            _buildSubScoreItem('Tata Ruang Kelompok', '20%', nskRuang),
          ]),
          const SizedBox(height: AppDimensions.md),
          _buildScoreGroup('NPTT / Taskap', '30%', nt, [
            _buildSubScoreItem('Materi NPTT / Taskap', '40%', ntMateri),
            _buildSubScoreItem('Penulisan Efektif', '30%', ntPenulisan),
            _buildSubScoreItem('Paparan & Diskusi', '30%', ntPaparan),
          ]),
          const SizedBox(height: AppDimensions.lg),
          _buildRecommendationCard(baseScore, status),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(double score, String status) {
    bool isWarning = status != 'Aman';
    bool isExcellent = score >= 85.0;

    String insight;
    if (isWarning) {
      insight =
          'Berdasarkan analisis tren Akademik, Serdik mengalami penurunan performa secara spesifik pada pemahaman NPTT / Taskap. Disarankan bagi Patun untuk memberikan sesi bimbingan dan pendalaman materi ekstra.';
    } else if (isExcellent) {
      insight =
          'Performa Akademik Serdik sangat luar biasa dengan pemahaman konseptual yang tajam. Patun dapat mempertahankan ritme belajar Serdik untuk diarahkan menjadi Lulusan Terbaik.';
    } else {
      insight =
          'Nilai Akademik Serdik berada pada kondisi stabil dan baik. Patun disarankan untuk tetap memonitor fokus belajar Serdik, terutama pada simulasi kepemimpinan kontemporer untuk mendongkrak nilai ke tingkat maksimal.';
    }

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
                  'Rekomendasi Tindakan Patun',
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

  Color _getScoreColor(double s) {
    if (s == 0) return Colors.blueGrey.shade800;
    if (s > 85.00) return Colors.green.shade800;
    if (s > 80.00) return Colors.green.shade500;
    if (s > 75.00) return Colors.lime.shade700;
    if (s > 70.00) return Colors.amber.shade500;
    return Colors.red.shade700;
  }

  Widget _buildScoreGroup(
    String title,
    String weight,
    double score,
    List<Widget> children,
  ) {
    final scoreColor = _getScoreColor(score);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              color: _primaryNavy.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    weight,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXs,
                      fontWeight: FontWeight.w800,
                      color: _primaryNavy,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w800,
                      color: _primaryNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),

                Container(
                  constraints: const BoxConstraints(minWidth: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    score > 0 ? score.toStringAsFixed(1) : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGroup2(
    String title,
    String weight,
    double score,
    List<Widget> children,
  ) {
    final scoreColor = _getScoreColor(score);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_right_rounded,
                  size: 20,
                  color: _primaryNavy,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    weight,
                    style: TextStyle(
                      fontSize: AppDimensions.fontXs,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w700,
                      color: _primaryNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                Container(
                  constraints: const BoxConstraints(minWidth: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    score > 0 ? score.toStringAsFixed(1) : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSm,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.sm,
              0,
              AppDimensions.sm,
              AppDimensions.xs,
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String title, String weight, double score) {
    final scoreColor = _getScoreColor(score);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_right_rounded, size: 20, color: _primaryNavy),
          const SizedBox(width: AppDimensions.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              weight,
              style: TextStyle(
                fontSize: AppDimensions.fontXs,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey.shade600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.xs),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.w700,
                color: _primaryNavy,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimensions.xs),
          Container(
            constraints: const BoxConstraints(minWidth: 52),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              score > 0 ? score.toStringAsFixed(1) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScoreItem(String title, String weight, double score) {
    final scoreColor = _getScoreColor(score);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.xs,
        left: AppDimensions.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 5, color: Colors.blueGrey.shade400),
          const SizedBox(width: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF001C40).withValues(alpha: 0.05),
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
          const SizedBox(width: AppDimensions.xs),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimensions.xs),
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              score > 0 ? score.toStringAsFixed(1) : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontXs + 1,
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
