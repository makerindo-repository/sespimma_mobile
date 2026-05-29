import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/data/serdik_mental_scores.dart';
import 'package:sespimma_mobile/core/data/serdik_senat_roles.dart';
import 'package:sespimma_mobile/features/assessment/presentation/pages/patun_mental_activity_history_screen.dart';
import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sespimma_mobile/shared/widgets/evidence_bottom_sheet.dart';

class PatunMentalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> serdik;

  const PatunMentalDetailScreen({super.key, required this.serdik});

  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  List<Map<String, dynamic>> _getDynamicActivities() {
    final rewards = RewardPunishmentData.rewards;
    final punishments = RewardPunishmentData.punishments;
    final now = DateTime.now();

    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';

    String dateStr(DateTime dt) {
      const m = [
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
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    }

    final d1 = DateTime(now.year, now.month, now.day, 8, 30);
    final d2 = DateTime(now.year, now.month, now.day - 1, 6, 15);
    final d3 = DateTime(now.year, now.month, now.day - 2, 14, 0);
    final d4 = DateTime(now.year, now.month, now.day - 10, 9, 0);

    return [
      {
        'title': rewards.isNotEmpty
            ? rewards[0].description
            : 'Pujian Tertulis',
        'desc': 'Diberikan oleh Patun Kelas',
        'justification':
            'Serdik menunjukkan inisiatif tinggi dengan sukarela membantu rekan seangkatannya yang mengalami kesulitan selama masa perkuliahan tanpa diminta.',
        'sender': 'Patun Kelas',
        'time': fmt(d1),
        'dateStr': dateStr(d1),
        'dateTime': d1,
        'isReward': true,
        'point': rewards.isNotEmpty ? rewards[0].point : 0.25,
      },
      {
        'title': punishments.isNotEmpty
            ? punishments[0].description
            : 'Teguran Lisan',
        'desc': 'Diberikan oleh Piket Batalyon',
        'justification':
            'Serdik tidak mengindahkan peringatan dari piket terkait kerapian seragam dan tata rambut saat pelaksanaan apel pagi.',
        'sender': 'Piket Batalyon',
        'time': fmt(d2),
        'dateStr': dateStr(d2),
        'dateTime': d2,
        'isReward': false,
        'point': punishments.isNotEmpty ? punishments[0].point : -0.70,
      },
      {
        'title': rewards.length > 2 ? rewards[2].description : 'Pujian Lisan',
        'desc': 'Diberikan oleh Gadik',
        'justification':
            'Serdik memberikan kontribusi yang signifikan melalui gagasan visioner saat simulasi pemecahan masalah operasional kepolisian.',
        'sender': 'Gadik',
        'time': fmt(d3),
        'dateStr': dateStr(d3),
        'dateTime': d3,
        'isReward': true,
        'point': rewards.length > 2 ? rewards[2].point : 0.25,
      },
      {
        'title': punishments.length > 1
            ? punishments[1].description
            : 'Teguran Tertulis',
        'desc': 'Diberikan oleh Patun Kelas',
        'justification':
            'Serdik mengulangi kesalahan fatal terkait pelanggaran batas waktu kehadiran setelah sebelumnya sudah mendapat teguran lisan.',
        'sender': 'Patun Kelas',
        'time': fmt(d4),
        'dateStr': dateStr(d4),
        'dateTime': d4,
        'isReward': false,
        'point': punishments.length > 1 ? punishments[1].point : -0.30,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final String name = (serdik['nama_lengkap'] as String?) ?? '-';
    final String noSerdik = (serdik['no_serdik'] as String?) ?? '-';
    final String pangkat = (serdik['pangkat'] as String?) ?? '-';
    final String? profilePhoto =
        serdik['profile_photo'] ?? serdik['profilePhoto'];

    final realScores = SerdikMentalScores.getScores(noSerdik);
    final double score = realScores != null
        ? (realScores['nilai'] as num).toDouble()
        : (serdik['_mock_score'] as num?)?.toDouble() ?? 80.0;

    final String status;
    if (score >= 80.0) {
      status = 'Aman';
    } else if (score >= 70.0) {
      status = 'Warning';
    } else {
      status = 'Kritis';
    }

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Keterangan Mental',
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
                  _buildMentalTrendChart(),
                  _buildActivityHistory(context),
                  _buildMentalScores(noSerdik, score, status),
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
    final Color statusColor;
    final IconData statusIcon;
    final String? senatRole = SerdikSenatRoles.getRole(noSerdik);
    if (status == 'Aman') {
      statusColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'Warning') {
      statusColor = const Color(0xFFF57C00);
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = const Color(0xFFD32F2F);
      statusIcon = Icons.error_rounded;
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
            width: 72,
            height: 72,
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
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  '$pangkat · $noSerdik',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
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
                    if (senatRole != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1A237E,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFF1A237E,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: Color(0xFF1A237E),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              senatRole,
                              style: const TextStyle(
                                fontSize: AppDimensions.fontXs,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A237E),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NILAI',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXs,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  score > 0 ? score.toStringAsFixed(2) : '-',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXxl,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalTrendChart() {
    final double score = (serdik['_mock_score'] as num?)?.toDouble() ?? 80.0;

    String insightText = '';
    String badgeText = '';
    Color insightColor;
    Color insightBgColor;
    IconData insightIcon;

    if (score < 70) {
      insightText = 'Perlu perhatian khusus';
      badgeText = 'Kritis';
      insightColor = Colors.red.shade700;
      insightBgColor = Colors.red.shade50;
      insightIcon = Icons.warning_rounded;
    } else if (score < 76) {
      insightText = 'Mulai menunjukkan penurunan';
      badgeText = 'Warning';
      insightColor = Colors.orange.shade700;
      insightBgColor = Colors.orange.shade50;
      insightIcon = Icons.info_outline_rounded;
    } else {
      insightText = 'Perkembangan mental stabil';
      badgeText = 'Aman';
      insightColor = Colors.green.shade700;
      insightBgColor = Colors.green.shade50;
      insightIcon = Icons.trending_up_rounded;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                'TREN PERKEMBANGAN MENTAL',
                style: TextStyle(
                  fontSize: AppDimensions.fontLg,
                  fontWeight: FontWeight.w800,
                  color: _primaryNavy,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 60,
                      maxY: 100,
                      minX: 0,
                      maxX: 3,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => _primaryNavy,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              return LineTooltipItem(
                                touchedSpot.y.toStringAsFixed(2),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 10,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final titles = ['W1', 'W2', 'W3', 'W4'];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < titles.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    titles[value.toInt()],
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                      fontSize: AppDimensions.fontXs,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 70,
                            color: Colors.red.shade400,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(
                                right: 5,
                                bottom: 5,
                              ),
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                              labelResolver: (line) => 'AMM (70)',
                            ),
                          ),
                        ],
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 80),
                            FlSpot(1, 85),
                            FlSpot(2, 75),
                            FlSpot(3, 82.5),
                          ],
                          isCurved: true,
                          color: _primaryNavy,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: _primaryNavy,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _primaryNavy.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: insightBgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(insightIcon, color: insightColor),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          insightText,
                          style: TextStyle(
                            fontSize: AppDimensions.fontSm,
                            fontWeight: FontWeight.w700,
                            color: insightColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: insightColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontXs,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHistory(BuildContext context) {
    final activities = _getDynamicActivities();
    final displayList = activities.take(2).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    'RIWAYAT AKTIVITAS',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w800,
                      color: _primaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (activities.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatunMentalActivityHistoryScreen(
                          initialActivities: activities,
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
          const SizedBox(height: AppDimensions.md),
          if (displayList.isEmpty)
            _buildEmptyActivity()
          else
            ...displayList.map(
              (act) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: _buildActivityCard(
                  context,
                  (act['title'] as String?) ?? 'Aktivitas Mental',
                  (act['desc'] as String?) ?? '-',
                  (act['justification'] as String?) ?? '-',
                  (act['sender'] as String?) ?? '-',
                  (act['time'] as String?) ?? '-',
                  (act['isReward'] as bool?) ?? true,
                  (act['point'] as num?)?.toDouble() ?? 0.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Belum ada riwayat aktivitas',
            style: TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String desc,
    String justification,
    String sender,
    String time,
    bool isReward,
    double point,
  ) {
    final iconColor = isReward
        ? const Color(0xFF1B5E20)
        : const Color(0xFFB71C1C);
    final bgColor = isReward
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);
    final iconData = isReward ? AppIcons.thumbUp : AppIcons.thumbDown;
    final pointsStr = point > 0
        ? '+${point.toStringAsFixed(2)}'
        : point.toStringAsFixed(2);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: bgColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: () {
            EvidenceBottomSheet.show(
              context,
              title: title,
              description: justification,
              evaluatorName: sender,
              timeText: time,
              points: pointsStr,
              type: isReward ? 'reward' : 'punishment',
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w700,
                          color: _primaryNavy,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$desc · $sender',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    pointsStr,
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMentalScores(String noSerdik, double baseScore, String status) {
    final scores = SerdikMentalScores.getScores(noSerdik);
    final double base = baseScore == 0 ? 0.0 : baseScore;

    final double moral = scores != null
        ? (scores['moral'] as num).toDouble()
        : (base + 1.2).clamp(0, 100);
    final double disiplin = scores != null
        ? (scores['disiplin'] as num).toDouble()
        : (base + 0.5).clamp(0, 100);
    final double kepemimpinan = scores != null
        ? (scores['kepemimpinan'] as num).toDouble()
        : (base - 0.2).clamp(0, 100);
    final double pengendalianDiri = scores != null
        ? (scores['pengendalian_diri'] as num).toDouble()
        : (base + 1.5).clamp(0, 100);
    final double penampilan = scores != null
        ? (scores['penampilan'] as num).toDouble()
        : (base - 1.0).clamp(0, 100);
    final double sosiometriAwal = scores != null
        ? (scores['sosiometri_awal'] as num).toDouble()
        : (base - 2).clamp(0, 100);
    final double sosiometriAkhir = scores != null
        ? (scores['sosiometri_akhir'] as num).toDouble()
        : (base + 2).clamp(0, 100);
    final double sosiometri = (sosiometriAwal + sosiometriAkhir) / 2;

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
                const Expanded(
                  child: Text(
                    'SELURUH NILAI MENTAL KEPRIBADIAN',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w800,
                      color: _primaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildScoreGroup('Moral', '20%', moral, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Disiplin', '15%', disiplin, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Kepemimpinan', '20%', kepemimpinan, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Pengendalian Diri', '15%', pengendalianDiri, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Penampilan', '15%', penampilan, []),
          const SizedBox(height: AppDimensions.sm),
          _buildScoreGroup('Sosiometri', '15%', sosiometri, [
            _buildSubScoreItem('Sosiometri Awal', sosiometriAwal),
            _buildSubScoreItem('Sosiometri Akhir', sosiometriAkhir),
          ]),
          const SizedBox(height: AppDimensions.lg),
          _buildRecommendationCard(baseScore, status),
          const SizedBox(height: AppDimensions.xxl),
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

  Widget _buildRecommendationCard(double score, String status) {
    final isWarning = status != 'Aman';
    final isExcellent = score >= 85.0;

    final String insight;
    if (isWarning) {
      insight =
          'Sistem mendeteksi adanya indikator kedisiplinan dan pengendalian diri yang perlu diperhatikan. Mohon segera berkonsultasi secara intensif dengan Pengasuh/Patun.';
    } else if (isExcellent) {
      insight =
          'Karakter dan kepemimpinan Serdik dinilai sangat inspiratif oleh rekan se-Pokjar (Sosiometri tinggi). Serdik adalah role model yang baik dalam aspek Mental Kepribadian.';
    } else {
      insight =
          'Aspek Mental Kepribadian Serdik masuk kategori baik. Terus tingkatkan inisiatif dan interaksi positif (Sosiometri) dengan rekan sejawat agar penilaian karakter semakin optimal.';
    }

    return Container(
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
                  'Rekomendasi Karakter',
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
    if (s > 85.00) return const Color(0xFF1B5E20);
    if (s > 80.00) return const Color(0xFF2E7D32);
    if (s > 75.00) return const Color(0xFF827717);
    if (s > 70.00) return const Color(0xFFF9A825);
    return const Color(0xFFB71C1C);
  }
}
