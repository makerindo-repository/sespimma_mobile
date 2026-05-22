import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class AiRecommendationCard extends StatelessWidget {
  final String selectedPokjar;

  const AiRecommendationCard({super.key, required this.selectedPokjar});

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF0C4A6E);
    const Color bgColor = Color(0xFFF0F9FF);
    const Color borderColor = Color(0xFFBAE6FD);
    const Color iconBgColor = Color(0xFFE0F2FE);
    const Color iconColor = Color(0xFF0284C7);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm + 2),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.sparkleFill,
              color: iconColor,
              size: AppDimensions.iconDefault,
            ),
          ),
          const SizedBox(width: AppDimensions.md - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekomendasi',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Berdasarkan tren data nilai saat ini${selectedPokjar == 'Semua Pokjar' ? ' secara keseluruhan' : ' di $selectedPokjar'}, Serdik yang berada pada batas EWS membutuhkan pendampingan mental khusus sebelum tahap akhir penugasan.',
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
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
