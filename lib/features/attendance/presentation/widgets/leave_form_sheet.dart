import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:sespimma_mobile/core/utils/app_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:sespimma_mobile/injection_container.dart';

class LeaveFormSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const LeaveFormSheet({super.key, required this.onSuccess});

  @override
  State<LeaveFormSheet> createState() => _LeaveFormSheetState();
}

class _LeaveFormSheetState extends State<LeaveFormSheet> {
  String? attachedFileName;
  bool isAttaching = false;
  bool _isSubmitting = false;
  late final TextEditingController reasonCtrl;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectDate(String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryNavy),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (type == 'start') {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(String type) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryNavy),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (type == 'start') {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Widget _buildDateTimePicker({required String type}) {
    final time = type == 'start' ? _startTime : _endTime;
    final date = type == 'start' ? _startDate : _endDate;
    final label = type == 'start' ? 'Waktu Mulai' : 'Waktu Berakhir';
    
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : '--/--/----';
    final timeStr = time?.format(context) ?? '--:--';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () => _selectDate(type),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                      color: date != null ? Colors.black87 : Colors.grey,
                      fontSize: AppDimensions.fontSm,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _selectTime(type),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(AppIcons.clock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontWeight: time != null ? FontWeight.bold : FontWeight.normal,
                      color: time != null ? Colors.black87 : Colors.grey,
                      fontSize: AppDimensions.fontSm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady =
        attachedFileName != null &&
        _startDate != null &&
        _endDate != null &&
        _startTime != null &&
        _endTime != null &&
        reasonCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.xxxl,
        top: AppDimensions.xl,
        left: AppDimensions.xxl,
        right: AppDimensions.xxl,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
            const Text(
              'Pengajuan Izin Khusus',
              style: TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: AppDimensions.xs + 2),
            Text(
              'Silakan lampirkan alasan tertulis beserta dokumen bukti.',
              style: TextStyle(
                fontSize: AppDimensions.fontXs + 1,
                color: Colors.blueGrey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            TextFormField(
              controller: reasonCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Alasan wajib diisi' : null,
              decoration: InputDecoration(
                hintText: 'Ketik alasan pengajuan izin...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDateTimePicker(type: 'start')),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDateTimePicker(type: 'end')),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            InkWell(
              onTap: isAttaching
                  ? null
                  : () async {
                      setState(() => isAttaching = true);
                      try {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'doc',
                            'docx',
                            'jpg',
                            'png',
                          ],
                        );
                        if (result != null) {
                          setState(() {
                            attachedFileName = result.files.single.name;
                          });
                        }
                      } on PlatformException catch (e, st) {
                        talker.error('Gagal memilih file lampiran (platform)', e, st);
                      } catch (e, st) {
                        talker.error('Gagal memilih file lampiran', e, st);
                      }
                      setState(() => isAttaching = false);
                    },
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: attachedFileName != null
                        ? AppColors.successGreen
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      attachedFileName != null
                          ? AppIcons.filePdfFill
                          : AppIcons.paperclip,
                      color: attachedFileName != null
                          ? AppColors.successGreen
                          : Colors.blueGrey,
                    ),
                    const SizedBox(width: AppDimensions.lg),
                    Expanded(
                      child: Text(
                        attachedFileName ?? 'Lampirkan Dokumen Bukti',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: attachedFileName != null
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: attachedFileName != null
                              ? AppColors.successGreen
                              : Colors.blueGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_startDate == null ||
                            _endDate == null ||
                            _startTime == null ||
                            _endTime == null) {
                          AppNotifier.showError(
                            context,
                            'Harap lengkapi tanggal dan waktu izin!',
                          );
                          return;
                        }
                        if (attachedFileName == null) {
                          AppNotifier.showError(
                            context,
                            'Harap lampirkan dokumen bukti izin',
                          );
                          return;
                        }
                        if (!formKey.currentState!.validate()) return;

                        final startDt = DateTime(
                          _startDate!.year,
                          _startDate!.month,
                          _startDate!.day,
                          _startTime!.hour,
                          _startTime!.minute,
                        );
                        final endDt = DateTime(
                          _endDate!.year,
                          _endDate!.month,
                          _endDate!.day,
                          _endTime!.hour,
                          _endTime!.minute,
                        );

                        final ctx = context;
                        setState(() => _isSubmitting = true);
                        try {
                          await sl<Dio>().post('/izin', data: {
                            'start_time': startDt.toUtc().toIso8601String(),
                            'end_time': endDt.toUtc().toIso8601String(),
                            'description': reasonCtrl.text.trim(),
                            'attachment_file_name': attachedFileName,
                          });
                          if (!ctx.mounted) return;
                          HapticFeedback.heavyImpact();
                          Navigator.pop(ctx);
                          widget.onSuccess();
                        } on DioException catch (e, st) {
                          talker.error('Submit izin gagal', e, st);
                          if (!ctx.mounted) return;
                          setState(() => _isSubmitting = false);
                          AppNotifier.showError(
                            ctx,
                            'Gagal mengirim permohonan izin. Silakan coba lagi.',
                          );
                        } catch (e, st) {
                          talker.error('Submit izin error tidak terduga', e, st);
                          if (!ctx.mounted) return;
                          setState(() => _isSubmitting = false);
                          AppNotifier.showError(ctx, 'Terjadi kesalahan.');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isReady && !_isSubmitting)
                      ? AppColors.primaryNavy
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: const Text(
                  'KIRIM PERMOHONAN',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
