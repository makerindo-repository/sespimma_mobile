import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import '../../data/models/gadik_assignment_model.dart';
import '../../data/models/gadik_submission_model.dart';
import '../../data/datasources/gadik_assignment_mock_data.dart';
import '../widgets/gadik_grading_bottom_sheet.dart';

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
            final idx = _submissions.indexWhere((s) => s.id == updatedSubmission.id);
            if (idx != -1) {
              _submissions[idx] = updatedSubmission;
              final mockIdx = GadikAssignmentMockData.submissions
                  .indexWhere((s) => s.id == updatedSubmission.id);
              if (mockIdx != -1) {
                GadikAssignmentMockData.submissions[mockIdx] = updatedSubmission;
              }
            }
          });
        },
      ),
    );
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
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXl,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderSection(shortCat, totalSerdik, submittedCount, gradedCount),
          ),
          SliverToBoxAdapter(
            child: _buildInstructionSection(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.xl,
                AppDimensions.lg,
                AppDimensions.xl,
                AppDimensions.sm,
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
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryNavy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      '$gradedCount / $submittedCount Dinilai',
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
          ),
          if (_submissions.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xxxl),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Text(
                        'Belum Ada Pengumpulan',
                        style: TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'Serdik belum ada yang mengirimkan tugas ini.',
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppDimensions.xl,
                right: AppDimensions.xl,
                bottom: AppDimensions.xxxl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sub = _submissions[index];
                    return _buildSubmissionCard(sub);
                  },
                  childCount: _submissions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String shortCat, int totalTarget, int submitted, int graded) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.md,
        AppDimensions.xl,
        AppDimensions.xl,
      ),
      decoration: const BoxDecoration(
        color: _primaryNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXxl),
          bottomRight: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Text(
                  shortCat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontXs + 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Text(
                  widget.assignment.targetPokjar.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontXs + 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            widget.assignment.judul,
            style: const TextStyle(
              fontSize: AppDimensions.fontXxl,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          if (widget.assignment.turunanTugas != null) ...[
            const SizedBox(height: 6),
            Text(
              'Kompetensi: ${widget.assignment.turunanTugas}',
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.xl),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStatBox(
                  icon: Icons.timer_outlined,
                  title: 'Tenggat Waktu',
                  value: _formatDeadline(widget.assignment.deadline),
                  valueColor: Colors.red.shade300,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildHeaderStatBox(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Progres',
                  value: '$submitted / $totalTarget',
                  valueColor: Colors.green.shade300,
                ),
              ),
            ],
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppDimensions.fontXs,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Instruksi Pengerjaan',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSm + 1,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              widget.assignment.instruksi,
              style: TextStyle(
                fontSize: AppDimensions.fontSm + 1,
                color: Colors.blueGrey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(GadikSubmissionModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _lightGrey,
            backgroundImage: const AssetImage('assets/images/default_avatar.png'),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.serdikName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontSm + 1,
                    color: _primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'NRP: ${sub.serdikNrp}',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXs + 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                if (sub.fileName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.attachment_rounded, size: 14, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sub.fileName!,
                          style: TextStyle(
                            fontSize: AppDimensions.fontXs,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          _buildGradingAction(sub),
        ],
      ),
    );
  }

  Widget _buildGradingAction(GadikSubmissionModel sub) {
    if (sub.isGraded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  sub.nilaiAkhir?.toStringAsFixed(1) ?? '-',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w900,
                    fontSize: AppDimensions.fontSm,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _openGradingSheet(sub);
            },
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          _openGradingSheet(sub);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: const Text(
          'Nilai',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontSm,
          ),
        ),
      );
    }
  }
}
