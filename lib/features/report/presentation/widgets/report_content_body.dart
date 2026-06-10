import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/ai_insight_card.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/detailed_competencies.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/nak_summary_card.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/score_category_row.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/score_line_chart.dart';
import 'package:sespimma_mobile/features/report/presentation/widgets/report_section_header.dart';
import 'package:sespimma_mobile/features/leadership_report/domain/services/score_calculator_service.dart';

class ReportContentBody extends StatelessWidget {
  final UserEntity user;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const ReportContentBody({
    super.key,
    required this.user,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final serdikId = user.noSerdik.isNotEmpty ? user.noSerdik : user.nrp;
    final rawScores = ScoreCalculatorService.generateSimulatedScores(serdikId);

    final serdikMap = {
      'id': serdikId,
      'name': user.name,
      'nrp': user.nrp,
      'nosis': user.noSerdik,
      'pokjar': user.pokjar,
      'pangkat': user.pangkat,
    };

    final recap = ScoreCalculatorService.calculateFinalRecap(
      serdikMap,
      rawScores,
    );

    final double dynamicAkademik = recap.academicScore;
    final double dynamicMentalScore = recap.mentalScore;
    final double dynamicJasmani = recap.physicalScore;
    final nak = recap.nak;

    return RefreshIndicator(
      color: AppColors.primaryNavy,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xl,
          vertical: AppDimensions.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NakSummaryCard(user: user, nak: nak),
            const SizedBox(height: AppDimensions.xxl),
            ScoreCategoryRow(
              nilaiAkademik: dynamicAkademik,
              nilaiMental: dynamicMentalScore,
              nilaiJasmani: dynamicJasmani,
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: AppDimensions.xxl + AppDimensions.md),
            const ReportSectionHeader(judul: 'Tren Perkembangan Terpadu'),
            const SizedBox(height: AppDimensions.md),
            ScoreLineChart(
              key: const ValueKey('integrated_trend_chart'),
              nilaiAkademik: dynamicAkademik,
              nilaiMental: dynamicMentalScore,
              nilaiJasmani: dynamicJasmani,
              selectedCategory: selectedCategory,
              noSerdik: user.noSerdik.isNotEmpty ? user.noSerdik : user.nrp,
            ),
            const SizedBox(height: AppDimensions.xxl + AppDimensions.md),
            const ReportSectionHeader(judul: 'Rincian Kompetensi'),
            const SizedBox(height: AppDimensions.md),
            _buildAnimatedChild(
              DetailedCompetencies(
                key: ValueKey<String>('details_$selectedCategory'),
                category: selectedCategory,
                recap: recap,
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
            _buildAnimatedChild(
              AiInsightCard(
                key: ValueKey<String>('insight_$selectedCategory'),
                category: selectedCategory,
                recap: recap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedChild(Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
