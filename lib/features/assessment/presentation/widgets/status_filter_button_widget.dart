import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';

class StatusFilterButtonWidget extends StatelessWidget {
  final String selectedStatus;
  final List<String> statuses;
  final ValueChanged<String> onSelected;

  const StatusFilterButtonWidget({
    super.key,
    required this.selectedStatus,
    required this.statuses,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilter = selectedStatus != 'Semua Status';
    return Container(
      height: AppDimensions.inputHeight,
      width: AppDimensions.inputHeight,
      decoration: BoxDecoration(
        color: hasActiveFilter
            ? AppColors.primaryNavy.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: hasActiveFilter ? AppColors.primaryNavy : Colors.grey.shade200,
          width: hasActiveFilter
              ? AppDimensions.borderWidthThick
              : AppDimensions.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: AppDimensions.xs,
            offset: const Offset(0, AppDimensions.xs / 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.filter_list_rounded,
          color:
              hasActiveFilter ? AppColors.primaryNavy : Colors.blueGrey.shade600,
          size: AppDimensions.iconDefault,
        ),
        tooltip: 'Filter Status Penilaian',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        position: PopupMenuPosition.under,
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return statuses.map((String filter) {
            final isSelected = selectedStatus == filter;
            return PopupMenuItem<String>(
              value: filter,
              child: Row(
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryNavy : Colors.black87,
                      fontSize: AppDimensions.fontDefault,
                    ),
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: AppDimensions.iconSm,
                      color: AppColors.primaryNavy,
                    ),
                  ],
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
