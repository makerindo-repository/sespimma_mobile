import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/features/assignment/data/models/tugas_model.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';

class GadikTaskListScreen extends StatefulWidget {
  const GadikTaskListScreen({super.key});

  @override
  State<GadikTaskListScreen> createState() => _GadikTaskListScreenState();
}

class _GadikTaskListScreenState extends State<GadikTaskListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);
  static const Color _successGreen = Color(0xFF2E7D32);

  List<TugasModel> get _mockTasks {
    return PimpinanMockData.sharedTasks;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String currentNrp = '';
    if (authState is AuthSuccess) {
      currentNrp = authState.user.nrp;
    }

    final rawTasks = _mockTasks
        .where((t) => t.createdBy == currentNrp)
        .toList();

    final tasks = rawTasks.where((task) {
      final matchesSearch =
          task.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.mapel.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Sedang Berjalan' &&
              task.status.toLowerCase() == 'aktif') ||
          (_selectedFilter == 'Ditutup' &&
              task.status.toLowerCase() == 'selesai');
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manajemen Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                color: _primaryNavy,
                child: tasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final animation = CurvedAnimation(
                            parent: _animController,
                            curve: Interval(
                              (index / tasks.length).clamp(0.0, 1.0),
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
                              child: _buildTaskItem(context, tasks[index]),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/buat-tugas').then((_) {
            if (mounted) setState(() {});
          });
        },
        backgroundColor: _primaryNavy,
        elevation: 4,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          'Buat Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau mapel...',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: AppDimensions.fontDefault,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey.shade300,
                      size: AppDimensions.iconDefault,
                    ),
                    filled: true,
                    fillColor: _lightGrey,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                    color: _primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md - 4),
              PopupMenuButton<String>(
                initialValue: _selectedFilter,
                onSelected: (val) {
                  setState(() {
                    _selectedFilter = val;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                color: Colors.white,
                elevation: 4,
                offset: const Offset(0, 48),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'Semua',
                    child: Text(
                      'Semua Status',
                      style: TextStyle(
                        fontSize: AppDimensions.fontDefault,
                        fontWeight: FontWeight.w600,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Sedang Berjalan',
                    child: Text(
                      'Sedang Berjalan',
                      style: TextStyle(
                        fontSize: AppDimensions.fontDefault,
                        fontWeight: FontWeight.w600,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Ditutup',
                    child: Text(
                      'Ditutup',
                      style: TextStyle(
                        fontSize: AppDimensions.fontDefault,
                        fontWeight: FontWeight.w600,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: _selectedFilter != 'Semua'
                        ? _primaryNavy
                        : _lightGrey,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: _selectedFilter != 'Semua'
                        ? Colors.white
                        : _primaryNavy,
                    size: AppDimensions.iconDefault,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_add, size: 80, color: Colors.blueGrey.shade100),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Belum ada tugas yang dipublikasikan.\nTekan tombol di bawah untuk membuat tugas baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade300,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TugasModel task) {
    final bool isAktif = task.status.toLowerCase() == 'aktif';
    final String displayStatus = isAktif ? 'SEDANG BERJALAN' : 'DITUTUP';
    final Color statusColor = isAktif ? _successGreen : Colors.blueGrey;
    final IconData statusIcon = isAktif
        ? Icons.run_circle_outlined
        : Icons.lock_clock_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isAktif
              ? statusColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/monitoring-tugas',
              arguments: task,
            ).then((_) {
              if (mounted) setState(() {});
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl - 4),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: AppDimensions.fontLg,
                                  color: statusColor,
                                ),
                                const SizedBox(width: AppDimensions.xs),
                                Text(
                                  displayStatus,
                                  style: TextStyle(
                                    fontSize: AppDimensions.fontSm,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            task.judul,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontLg + 1,
                              fontWeight: FontWeight.w800,
                              color: _primaryNavy,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.radiusSm),
                          Text(
                            task.mapel,
                            style: TextStyle(
                              fontSize: AppDimensions.fontMd,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXs,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: AppDimensions.iconXs,
                                  color: Colors.blueGrey.shade600,
                                ),
                                const SizedBox(width: AppDimensions.xs),
                                Text(
                                  'Dibuat Oleh: ${task.createdByName}',
                                  style: TextStyle(
                                    fontSize: AppDimensions.fontSm,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: _primaryNavy,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: AppDimensions.iconSm,
                      color: Colors.blueGrey.shade300,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      'Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year} - ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')} WIB',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
