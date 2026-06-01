import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/core/data/serdik_mental_scores.dart';

class ScoreLineChart extends StatelessWidget {
  final double nilaiAkademik;
  final double nilaiMental;
  final double nilaiJasmani;
  final String selectedCategory;
  final String noSerdik;

  const ScoreLineChart({
    super.key,
    required this.nilaiAkademik,
    required this.nilaiMental,
    required this.nilaiJasmani,
    required this.selectedCategory,
    required this.noSerdik,
  });

  @override
  Widget build(BuildContext context) {
    const colorAka = Color(0xFF001C40);
    const colorMen = Color(0xFF10B981);
    const colorJas = Color(0xFFF59E0B);

    final bool hasWarning =
        (nilaiAkademik > 0 && nilaiAkademik < 70.0) ||
        (nilaiMental > 0 && nilaiMental < 70.0) ||
        (nilaiJasmani > 0 && nilaiJasmani < 70.0);

    final List<FlSpot> spotsAka = _generateSpots(nilaiAkademik, 'Akademik');
    final List<FlSpot> spotsMen = _generateSpots(
      nilaiMental,
      'Mental Kepribadian',
    );
    final List<FlSpot> spotsJas = _generateSpots(nilaiJasmani, 'Jasmani');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: AppDimensions.radiusXl,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(hasWarning, colorAka),
          const SizedBox(height: AppDimensions.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildLegendItem(
                  'Akademik',
                  _getScoreColor(nilaiAkademik, colorAka),
                  selectedCategory == 'Akademik',
                ),
                const SizedBox(width: AppDimensions.sm),
                _buildLegendItem(
                  'Mental Kepribadian',
                  _getScoreColor(nilaiMental, colorMen),
                  selectedCategory == 'Mental Kepribadian',
                ),
                const SizedBox(width: AppDimensions.sm),
                _buildLegendItem(
                  'Jasmani',
                  _getScoreColor(nilaiJasmani, colorJas),
                  selectedCategory == 'Jasmani',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),
          SizedBox(
            height: 200,
            child: _buildChart(
              spotsAka,
              spotsMen,
              spotsJas,
              colorAka,
              colorMen,
              colorJas,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasWarning, Color colorAka) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.sm + 2),
          decoration: BoxDecoration(
            color: hasWarning ? Colors.red.shade50 : Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Icon(
            hasWarning ? AppIcons.warningOctagonFill : AppIcons.sparkleFill,
            size: AppDimensions.iconSm,
            color: hasWarning ? Colors.red.shade600 : colorAka,
          ),
        ),
        const SizedBox(width: AppDimensions.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasWarning
                    ? 'Peringatan Tren Menurun (EWS)'
                    : 'Analisis Tren Perkembangan',
                style: TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w800,
                  color: hasWarning ? Colors.red.shade900 : colorAka,
                ),
              ),
              const SizedBox(height: AppDimensions.xs / 2),
              Text(
                selectedCategory == 'Mental Kepribadian'
                    ? 'Evaluasi Mingguan Terkini'
                    : 'Evaluasi Komprehensif Periode I - IV',
                style: TextStyle(
                  fontSize: AppDimensions.fontXs + 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LineChart _buildChart(
    List<FlSpot> sAka,
    List<FlSpot> sMen,
    List<FlSpot> sJas,
    Color cAka,
    Color cMen,
    Color cJas,
  ) {
    Color dynAka = _getScoreColor(nilaiAkademik, cAka);
    Color dynMen = _getScoreColor(nilaiMental, cMen);
    Color dynJas = _getScoreColor(nilaiJasmani, cJas);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 70.0,
              color: Colors.red.withValues(alpha: 0.35),
              strokeWidth: 1.5,
              dashArray: [6, 6],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                labelResolver: (_) => 'AMM (70)',
              ),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.fontSm,
                );
                String text = '';
                if (selectedCategory == 'Mental Kepribadian') {
                  if (value == 0.0) text = 'Mg 1';
                  if (value == 1.0) text = 'Mg 2';
                  if (value == 2.0) text = 'Mg 3';
                  if (value == 3.0) text = 'Mg 4';
                } else {
                  if (value == 0.0) text = 'Periode I';
                  if (value == 1.0) text = 'Periode II';
                  if (value == 2.0) text = 'Periode III';
                  if (value == 3.0) text = 'Periode IV';
                }
                if (text.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.fontSm,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: -0.1,
        maxX: 3.1,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          _buildLineBar(sAka, dynAka, 'Akademik'),
          _buildLineBar(sMen, dynMen, 'Mental Kepribadian'),
          _buildLineBar(sJas, dynJas, 'Jasmani'),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF001C40),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${_resolveLabel(spot.barIndex)} - ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontSm,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _resolveLabel(int barIndex) {
    if (barIndex == 0) return 'Akademik';
    if (barIndex == 1) return 'Mental';
    return 'Jasmani';
  }

  Color _getScoreColor(double score, Color defaultColor) {
    if (score == 0) return defaultColor;
    if (score >= 80.0) return Colors.green.shade700;
    if (score >= 70.0) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  LineChartBarData _buildLineBar(List<FlSpot> spots, Color color, String cat) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color.withValues(alpha: selectedCategory == cat ? 1.0 : 0.35),
      barWidth: selectedCategory == cat ? 4.0 : 2.2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: selectedCategory == cat,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: Colors.white,
          strokeWidth: 2.5,
          strokeColor: color,
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(double finalScore, String cat) {
    if (finalScore == 0) {
      return [
        const FlSpot(0, 0),
        const FlSpot(1, 0),
        const FlSpot(2, 0),
        const FlSpot(3, 0),
      ];
    }
    final bool isWarning = finalScore < 70.0;
    if (isWarning) {
      return [
        FlSpot(0, (finalScore + 5.8).clamp(0.0, 100.0)),
        FlSpot(1, (finalScore + 4.2).clamp(0.0, 100.0)),
        FlSpot(2, (finalScore + 1.8).clamp(0.0, 100.0)),
        FlSpot(3, finalScore),
      ];
    } else {
      if (cat == 'Akademik') {
        return [
          FlSpot(0, (finalScore - 4.5).clamp(0.0, 100.0)),
          FlSpot(1, (finalScore - 3.2).clamp(0.0, 100.0)),
          FlSpot(2, (finalScore - 1.2).clamp(0.0, 100.0)),
          FlSpot(3, finalScore),
        ];
      } else if (cat == 'Mental Kepribadian') {
        final scores = SerdikMentalScores.getScores(noSerdik);
        if (scores != null) {
          return [
            FlSpot(0, (scores['moral'] as num).toDouble()),
            FlSpot(1, (scores['disiplin'] as num).toDouble()),
            FlSpot(2, (scores['kepemimpinan'] as num).toDouble()),
            FlSpot(3, (scores['nilai'] as num).toDouble()),
          ];
        }
        return [
          FlSpot(0, (finalScore - 3.8).clamp(0.0, 100.0)),
          FlSpot(1, (finalScore - 3.2).clamp(0.0, 100.0)),
          FlSpot(2, (finalScore - 1.0).clamp(0.0, 100.0)),
          FlSpot(3, finalScore),
        ];
      } else {
        return [
          FlSpot(0, (finalScore - 2.5).clamp(0.0, 100.0)),
          FlSpot(1, (finalScore - 1.8).clamp(0.0, 100.0)),
          FlSpot(2, (finalScore - 0.6).clamp(0.0, 100.0)),
          FlSpot(3, finalScore),
        ];
      }
    }
  }

  Widget _buildLegendItem(String label, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm + 2,
        vertical: AppDimensions.xs + 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.08)
            : Colors.blueGrey.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm + 2),
        border: Border.all(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.xs + 2),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontXs,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? color : Colors.blueGrey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
