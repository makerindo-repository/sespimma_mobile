import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:flutter/services.dart';

import 'package:sespimma_mobile/features/assignment/data/models/tugas_model.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';

class MonitoringTaskScreen extends StatefulWidget {
  const MonitoringTaskScreen({super.key});

  @override
  State<MonitoringTaskScreen> createState() => _MonitoringTaskScreenState();
}

class _MonitoringTaskScreenState extends State<MonitoringTaskScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'Semua';
  String _selectedPokjar = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _warningOrange = Color(0xFFF57C00);

  List<Map<String, dynamic>> _getSubmissionsForTask(String taskId) {
    return PimpinanMockData.getSubmissionsForTask(taskId);
  }

  void _showGradeDialog(Map<String, dynamic> submission) {
    final scoreCtrl = TextEditingController(
      text: submission['score'] != null ? submission['score'].toString() : '',
    );
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Penilaian Tugas',
                      style: TextStyle(
                        fontSize: AppDimensions.fontXxl,
                        fontWeight: FontWeight.w800,
                        color: _primaryNavy,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: _dangerRed,
                        size: AppDimensions.iconXxl,
                      ),
                      const SizedBox(width: AppDimensions.md - 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              submission['file'] ?? 'Tidak ada file',
                              style: const TextStyle(
                                fontSize: AppDimensions.fontDefault,
                                fontWeight: FontWeight.w700,
                                color: _primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              'Diserahkan: ${submission['time']}',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSm + 1,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_rounded,
                              color: _primaryNavy,
                              size: AppDimensions.iconDefault,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final filename =
                                  submission['file'] ?? 'document.pdf';
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusLg,
                                    ),
                                  ),
                                  insetPadding: const EdgeInsets.all(
                                    AppDimensions.xl - 4,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.6,
                                    color: Colors.grey.shade100,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          color: _primaryNavy,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Pratinjau: $filename',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: AppDimensions
                                                        .fontDefault,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size:
                                                      AppDimensions.iconDefault,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.description_rounded,
                                                  size:
                                                      AppDimensions.iconDisplay,
                                                  color: Colors.blueGrey,
                                                ),
                                                const SizedBox(
                                                  height: AppDimensions.md,
                                                ),
                                                Text(
                                                  'Simulasi Pratinjau Dokumen\n($filename)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .blueGrey
                                                        .shade600,
                                                    fontSize:
                                                        AppDimensions.fontLg,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          IconButton(
                            icon: const Icon(
                              Icons.file_download_outlined,
                              color: _primaryNavy,
                              size: AppDimensions.iconDefault,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final filename =
                                  submission['file'] ?? 'document.pdf';
                              final scaffoldMsg = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              final String? selectedFolder =
                                  await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusLg,
                                        ),
                                      ),
                                      title: const Text(
                                        'Pilih Lokasi Penyimpanan',
                                        style: TextStyle(
                                          fontSize: AppDimensions.fontXl,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryNavy,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.folder_shared,
                                              color: _primaryNavy,
                                            ),
                                            title: const Text(
                                              'Internal Storage / SESPIMMA',
                                              style: TextStyle(
                                                fontSize: AppDimensions.fontLg,
                                                fontWeight: FontWeight.w600,
                                                color: _primaryNavy,
                                              ),
                                            ),
                                            onTap: () => Navigator.pop(
                                              ctx,
                                              '/storage/emulated/0/SESPIMMA',
                                            ),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.download_rounded,
                                              color: _primaryNavy,
                                            ),
                                            title: const Text(
                                              'Internal Storage / Download',
                                              style: TextStyle(
                                                fontSize: AppDimensions.fontLg,
                                                fontWeight: FontWeight.w600,
                                                color: _primaryNavy,
                                              ),
                                            ),
                                            onTap: () => Navigator.pop(
                                              ctx,
                                              '/storage/emulated/0/Download',
                                            ),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.sd_storage_rounded,
                                              color: _primaryNavy,
                                            ),
                                            title: const Text(
                                              'SD Card / Documents',
                                              style: TextStyle(
                                                fontSize: AppDimensions.fontLg,
                                                fontWeight: FontWeight.w600,
                                                color: _primaryNavy,
                                              ),
                                            ),
                                            onTap: () => Navigator.pop(
                                              ctx,
                                              '/storage/extSdCard/Documents',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                              if (selectedFolder == null) return;
                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusLg,
                                    ),
                                  ),
                                  content: Row(
                                    children: [
                                      const CircularProgressIndicator(
                                        color: _primaryNavy,
                                      ),
                                      const SizedBox(width: AppDimensions.xl),
                                      Expanded(
                                        child: Text('Mengunduh $filename...'),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              await Future.delayed(const Duration(seconds: 2));

                              if (!context.mounted) return;
                              navigator.pop();
                              scaffoldMsg.showSnackBar(
                                SnackBar(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '✅ Unduhan Selesai',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Tersimpan di: $selectedFolder/$filename',
                                        style: const TextStyle(
                                          fontSize: AppDimensions.fontMd,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: _successGreen,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
                const Text(
                  'Beri Nilai (0 - 100)',
                  style: TextStyle(
                    fontSize: AppDimensions.fontDefault,
                    fontWeight: FontWeight.w700,
                    color: _primaryNavy,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextFormField(
                  controller: scoreCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                    color: _primaryNavy,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nilai wajib diisi';
                    }
                    final num? val = num.tryParse(value);
                    if (val == null) {
                      return 'Format nilai tidak valid';
                    }
                    if (val < 0 || val > 100) {
                      return 'Nilai harus di antara 0 - 100';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Contoh: 85.5',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: AppDimensions.fontDefault,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: const BorderSide(
                        color: _primaryNavy,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                const Text(
                  'Catatan Pengajar (Opsional)',
                  style: TextStyle(
                    fontSize: AppDimensions.fontDefault,
                    fontWeight: FontWeight.w700,
                    color: _primaryNavy,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextFormField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                    color: _primaryNavy,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Berikan masukan atau evaluasi untuk Serdik...',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: AppDimensions.fontDefault,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: const BorderSide(
                        color: _primaryNavy,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(AppDimensions.md),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final double newScore =
                            double.tryParse(scoreCtrl.text) ?? 0.0;

                        setState(() {
                          final subIndex = PimpinanMockData
                              .sharedTaskSubmissions
                              .indexWhere(
                                (s) =>
                                    s['nrp'] == submission['nrp'] &&
                                    s['taskId'] == submission['taskId'],
                              );
                          if (subIndex != -1) {
                            PimpinanMockData
                                    .sharedTaskSubmissions[subIndex]['score'] =
                                newScore;
                            PimpinanMockData
                                    .sharedTaskSubmissions[subIndex]['status'] =
                                'dinilai';
                          }

                          final serdikIndex = PimpinanMockData.sharedReportData
                              .indexWhere((r) => r.nrp == submission['nrp']);
                          if (serdikIndex != -1) {
                            final current =
                                PimpinanMockData.sharedReportData[serdikIndex];
                            PimpinanMockData.sharedReportData[serdikIndex] =
                                current.copyWith(
                                  academicScore:
                                      (current.academicScore + newScore) / 2,
                                );
                          }
                        });

                        Navigator.pop(context);
                        AppNotifier.showSuccess(
                          context,
                          'Nilai berhasil disimpan untuk ${submission['name']}',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                    ),
                    child: const Text(
                      'SIMPAN NILAI',
                      style: TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: AppDimensions.iconDisplay,
              color: Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const Text(
            'Data Serdik Tidak Ditemukan',
            style: TextStyle(
              fontSize: AppDimensions.fontXxl,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Belum ada data pengumpulan serdik yang sesuai\ndengan pencarian atau filter Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              color: Colors.blueGrey.shade400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _mapRomanToArabic(String roman) {
    switch (roman) {
      case 'POKJAR I':
        return 'POKJAR 1';
      case 'POKJAR II':
        return 'POKJAR 2';
      case 'POKJAR III':
        return 'POKJAR 3';
      case 'POKJAR IV':
        return 'POKJAR 4';
      case 'POKJAR V':
        return 'POKJAR 5';
      case 'POKJAR VI':
        return 'POKJAR 6';
      default:
        return roman;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskArg = ModalRoute.of(context)?.settings.arguments as TugasModel?;

    final TugasModel task =
        taskArg ??
        TugasModel(
          id: 'DUMMY',
          judul: 'Tugas Akademik (Mode Preview)',
          deskripsi: '-',
          mapel: '-',
          deadline: DateTime.now(),
          status: 'Aktif',
          createdBy: '00000000',
          createdByName: 'System Dummy',
        );

    final allSubmissions = _getSubmissionsForTask(task.id);
    final filteredSubmissions = allSubmissions.where((sub) {
      final String q = _searchQuery.trim().toLowerCase();
      final String name = sub['name'].toString().toLowerCase();
      final String nrp = sub['nrp'].toString().toLowerCase();

      if (q.isNotEmpty && !name.contains(q) && !nrp.contains(q)) {
        return false;
      }

      if (_selectedPokjar != 'Semua' &&
          sub['pokjar'] != _mapRomanToArabic(_selectedPokjar)) {
        return false;
      }

      if (_selectedFilter == 'Semua') {
        return true;
      }
      if (_selectedFilter == 'Sudah' &&
          (sub['status'] == 'sudah' || sub['status'] == 'dinilai')) {
        return true;
      }
      if (_selectedFilter == 'Belum' && sub['status'] == 'belum') {
        return true;
      }
      if (_selectedFilter == 'Terlambat' && sub['status'] == 'terlambat') {
        return true;
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pemantauan Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTaskHeader(task, allSubmissions),
          _buildSearchAndFilterRow(),
          Expanded(
            child: RefreshIndicator(
              color: _primaryNavy,
              backgroundColor: Colors.white,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) setState(() {});
              },
              child: filteredSubmissions.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        alignment: Alignment.center,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filteredSubmissions.length,
                      itemBuilder: (context, index) {
                        final animation = CurvedAnimation(
                          parent: _animController,
                          curve: Interval(
                            (index /
                                    (filteredSubmissions.isEmpty
                                        ? 1
                                        : filteredSubmissions.length))
                                .clamp(0.0, 1.0),
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: _buildSerdikItem(filteredSubmissions[index]),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(
    TugasModel task,
    List<Map<String, dynamic>> submissions,
  ) {
    final int total = submissions.length;
    final int sudah = submissions
        .where((s) => s['status'] == 'sudah' || s['status'] == 'dinilai')
        .length;
    final int belum = submissions.where((s) => s['status'] == 'belum').length;
    final int terlambat = submissions
        .where((s) => s['status'] == 'terlambat')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl - 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.mapel.toUpperCase(),
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm + 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey.shade400,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      task.judul,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontXl,
                        fontWeight: FontWeight.w800,
                        color: _primaryNavy,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: AppDimensions.fontLg,
                          color: _warningOrange,
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Text(
                          'Batas Waktu: ${task.deadline.day.toString().padLeft(2, '0')}/${task.deadline.month.toString().padLeft(2, '0')}/${task.deadline.year} ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')} WIB',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontMd,
                            fontWeight: FontWeight.w700,
                            color: _warningOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmationDialog(context, task),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: _dangerRed,
                ),
                tooltip: 'Hapus Tugas',
                style: IconButton.styleFrom(
                  backgroundColor: _dangerRed.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(AppDimensions.md),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  total.toString(),
                  Colors.blueGrey.shade600,
                ),
                _buildDivider(),
                _buildStatItem('Sudah', sudah.toString(), _successGreen),
                _buildDivider(),
                _buildStatItem('Belum', belum.toString(), _dangerRed),
                _buildDivider(),
                _buildStatItem(
                  'Terlambat',
                  terlambat.toString(),
                  _warningOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TugasModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: _dangerRed,
              size: AppDimensions.iconXl,
            ),
            SizedBox(width: AppDimensions.md - 4),
            Text(
              'Hapus Tugas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _primaryNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'Anda yakin ingin menghapus tugas "${task.judul}"? Semua data pengumpulan siswa akan ikut terhapus.',
          style: const TextStyle(
            fontSize: AppDimensions.fontLg,
            color: _primaryNavy,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              PimpinanMockData.sharedTasks.removeWhere((t) => t.id == task.id);

              PimpinanMockData.sharedTaskSubmissions.removeWhere(
                (s) => s['taskId'] == task.id,
              );

              Navigator.pop(ctx);
              Navigator.pop(context);
              AppNotifier.showSuccess(
                context,
                '✅ Tugas "${task.judul}" berhasil dihapus!',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd + 2),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.fontXxl,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontSm,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildSearchAndFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                color: _lightGrey,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau NRP serdik...',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: AppDimensions.fontDefault,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.blueGrey.shade400,
                    size: AppDimensions.iconDefault,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: AppDimensions.fontLg,
                  color: _primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md - 4),
          _buildStatusFilterDropdown(),
          const SizedBox(width: AppDimensions.sm),
          _buildPokjarFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    final bool isFiltered = _selectedFilter != 'Semua';
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedFilter = value;
        });
        _animController.forward(from: 0.0);
      },
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      itemBuilder: (context) {
        return ['Semua', 'Sudah', 'Belum', 'Terlambat'].map((item) {
          final bool isSel = _selectedFilter == item;
          return PopupMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Icon(
                  _resolveSelectionIcon(isSel),
                  color: _resolveSelectionColor(isSel),
                  size: AppDimensions.iconDefault,
                ),
                const SizedBox(width: AppDimensions.sm + 2),
                Text(
                  item,
                  style: TextStyle(
                    fontSize: AppDimensions.fontDefault,
                    color: _primaryNavy,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 48.0,
        width: 48.0,
        decoration: BoxDecoration(
          color: isFiltered
              ? _primaryNavy.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: isFiltered ? _primaryNavy : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(
          Icons.filter_list_rounded,
          color: isFiltered ? _primaryNavy : Colors.blueGrey.shade500,
          size: AppDimensions.iconDefault + 2,
        ),
      ),
    );
  }

  Widget _buildPokjarFilterDropdown() {
    final bool isFiltered = _selectedPokjar != 'Semua';
    final pokjars = [
      'Semua',
      'POKJAR I',
      'POKJAR II',
      'POKJAR III',
      'POKJAR IV',
      'POKJAR V',
      'Simulasi Kesatuan',
    ];
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedPokjar = value;
        });
        _animController.forward(from: 0.0);
      },
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      itemBuilder: (context) {
        return pokjars.map((item) {
          final bool isSel = _selectedPokjar == item;
          return PopupMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Icon(
                  _resolveSelectionIcon(isSel),
                  color: _resolveSelectionColor(isSel),
                  size: AppDimensions.iconDefault,
                ),
                const SizedBox(width: AppDimensions.sm + 2),
                Text(
                  item,
                  style: TextStyle(
                    fontSize: AppDimensions.fontDefault,
                    color: _primaryNavy,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 48.0,
        width: 48.0,
        decoration: BoxDecoration(
          color: isFiltered
              ? _primaryNavy.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: isFiltered ? _primaryNavy : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(
          Icons.groups_rounded,
          color: isFiltered ? _primaryNavy : Colors.blueGrey.shade500,
          size: AppDimensions.iconDefault + 2,
        ),
      ),
    );
  }

  IconData _resolveSelectionIcon(bool isSel) {
    if (isSel) return Icons.check_circle_rounded;
    return Icons.circle_outlined;
  }

  Color _resolveSelectionColor(bool isSel) {
    if (isSel) return _primaryNavy;
    return Colors.grey;
  }

  Widget _buildSerdikItem(Map<String, dynamic> submission) {
    final status = submission['status'];
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'sudah') {
      statusColor = Colors.blue.shade700;
      statusText = 'Menunggu Penilaian';
      statusIcon = Icons.drive_folder_upload_rounded;
    } else if (status == 'dinilai') {
      statusColor = _successGreen;
      statusText = 'Dinilai: ${submission['score'] ?? '-'}';
      statusIcon = Icons.verified_rounded;
    } else if (status == 'terlambat') {
      statusColor = _warningOrange;
      statusText = 'Terlambat Mengumpulkan';
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = _dangerRed;
      statusText = 'Belum Mengumpulkan';
      statusIcon = Icons.cancel_rounded;
    }

    final bool hasFile = submission['file'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: hasFile ? () => _showGradeDialog(submission) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission['name'],
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w700,
                          color: _primaryNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'NRP: ${submission['nrp']}  •  ${submission['pokjar'] ?? '-'}',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade500,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: AppDimensions.fontLg,
                            color: statusColor,
                          ),
                          const SizedBox(width: AppDimensions.xs),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSm + 1,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasFile)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.sm + 2),
                    decoration: BoxDecoration(
                      color: _primaryNavy.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_rounded,
                      color: _primaryNavy,
                      size: AppDimensions.iconDefault,
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
