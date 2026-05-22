import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sespimma_mobile/features/assignment/data/models/assignment_model.dart';
import 'package:sespimma_mobile/features/assignment/presentation/widgets/assignment_widgets.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({super.key});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFileAttached = false;
  String _fileName = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  String _stdName(AssignmentModel a, String n) {
    const nrp = '202602003097';
    final ext = n.contains('.') ? n.split('.').last : 'pdf';
    String c(String t) => t
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim().replaceAll(' ', '_').toUpperCase();
    return '${nrp}_${c(a.judul)}_${c(a.mapel)}_${c(a.pengajar)}.$ext';
  }

  void _pickFile(AssignmentModel a) => showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusRound))),
    builder: (_) => AssignmentFilePickerSheet(
      onPickImage: () => _pickImage(a),
      onPickDocument: () => _pickDocument(a)),
  );

  Future<void> _pickImage(AssignmentModel a) async {
    Navigator.pop(context);
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) return;
    await HapticFeedback.mediumImpact();
    setState(() { _isFileAttached = true; _fileName = _stdName(a, img.name); });
  }
  Future<void> _pickDocument(AssignmentModel a) async {
    Navigator.pop(context);
    final r = await FilePicker.pickFiles(type: FileType.any);
    if (r == null) return;
    await HapticFeedback.mediumImpact();
    setState(() {
      _isFileAttached = true; _fileName = _stdName(a, r.files.single.name);
    });
  }

  Future<void> _removeFile() async {
    await HapticFeedback.lightImpact();
    setState(() { _isFileAttached = false; _fileName = ''; });
  }
  Future<void> _submitTask() async {
    await HapticFeedback.heavyImpact();
    if (!mounted) return;
    AssignmentSnackbars.showSuccess(context, 'Tugas berhasil dikumpulkan');
    Navigator.pop(context);
  }
  Future<void> _downloadFile(String name) async {
    await HapticFeedback.lightImpact();
    try {
      final dir = await FilePicker.getDirectoryPath(
        dialogTitle: 'Pilih lokasi penyimpanan berkas',
      );
      if (dir == null || !mounted) return;
      await HapticFeedback.mediumImpact();
      if (!mounted) return;
      AssignmentSnackbars.showSuccess(
        context, 'Berkas $name berhasil disimpan di: $dir',
      );
    } catch (e) {
      if (!mounted) return;
      AssignmentSnackbars.showError(context, 'Gagal menyimpan berkas: $e');
    }
  }

  void _showSubmitSheet(bool isExpired) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AssignmentSubmitConfirmationSheet(
      isExpired: isExpired, fileName: _fileName, onConfirm: _submitTask),
  );

  @override
  Widget build(BuildContext context) {
    final a = ModalRoute.of(context)!.settings.arguments as AssignmentModel;
    final isAktif = a.status == 'aktif';
    final isExpired = isAktif && a.deadline.isBefore(DateTime.now());
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AssignmentDetailAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AssignmentDetailContent(
                assignment: a,
                isAktif: isAktif,
                isExpired: isExpired,
                isFileAttached: _isFileAttached,
                fileName: _fileName,
                fadeAnimation: _fadeAnimation,
                onPickFile: () => _pickFile(a),
                onRemoveFile: _removeFile,
                onDownloadFile: _downloadFile,
              ),
            ),
            if (isAktif)
              AssignmentBottomActionButton(
                isExpired: isExpired,
                isFileAttached: _isFileAttached,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showSubmitSheet(isExpired);
                },
              ),
          ],
        ),
      ),
    );
  }
}
