import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/features/attendance/data/services/pdf_report_service.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';

class PatunAttendanceReportScreen extends StatefulWidget {
  final String pokjar;

  const PatunAttendanceReportScreen({super.key, required this.pokjar});

  @override
  State<PatunAttendanceReportScreen> createState() =>
      _PatunAttendanceReportScreenState();
}

class _PatunAttendanceReportScreenState
    extends State<PatunAttendanceReportScreen> {
  static const Color _primaryNavy = Color(0xFF000B1D);
  bool _isGenerating = false;

  void _generateAndDownloadPdf() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    
    HapticFeedback.mediumImpact();
    AppNotifier.showSuccess(context, 'Membuat laporan PDF...');

    try {
      await PdfReportService.generateAndDownloadReport(
        pokjar: widget.pokjar,
        date: DateTime.now(),
      );
    } catch (e) {
      if (mounted) {
        AppNotifier.showError(context, 'Gagal membuat laporan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Kehadiran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
            tooltip: 'Filter Tanggal',
            onPressed: () {
              HapticFeedback.selectionClick();
              // TODO: Implement date filter
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        children: [
          _buildDateSection('05 Juni 2026'),
          _buildReportCard(),
        ],
      ),
    );
  }

  Widget _buildDateSection(String dateStr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md, left: AppDimensions.xs),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  Widget _buildReportCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: _isGenerating ? null : _generateAndDownloadPdf,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporan Kegiatan Rutin',
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm + 1,
                        fontWeight: FontWeight.w700,
                        color: _primaryNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dibuat otomatis secara objektif',
                      style: TextStyle(
                        fontSize: AppDimensions.fontXs,
                        fontWeight: FontWeight.w400,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '23.59',
                          style: TextStyle(
                            fontSize: AppDimensions.fontXs,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.green,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.download_rounded,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
