import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import '../../data/models/assignment_model.dart';

class TaskCard extends StatelessWidget {
  final AssignmentModel assignment;

  const TaskCard({super.key, required this.assignment});

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _warningOrange = Color(0xFFF57C00);
  static const Color _successGreen = Color(0xFF2E7D32);

  String _getDeadlineText(DateTime deadline, String status) {
    if (status == 'diperiksa') {
      return 'Tugas Terkirim • Sedang Dinilai';
    } else if (status == 'selesai') {
      return 'Tugas Selesai • Telah Dinilai';
    }

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Batas waktu telah habis';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return 'Sisa waktu: ${hours}j ${minutes}m';
    } else {
      return 'Sisa waktu: ${difference.inDays} hari';
    }
  }

  Color _getDeadlineColor(DateTime deadline, String status) {
    if (status == 'diperiksa') return _warningOrange;
    if (status == 'selesai') return _successGreen;

    final difference = deadline.difference(DateTime.now());
    if (difference.isNegative) return _dangerRed;
    if (difference.inHours < 3) return _warningOrange;
    return _primaryNavy;
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'diperiksa':
        return AppIcons.hourglassHighFill;
      case 'selesai':
        return AppIcons.checkCircleFill;
      case 'aktif':
      default:
        return AppIcons.clipboardTextFill;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diperiksa':
        return _warningOrange;
      case 'selesai':
        return _successGreen;
      case 'aktif':
      default:
        return _primaryNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAktif = assignment.status == 'aktif';
    final Color deadlineColor = _getDeadlineColor(
      assignment.deadline,
      assignment.status,
    );
    final statusColor = _getStatusColor(assignment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isAktif ? Colors.transparent : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/assignment-detail',
              arguments: assignment,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'icon-${assignment.id}',
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.lg - 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(assignment.status),
                          color: statusColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'title-${assignment.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                assignment.judul,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXl,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryNavy,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            '${assignment.mapel} • ${assignment.pengajar}',
                            style: TextStyle(
                              fontSize: AppDimensions.fontDefault,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),
                Hero(
                  tag: 'deadline-${assignment.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: deadlineColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        border: Border.all(
                          color: deadlineColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            assignment.status == 'diperiksa'
                                ? AppIcons.hourglassHigh
                                : (assignment.status == 'selesai'
                                      ? AppIcons.checkCircle
                                      : AppIcons.timer),
                            color: deadlineColor,
                            size: AppDimensions.iconMd,
                          ),
                          const SizedBox(width: AppDimensions.sm + 2),
                          Expanded(
                            child: Text(
                              _getDeadlineText(
                                assignment.deadline,
                                assignment.status,
                              ),
                              style: TextStyle(
                                fontSize: AppDimensions.fontDefault,
                                fontWeight: FontWeight.w600,
                                color: deadlineColor,
                              ),
                            ),
                          ),
                          Icon(
                            AppIcons.caretRight,
                            color: Colors.blueGrey.shade400,
                            size: AppDimensions.iconMd,
                          ),
                        ],
                      ),
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
}
