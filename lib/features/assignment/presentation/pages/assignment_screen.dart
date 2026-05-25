import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import '../../data/models/assignment_model.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import '../widgets/task_card.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryNavy = AppColors.primaryNavy;
  static const Color _lightGrey = AppColors.background;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSubject = 'Semua Kategori';
  List<AssignmentModel>? __mockAssignments;
  List<AssignmentModel> get _mockAssignments {
    if (__mockAssignments != null) return __mockAssignments!;

    final List<AssignmentModel> base = [
      AssignmentModel(
        id: 'TSK-001',
        judul: 'Naskah Karya Perseorangan (NKP) - Analisis Integritas',
        mapel: 'NKP (Naskah Karya Perseorangan)',
        pengajar: 'Kombes Pol. Budi Santoso',
        deadline: DateTime.now().add(const Duration(minutes: 59)),
        status: 'aktif',
      ),
      AssignmentModel(
        id: 'TSK-002',
        judul: 'Naskah Program Transformasi Teknis (Taskap)',
        mapel: 'NKKP (Naskah Kuliah Kerja Profesi)',
        pengajar: 'AKBP Andi Wijaya',
        deadline: DateTime.now().add(const Duration(hours: 23, minutes: 15)),
        status: 'aktif',
      ),
      AssignmentModel(
        id: 'TSK-003',
        judul: 'Ujian MP - Pengendalian Diri & Emosi',
        mapel: 'Ujian MP/Esai',
        pengajar: 'Kombes Pol. Fajar Nugroho',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        status: 'diperiksa',
        submissionFileName: 'Ujian_MP_Jawaban.pdf',
      ),
      AssignmentModel(
        id: 'TSK-004',
        judul: 'Resume Kuliah Umum - Transparansi Digital SESPIMMA',
        mapel: 'Resume Mata Pelajaran',
        pengajar: 'AKBP Rina Kartika',
        deadline: DateTime.now().subtract(const Duration(days: 3)),
        status: 'selesai',
        submissionFileName: 'Resume_Kuliah.pdf',
        nilai: 85.5,
        catatan: 'Bagus, analisa mendalam namun referensi kurang kuat.',
      ),
    ];

    final dynamicTasks = PimpinanMockData.sharedTasks
        .map((t) {
          return AssignmentModel(
            id: t.id,
            judul: t.judul,
            mapel: t.mapel,
            pengajar: t.createdByName,
            deadline: t.deadline,
            status: t.status.toLowerCase() == 'aktif' ? 'aktif' : 'selesai',
            deskripsi: t.deskripsi,
          );
        })
        .where((dt) => !base.any((b) => b.id == dt.id))
        .toList();

    __mockAssignments = [...dynamicTasks, ...base];
    return __mockAssignments!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _allSubjects {
    return const [
      'Semua Kategori',
      'Resume Mata Pelajaran',
      'Ujian Mata Pelajaran atau Esai',
      'NKKP (Naskah Kuliah Kerja Profesi)',
      'NPKP (Naskah Praktek Kerja Profesi)',
      'NKP (Naskah Karya Perseorangan)',
      'NPTT (Naskah Program Transformasi Teknis)',
      'NAC (Neuro Associative Conditioning)',
      'MTL II (Manajemen Training Level II)',
      'BCS (Bina Cendekia Samapta)',
      'Simulasi Manajemen Penanggulangan Bencana',
      'KKP (Kuliah Kerja Profesi)',
      'PKP (Praktek Kerja Profesi)',
      'Simulasi Kepemimpinan Kontemporer',
      'Seminar Sekolah',
    ];
  }

  Widget _buildFilterDropdown() {
    final bool isFiltered = _selectedSubject != 'Semua Kategori';
    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedSubject = value;
        });
      },
      offset: const Offset(0, 56),
      constraints: const BoxConstraints(maxHeight: 280),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      itemBuilder: (context) {
        return _allSubjects.map((subject) {
          final bool isSelected = subject == _selectedSubject;
          return PopupMenuItem<String>(
            value: subject,
            child: Row(
              children: [
                Icon(
                  isSelected ? AppIcons.checkCircleFill : AppIcons.circle,
                  color: isSelected ? _primaryNavy : Colors.blueGrey.shade300,
                  size: AppDimensions.iconDefault,
                ),
                const SizedBox(width: AppDimensions.md - 4),
                Expanded(
                  child: Text(
                    subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? _primaryNavy
                          : Colors.blueGrey.shade700,
                      fontSize: AppDimensions.fontDefault,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isFiltered
              ? _primaryNavy.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isFiltered ? _primaryNavy : Colors.grey.shade200,
            width: isFiltered ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered ? AppIcons.funnelFill : AppIcons.funnel,
              color: isFiltered ? _primaryNavy : Colors.blueGrey.shade500,
              size: AppDimensions.iconDefault,
            ),
            if (isFiltered) ...[
              const SizedBox(width: AppDimensions.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  _selectedSubject,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w700,
                    color: _primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(width: AppDimensions.xs),
            Icon(
              AppIcons.caretDown,
              color: isFiltered ? _primaryNavy : Colors.blueGrey.shade400,
              size: AppDimensions.iconSm,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final List<AssignmentModel> searchedAssignments = _mockAssignments.where((
      t,
    ) {
      if (_selectedSubject != 'Semua Kategori' && t.mapel != _selectedSubject) {
        return false;
      }
      if (query.isEmpty) return true;
      return t.judul.toLowerCase().contains(query) ||
          t.mapel.toLowerCase().contains(query) ||
          t.pengajar.toLowerCase().contains(query);
    }).toList();

    final activeTasks = searchedAssignments
        .where((t) => t.status == 'aktif')
        .toList();
    final historyTasks = searchedAssignments
        .where((t) => t.status != 'aktif')
        .toList();

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Manajemen Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari judul tugas atau mata pelajaran...',
                      hintStyle: TextStyle(
                        color: Colors.blueGrey.shade300,
                        fontSize: AppDimensions.fontSm,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        AppIcons.magnifyingGlass,
                        color: Colors.blueGrey.shade400,
                        size: AppDimensions.iconDefault,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                AppIcons.xCircleFill,
                                color: Colors.blueGrey.shade300,
                                size: AppDimensions.iconMd,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        borderSide: BorderSide(color: Colors.grey.shade200),
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
                    ),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontDefault,
                      color: _primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md - 4),
                _buildFilterDropdown(),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _primaryNavy,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd + 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blueGrey.shade400,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.fontLg,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.fontLg,
                ),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(AppDimensions.xs),
                tabs: const [
                  Tab(text: 'Tugas Aktif'),
                  Tab(text: 'Riwayat Tugas'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(
                  activeTasks,
                  'Tidak Ada Tugas Aktif',
                  'Anda sudah menyelesaikan semua kewajiban tugas saat ini.',
                  AppIcons.clipboardText,
                ),
                _buildTaskList(
                  historyTasks,
                  'Belum Ada Riwayat',
                  'Belum ada tugas yang diselesaikan atau kadaluarsa.',
                  AppIcons.archive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    List<AssignmentModel> tasks,
    String emptyTitle,
    String emptyMessage,
    IconData iconData,
  ) {
    if (tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: _primaryNavy,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.8, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.lg),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              size: AppDimensions.iconDisplay,
                              color: Colors.blueGrey.shade300,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      emptyTitle,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontXxl,
                        fontWeight: FontWeight.w800,
                        color: _primaryNavy,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppDimensions.fontLg,
                        color: Colors.blueGrey.shade400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: _primaryNavy,
      child: ListView.builder(
        key: ValueKey('list_$_searchQuery'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(task.id),
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: TaskCard(assignment: task),
          );
        },
      ),
    );
  }
}
