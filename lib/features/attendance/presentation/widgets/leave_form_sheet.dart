import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class LeaveFormSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const LeaveFormSheet({super.key, required this.onSuccess});

  @override
  State<LeaveFormSheet> createState() => _LeaveFormSheetState();
}

class _LeaveFormSheetState extends State<LeaveFormSheet> {
  String? attachedFileName;
  bool isAttaching = false;
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

  @override
  Widget build(BuildContext context) {
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
              validator: (v) => v == null || v.trim().isEmpty ? 'Alasan wajib diisi' : null,
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
            InkWell(
              onTap: isAttaching
                  ? null
                  : () async {
                      setState(() => isAttaching = true);
                      try {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                        );
                        if (result != null) {
                          setState(() {
                            attachedFileName = result.files.single.name;
                          });
                        }
                      } catch (_) {}
                      setState(() => isAttaching = false);
                    },
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: attachedFileName != null ? AppColors.successGreen : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      attachedFileName != null ? AppIcons.filePdfFill : AppIcons.paperclip,
                      color: attachedFileName != null ? AppColors.successGreen : Colors.blueGrey,
                    ),
                    const SizedBox(width: AppDimensions.lg),
                    Expanded(
                      child: Text(
                        attachedFileName ?? 'Lampirkan Dokumen Bukti',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: attachedFileName != null ? FontWeight.w700 : FontWeight.w600,
                          color: attachedFileName != null ? AppColors.successGreen : Colors.blueGrey,
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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (attachedFileName == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap lampirkan dokumen bukti izin!'),
                          backgroundColor: AppColors.dangerRed,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    HapticFeedback.heavyImpact();
                    widget.onSuccess();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: const Text(
                  'KIRIM PERMOHONAN',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
