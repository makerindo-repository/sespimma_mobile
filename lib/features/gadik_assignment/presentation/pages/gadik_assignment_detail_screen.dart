import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import '../../data/models/gadik_assignment_model.dart';
import '../../data/models/gadik_submission_model.dart';
import '../../data/datasources/gadik_assignment_mock_data.dart';
import '../widgets/gadik_grading_bottom_sheet.dart';
import 'gadik_create_assignment_screen.dart';

class GadikAssignmentDetailScreen extends StatefulWidget {
  final GadikAssignmentModel assignment;

  const GadikAssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<GadikAssignmentDetailScreen> createState() =>
      _GadikAssignmentDetailScreenState();
}

class _GadikAssignmentDetailScreenState
    extends State<GadikAssignmentDetailScreen> {
  static const Color _primaryNavy = AppColors.primaryNavy;
  static const Color _lightGrey = AppColors.background;

  List<GadikSubmissionModel> _submissions = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  void _loadSubmissions() {
    setState(() {
      _submissions = GadikAssignmentMockData.submissions
          .where((s) => s.assignmentId == widget.assignment.id)
          .toList();

      if (_submissions.isEmpty) {
        final dummySubmissions = [
          GadikSubmissionModel(
            id: 'SUB-DUMMY-1-${widget.assignment.id}',
            assignmentId: widget.assignment.id,
            serdikName: 'Abd Azis, S.Sos.',
            serdikNrp: '77110075',
            serdikPangkat: 'Ajun Komisaris Polisi',
            serdikNosis: '202602003001',
            submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
            fileName: 'Tugas_Azis.pdf',
            fileUrl: 'https://example.com/file',
            isGraded: false,
          ),
          GadikSubmissionModel(
            id: 'SUB-DUMMY-2-${widget.assignment.id}',
            assignmentId: widget.assignment.id,
            serdikName: 'Abdan, S.E., M.H.',
            serdikNrp: '76090530',
            serdikPangkat: 'Ajun Komisaris Polisi',
            serdikNosis: '202602003002',
            submittedAt: DateTime.now().subtract(const Duration(minutes: 45)),
            fileName: 'Tugas_Abdan.pdf',
            fileUrl: 'https://example.com/file',
            isGraded: false,
            isRemedial: true,
          ),
          GadikSubmissionModel(
            id: 'SUB-DUMMY-3-${widget.assignment.id}',
            assignmentId: widget.assignment.id,
            serdikName: 'Tommy Bambang Irawan',
            serdikNrp: '71080519',
            serdikPangkat: 'Komisaris Besar Polisi',
            serdikNosis: '202602003015',
            submittedAt: DateTime.now().subtract(const Duration(days: 1)),
            fileName: 'Tugas_Tommy.pdf',
            fileUrl: 'https://example.com/file',
            isGraded: true,
            nilaiAkhir: 88.0,
            scoreMateri: 90,
            scorePaparan: 85,
            scoreKeaktifan: 90,
            catatanPengajar: 'Analisis masalah sangat tajam.',
          ),
        ];
        GadikAssignmentMockData.submissions.addAll(dummySubmissions);
        _submissions = dummySubmissions;
      }
    });
  }

  int _getTotalSerdik(String targetPokjar) {
    if (targetPokjar.toLowerCase() == 'semua pokjar') return 125;
    return 25;
  }

  String _formatDeadline(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  void _openGradingSheet(GadikSubmissionModel submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GadikGradingBottomSheet(
        assignment: widget.assignment,
        submission: submission,
        onSaved: (updatedSubmission) {
          setState(() {
            final idx = _submissions.indexWhere(
              (s) => s.id == updatedSubmission.id,
            );
            if (idx != -1) {
              _submissions[idx] = updatedSubmission;
              final mockIdx = GadikAssignmentMockData.submissions.indexWhere(
                (s) => s.id == updatedSubmission.id,
              );
              if (mockIdx != -1) {
                GadikAssignmentMockData.submissions[mockIdx] =
                    updatedSubmission;
              }
            }
          });
        },
      ),
    );
  }

  Future<void> _downloadFile(String? url, String? fileName) async {
    if (url == null || url.isEmpty || fileName == null) return;
    try {
      String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory == null) {
        return;
      }

      final String savePath = '$selectedDirectory/$fileName';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Mengunduh lampiran $fileName...')),
            ],
          ),
          backgroundColor: _primaryNavy,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (url.contains('example.com')) {
        await Future.delayed(const Duration(seconds: 1));
        final file = File(savePath);
        await file.writeAsBytes([0]);
      } else {
        await Dio().download(url, savePath);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tersimpan di Download/$fileName'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'BUKA',
            textColor: Colors.white,
            onPressed: () {
              OpenFilex.open(savePath);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalSerdik = _getTotalSerdik(widget.assignment.targetPokjar);
    final int submittedCount = _submissions.length;
    final int gradedCount = _submissions.where((s) => s.isGraded).length;

    String shortCat = widget.assignment.jenisTugas;
    if (shortCat.contains('(')) {
      shortCat = shortCat.substring(0, shortCat.indexOf('(')).trim();
    }

    return Scaffold(
      backgroundColor: _lightGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _primaryNavy,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Detail Tugas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.fontLg,
                letterSpacing: -0.3,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _showDeleteConfirmation(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: _primaryNavy,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.xl,
                0,
                AppDimensions.xl,
                AppDimensions.xl + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Text(
                          shortCat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: AppDimensions.fontXs + 1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Text(
                          widget.assignment.targetPokjar.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: AppDimensions.fontXs + 1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    widget.assignment.judul,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXxl,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.assignment.turunanTugas != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Kompetensi: ${widget.assignment.turunanTugas}',
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderStatBox(
                          icon: Icons.timer_outlined,
                          title: 'Tenggat Waktu',
                          value: _formatDeadline(widget.assignment.deadline),
                          valueColor: const Color(0xFFFCA5A5),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: _buildHeaderStatBox(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Progres',
                          value: '$submittedCount / $totalSerdik',
                          valueColor: const Color(0xFF6EE7B7),
                        ),
                      ),
                    ],
                  ),
                  if (_submissions.any((s) => s.isRemedial == true)) ...[
                    const SizedBox(height: AppDimensions.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final remedialSerdiks = _submissions
                              .where((s) => s.isRemedial == true)
                              .map((s) => s.serdikName)
                              .toList();
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GadikCreateAssignmentScreen(
                                isRemedialMode: true,
                                remedialSerdiks: remedialSerdiks,
                              ),
                            ),
                          ).then((value) {
                            if (!mounted) return;
                            if (value == true) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Tugas Remedial berhasil dibuat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.assignment_late_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Buat Tugas Remedial',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: _lightGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusXxl),
                    topRight: Radius.circular(AppDimensions.radiusXxl),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInstructionSection(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.xl,
                        AppDimensions.md,
                        AppDimensions.xl,
                        AppDimensions.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DAFTAR PENGUMPULAN',
                            style: TextStyle(
                              fontSize: AppDimensions.fontLg,
                              fontWeight: FontWeight.w800,
                              color: _primaryNavy,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryNavy.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg,
                              ),
                            ),
                            child: Text(
                              '$submittedCount / $totalSerdik Dikumpul',
                              style: const TextStyle(
                                fontSize: AppDimensions.fontSm,
                                fontWeight: FontWeight.w800,
                                color: _primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_submissions.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xxxl),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      const Text(
                        'Belum Ada Pengumpulan',
                        style: TextStyle(
                          fontSize: AppDimensions.fontXl,
                          fontWeight: FontWeight.w800,
                          color: _primaryNavy,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'Belum ada Serdik yang mengirimkan tugas ini.',
                        style: TextStyle(
                          fontSize: AppDimensions.fontLg,
                          color: Colors.blueGrey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final sub = _submissions[index];
                  return _buildSubmissionCard(sub);
                }, childCount: _submissions.length),
              ),
            ),
          if (_submissions.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFooterSection(submittedCount, gradedCount),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        title: const Text(
          'Hapus Tugas',
          style: TextStyle(fontWeight: FontWeight.w800, color: _primaryNavy),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tugas ini beserta seluruh nilainya?',
          style: TextStyle(
            fontSize: AppDimensions.fontLg,
            color: Colors.blueGrey,
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, 'deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatBox({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontXs,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDimensions.fontSm + 1,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.xxl,
        AppDimensions.xl,
        AppDimensions.xl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Instruksi Pengerjaan',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              widget.assignment.instruksi,
              style: TextStyle(
                fontSize: AppDimensions.fontSm + 1,
                color: Colors.blueGrey.shade700,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.assignment.fileName != null &&
                widget.assignment.fileName!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.xl),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: AppDimensions.lg),
              const Text(
                'Lampiran Tugas',
                style: TextStyle(
                  fontSize: AppDimensions.fontSm,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  onTap: () => _downloadFile(
                    widget.assignment.fileUrl,
                    widget.assignment.fileName,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
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
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
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
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.assignment.fileName!,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSm + 1,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryNavy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dokumen Lampiran • Ketuk untuk unduh',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontXs + 1,
                                  color: Colors.blueGrey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryNavy.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: _primaryNavy,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(GadikSubmissionModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: sub.isRemedial == true
              ? Colors.red.shade400
              : Colors.grey.shade100,
          width: sub.isRemedial == true ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: () {
            HapticFeedback.selectionClick();
            _openGradingSheet(sub);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _lightGrey,
                  backgroundImage: const AssetImage(
                    'assets/images/default_avatar.png',
                  ),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.serdikName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: AppDimensions.fontLg,
                          color: _primaryNavy,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sub.serdikPangkat ?? "Ajun Komisaris Polisi"} • ${sub.serdikNosis ?? "202602003001"}',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      if (sub.fileName != null && sub.fileName!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _downloadFile(sub.fileUrl, sub.fileName),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attachment_rounded,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    sub.fileName!,
                                    style: TextStyle(
                                      fontSize: AppDimensions.fontXs,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                _buildGradingAction(sub),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score == 0) return _primaryNavy;
    if (score < 70.01) return Colors.red.shade700;
    if (score <= 75.00) return Colors.orange.shade700;
    if (score <= 80.00) return Colors.blue.shade700;
    if (score <= 85.00) return Colors.green.shade600;
    return Colors.green.shade800;
  }

  Widget _buildGradingAction(GadikSubmissionModel sub) {
    if (sub.isGraded) {
      final double score = sub.nilaiAkhir ?? 0.0;
      final Color scoreColor = _getScoreColor(score);
      final Color scoreBgColor = score > 0
          ? scoreColor.withValues(alpha: 0.1)
          : const Color(0xFFECFDF5);
      final Color scoreBorderColor = score > 0
          ? scoreColor.withValues(alpha: 0.3)
          : const Color(0xFFA7F3D0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scoreBgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: scoreBorderColor),
                ),
                child: Text(
                  sub.nilaiAkhir?.toStringAsFixed(1) ?? '-',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w900,
                    fontSize: AppDimensions.fontLg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded, size: 12, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'Ubah Nilai',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.fontXs,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final beriNilaiBtn = Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: _primaryNavy,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: _primaryNavy.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Beri Nilai',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontSm,
            letterSpacing: 0.3,
          ),
        ),
      );

      if (sub.isRemedial == true) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'WAJIB REMEDIAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB91C1C),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            beriNilaiBtn,
          ],
        );
      }

      return beriNilaiBtn;
    }
  }

  Widget _buildFooterSection(int submitted, int graded) {
    if (submitted == 0) return const SizedBox.shrink();

    if (graded == submitted) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF047857),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Semua Nilai Telah Terintegrasi ke Sistem',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontSm + 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Text(
        'Selesaikan penilaian ($graded/$submitted) untuk menyimpan ke sistem.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.blueGrey.shade400,
          fontWeight: FontWeight.w600,
          fontSize: AppDimensions.fontSm,
        ),
      ),
    );
  }
}
