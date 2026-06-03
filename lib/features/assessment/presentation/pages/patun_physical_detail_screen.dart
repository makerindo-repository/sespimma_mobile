import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/assessment/presentation/pages/patun_physical_medical_history_screen.dart';

class PatunPhysicalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> serdik;

  const PatunPhysicalDetailScreen({super.key, required this.serdik});

  @override
  State<PatunPhysicalDetailScreen> createState() =>
      _PatunPhysicalDetailScreenState();
}

class _PatunPhysicalDetailScreenState extends State<PatunPhysicalDetailScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  late AnimationController _animController;

  static final List<Map<String, dynamic>> _mockMedicalRecords = [
    {
      'title': 'Kunjungan Poliklinik - Flu Ringan',
      'desc': 'Diberikan paracetamol & vitamin C. Istirahat 1 hari',
      'sender': 'dr. Sarah Dewi (Poliklinik Sespimma)',
      'time': '29 Mei 2026, 09:15 WIB',
      'category': 'Poliklinik',
      'dateStr': '29 Mei 2026',
      'date': DateTime(2026, 5, 29, 9, 15),
    },
    {
      'title': 'Tes Kesehatan Awal (A) Selesai',
      'desc': 'Parameter normal. Kolesterol sedikit di atas batas',
      'sender': 'Tim Medis Sespimma',
      'time': '15 Mei 2026, 08:00 WIB',
      'category': 'Tes Medis',
      'dateStr': '15 Mei 2026',
      'date': DateTime(2026, 5, 15, 8, 0),
    },
    {
      'title': 'Rawat Inap - ISPA',
      'desc': 'Dirawat selama 2 hari. Kondisi membaik',
      'sender': 'dr. Budi Santoso (RS Polri)',
      'time': '8 Mei 2026, 14:00 WIB',
      'category': 'Rawat Inap',
      'dateStr': '8 Mei 2026',
      'date': DateTime(2026, 5, 8, 14, 0),
    },
    {
      'title': 'Kunjungan Poliklinik - Sakit Kepala',
      'desc': 'Diberikan analgetik. Tidak perlu istirahat',
      'sender': 'dr. Sarah Dewi (Poliklinik Sespimma)',
      'time': '20 April 2026, 10:30 WIB',
      'category': 'Poliklinik',
      'dateStr': '20 April 2026',
      'date': DateTime(2026, 4, 20, 10, 30),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double s) {
    if (s == 0) return Colors.blueGrey.shade800;
    if (s > 85.00) return const Color(0xFF1B5E20);
    if (s > 80.00) return const Color(0xFF2E7D32);
    if (s > 75.00) return const Color(0xFF827717);
    if (s > 70.00) return const Color(0xFFF9A825);
    return const Color(0xFFB71C1C);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.serdik['nama_lengkap'] ?? '-';
    final noSerdik = widget.serdik['no_serdik'] ?? '-';
    final pangkat = widget.serdik['pangkat'] ?? '-';
    final double score = (widget.serdik['_mock_score'] as double?) ?? 0.0;
    final String status = widget.serdik['_mock_status'] ?? '-';
    final String? profilePhoto =
        widget.serdik['profile_photo'] ?? widget.serdik['profilePhoto'];

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Keterangan Jasmani',
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
          onPressed: () => Navigator.pop(context),
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
                  _buildHealthScoresSection(score),
                  _buildMedicalHistorySection(),
                  _buildPhysicalScoresSection(score),
                  _buildRecommendationSection(),
                  const SizedBox(height: AppDimensions.xxxl),
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
              score > 0 ? score.toStringAsFixed(2) : '-',
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

  Widget _buildSectionTitle(String title, [String? weight]) {
    return Row(
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
        if (weight != null && weight.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoresSection(double baseScore) {
    final double scoreA = (baseScore + 2).clamp(0, 100);
    final double scoreC = (baseScore - 2).clamp(0, 100);
    final double scoreB = (baseScore + 1.5).clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.xl,
        AppDimensions.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.md),
            child: _buildSectionTitle('SELURUH NILAI KESEHATAN', '40%'),
          ),
          _buildScoreGroup('Tes Kesehatan Awal (A)', '', scoreA, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Tes Kesehatan Akhir (B)', '', scoreB, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup(
            'Status Kesehatan Selama Pendidikan (C)',
            '',
            scoreC,
            [],
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
  }

  Widget _buildMedicalHistorySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.md,
        AppDimensions.xl,
        AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildSectionTitle('RIWAYAT CATATAN MEDIS')),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatunPhysicalMedicalHistoryScreen(
                        initialRecords: _mockMedicalRecords,
                      ),
                    ),
                  );
                },
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
          const SizedBox(height: AppDimensions.lg),
          ..._mockMedicalRecords
              .take(2)
              .map((item) => _buildMedicalRecordCard(item)),
        ],
      ),
    );
  }

  Color _categoryColor(String? category) {
    switch (category) {
      case 'Rawat Inap':
        return const Color(0xFFD32F2F);
      case 'Tes Medis':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFFF57C00);
    }
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'Rawat Inap':
        return Icons.local_hospital_rounded;
      case 'Tes Medis':
        return Icons.verified_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> item) {
    final String? category = item['category'] as String?;
    final Color color = _categoryColor(category);
    final Color bgColor = color.withValues(alpha: 0.1);
    final IconData icon = _categoryIcon(category);

    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_animController),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm + 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: AppDimensions.iconLg),
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
                              (item['title'] as String?) ?? '-',
                              style: const TextStyle(
                                fontSize: AppDimensions.fontLg,
                                fontWeight: FontWeight.w800,
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
                              category ?? '-',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSm,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        '${item['desc']} · ${item['sender']}',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs / 2),
                      Text(
                        (item['time'] as String?) ?? '-',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
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
        ),
      ),
    );
  }

  Widget _buildPhysicalScoresSection(double baseScore) {
    final double scoreA = (baseScore + 3).clamp(0, 100);
    final double scorePullUp = (baseScore - 1).clamp(0, 100);
    final double scoreSitUp = (baseScore + 1).clamp(0, 100);
    final double scorePushUp = baseScore.clamp(0, 100);
    final double scoreShuttle = (baseScore - 2).clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.xl,
        AppDimensions.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.md),
            child: _buildSectionTitle('SELURUH NILAI JASMANI', '60%'),
          ),
          _buildScoreGroup('Samapta A', '', scoreA, [
            _buildSubScoreItem('Lari / Jalan 12 Menit', scoreA),
          ]),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup(
            'Samapta B',
            '',
            ((scorePullUp + scoreSitUp + scorePushUp + scoreShuttle) / 4).clamp(
              0,
              100,
            ),
            [
              _buildSubScoreItem('Pull Up (1 menit)', scorePullUp),
              _buildSubScoreItem('Sit Up (1 menit)', scoreSitUp),
              _buildSubScoreItem('Push Up (1 menit)', scorePushUp),
              _buildSubScoreItem('Shuttle Run 6x10m', scoreShuttle),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
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
                if (weight.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
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
                ],
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
                    score > 0 ? score.toStringAsFixed(2) : '-',
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
          if (children.isNotEmpty)
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

  Widget _buildSubScoreItem(String title, double score) {
    final scoreColor = _getScoreColor(score);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.xs,
        left: AppDimensions.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 5, color: Colors.blueGrey.shade400),
          const SizedBox(width: AppDimensions.sm),
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
              score > 0 ? score.toStringAsFixed(2) : '-',
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

  Widget _buildRecommendationSection() {
    final String status = widget.serdik['_mock_status'] ?? 'Aman';
    final bool isWarning = status == 'Warning' || status == 'Kritis';
    final String insight = isWarning
        ? 'Perlu perhatian khusus. Evaluasi catatan medis menunjukkan adanya potensi penurunan jasmani (Samapta A) akibat seringnya kunjungan poli (Status C). Disarankan pantauan ketat dan program pemulihan terstruktur.'
        : 'Serdik menunjukkan performa jasmani (Samapta A) yang memuaskan. Namun, frekuensi kunjungan medis (Status C) perlu diperhatikan agar tidak berdampak pada akumulasi nilai kesehatan. Disarankan untuk memantau waktu istirahat dan suplemen harian Serdik.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: isWarning ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
                    'Rekomendasi Evaluasi Jasmani',
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
      ),
    );
  }
}
