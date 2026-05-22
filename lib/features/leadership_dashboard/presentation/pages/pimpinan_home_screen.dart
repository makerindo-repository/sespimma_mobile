import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/presentation/pages/notification_screen.dart';
import '../../data/datasources/pimpinan_mock_data.dart';
import '../../data/models/pokjar_stats_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

class PimpinanHomeScreen extends StatefulWidget {
  const PimpinanHomeScreen({super.key});

  @override
  State<PimpinanHomeScreen> createState() => _PimpinanHomeScreenState();
}

class _PimpinanHomeScreenState extends State<PimpinanHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  bool _animateBars = false;

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);
  static const Color _academicBlue = Color(0xFF1976D2);
  static const Color _mentalOrange = Color(0xFFF57C00);
  static const Color _physicalGreen = Color(0xFF2E7D32);
  static const Color _warningColor = Color(0xFFD32F2F);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _successGreen = Color(0xFF2E7D32);

  List<PokjarStatsModel> get _pokjarData {
    return PimpinanMockData.getPokjarAverages().map((e) {
      return PokjarStatsModel(
        id: e['name'],
        namaPokjar: e['name'],
        rataRataNilai: e['average'],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController?.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animateBars = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required double beginInterval,
    required double endInterval,
  }) {
    if (_animController == null) return child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController!,
          curve: Interval(beginInterval, endInterval, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animController!,
                curve: Interval(
                  beginInterval,
                  endInterval,
                  curve: Curves.easeOutQuart,
                ),
              ),
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;

            return SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: () async =>
                    await Future.delayed(const Duration(seconds: 1)),
                color: _primaryNavy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedSection(
                        child: _buildHeader(context, user),
                        beginInterval: 0.0,
                        endInterval: 0.3,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Column(
                          children: [
                            _buildAnimatedSection(
                              child: _buildGeneralStats(context),
                              beginInterval: 0.1,
                              endInterval: 0.4,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _buildAnimatedSection(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _buildPieChartSection(),
                              ),
                              beginInterval: 0.2,
                              endInterval: 0.5,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _buildAnimatedSection(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _buildBarChartSection(),
                              ),
                              beginInterval: 0.3,
                              endInterval: 0.6,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _buildAnimatedSection(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _buildAiRecommendation(),
                              ),
                              beginInterval: 0.4,
                              endInterval: 0.7,
                            ),
                            const SizedBox(height: AppDimensions.xl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: _primaryNavy),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    final name = user.name.split(',').first;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 16, 24, 60),
      decoration: const BoxDecoration(
        color: _primaryNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.xs / 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: _lightGrey,
              backgroundImage:
                  (user.profilePhoto != null && user.profilePhoto!.isNotEmpty)
                  ? FileImage(File(user.profilePhoto!)) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: TextStyle(
                    color: Colors.blueGrey.shade200,
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs / 2),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontXl,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Text(
                    'PIMPINAN SESPIMMA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderIcon(
            icon: AppIcons.bell,
            count: '3',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: Badge(
          backgroundColor: _dangerRed,
          label: Text(
            count,
            style: const TextStyle(
              fontSize: AppDimensions.fontSm,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.sm + 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppDimensions.iconDefault + 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralStats(BuildContext context) {
    final int totalSerdik = PimpinanMockData.sharedReportData.length;
    final double avgScore =
        _pokjarData.fold<double>(0, (s, e) => s + e.rataRataNilai) /
        _pokjarData.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ringkasan Eksekutif',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                  ),
                ),
                Icon(
                  AppIcons.squaresFourFill,
                  color: Colors.blueGrey.shade200,
                  size: AppDimensions.iconMd,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildStatTile(
                  'Total Serdik',
                  totalSerdik.toString(),
                  AppIcons.usersFill,
                  _academicBlue,
                ),
                _buildStatTile(
                  'Rata-rata',
                  avgScore.toStringAsFixed(1),
                  AppIcons.chartLineUpFill,
                  _successGreen,
                ),
                _buildStatTile(
                  'Pokjar Aktif',
                  _pokjarData.length.toString(),
                  AppIcons.treeStructureFill,
                  _mentalOrange,
                ),
                _buildStatTile(
                  'Laporan Absensi',
                  PimpinanMockData.attendanceReportCount.toString(),
                  AppIcons.clipboardTextFill,
                  _primaryNavy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconDefault),
          const SizedBox(height: AppDimensions.radiusSm),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDimensions.fontXl,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    final double avgScore =
        _pokjarData.fold<double>(0, (s, e) => s + e.rataRataNilai) /
        _pokjarData.length;

    final compAverages = PimpinanMockData.getGlobalComponentAverages();
    final double akademik = compAverages['akademik']!;
    final double mental = compAverages['mental']!;
    final double jasmani = compAverages['jasmani']!;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl - 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Komposisi Nilai',
                style: TextStyle(
                  fontSize: AppDimensions.fontLg,
                  fontWeight: FontWeight.w800,
                  color: _primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.trendUpFill, size: 10, color: _successGreen),
                    const SizedBox(width: AppDimensions.xs),
                    const Text(
                      'Stabil',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: 120,
            height: 120,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DonutChartPainter(
                  values: [akademik * 0.70, mental * 0.20, jasmani * 0.10],
                  colors: const [_academicBlue, _mentalOrange, _physicalGreen],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        avgScore.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: AppDimensions.fontHuge + 2,
                          fontWeight: FontWeight.w900,
                          color: _primaryNavy,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCenteredLegendItem(
                'Akademik (70%)',
                akademik.toStringAsFixed(1),
                _academicBlue,
              ),
              _buildCenteredLegendItem(
                'Mental (20%)',
                mental.toStringAsFixed(1),
                _mentalOrange,
              ),
              _buildCenteredLegendItem(
                'Jasmani (10%)',
                jasmani.toStringAsFixed(1),
                _physicalGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.fontLg + 1,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey.shade500,
              ),
            ),
          ],
        ),
        Text(
          _calculateKontribusi(label, value),
          style: TextStyle(
            fontSize: AppDimensions.fontXs,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade300,
          ),
        ),
      ],
    );
  }

  String _calculateKontribusi(String label, String value) {
    double multiplier = 0.1;
    if (label.contains('70')) {
      multiplier = 0.7;
    } else if (label.contains('20')) {
      multiplier = 0.2;
    }

    return '(Kontribusi: ${(double.parse(value) * multiplier).toStringAsFixed(1)})';
  }

  Widget _buildBarChartSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analisis Pokjar',
            style: TextStyle(
              fontSize: AppDimensions.fontLg + 1,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          ..._pokjarData.map((data) => _buildBarRow(data)),
        ],
      ),
    );
  }

  Widget _buildBarRow(PokjarStatsModel data) {
    final bool isWarning = data.rataRataNilai < 76.0;
    final Color color = isWarning ? _warningColor : _academicBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.namaPokjar,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w700,
                  color: _primaryNavy,
                ),
              ),
              Text(
                data.rataRataNilai.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.radiusSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            child: LinearProgressIndicator(
              value: _animateBars ? data.rataRataNilai / 100 : 0,
              backgroundColor: Colors.blueGrey.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendation() {
    final lowest = _pokjarData.reduce(
      (a, b) => a.rataRataNilai < b.rataRataNilai ? a : b,
    );
    final bool hasRisk = lowest.rataRataNilai < 76.0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl - 4),
      decoration: BoxDecoration(
        color: hasRisk
            ? _dangerRed.withValues(alpha: 0.05)
            : _academicBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        border: Border.all(
          color: hasRisk
              ? _dangerRed.withValues(alpha: 0.1)
              : _academicBlue.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasRisk ? AppIcons.warningFill : AppIcons.sparkleFill,
            color: hasRisk ? _dangerRed : _academicBlue,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRisk ? 'Prioritas Perhatian' : 'Rekomendasi Sistem',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                    color: hasRisk ? _dangerRed : _primaryNavy,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  hasRisk
                      ? 'Pokjar ${lowest.namaPokjar} memerlukan atensi khusus karena capaian rata-rata berada di bawah standar kelulusan.'
                      : 'Kualitas pembelajaran angkatan ini sangat stabil. Fokus pada pemeliharaan performa hingga evaluasi akhir.',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade700,
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
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (sum, item) => sum + item);
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint bgPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    double startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    if (oldDelegate.values.length != values.length ||
        oldDelegate.colors.length != colors.length) {
      return true;
    }
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i] ||
          oldDelegate.colors[i] != colors[i]) {
        return true;
      }
    }
    return false;
  }
}
