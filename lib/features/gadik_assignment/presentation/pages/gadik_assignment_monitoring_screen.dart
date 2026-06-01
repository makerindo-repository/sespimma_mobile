import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/assessment/presentation/widgets/assessment_search_bar_widget.dart';
import '../../data/models/gadik_assignment_model.dart';
import '../../data/datasources/gadik_assignment_mock_data.dart';
import 'gadik_create_assignment_screen.dart';
import 'gadik_assignment_detail_screen.dart';

class GadikAssignmentMonitoringScreen extends StatefulWidget {
  const GadikAssignmentMonitoringScreen({super.key});

  @override
  State<GadikAssignmentMonitoringScreen> createState() =>
      _GadikAssignmentMonitoringScreenState();
}

class _GadikAssignmentMonitoringScreenState
    extends State<GadikAssignmentMonitoringScreen> {
  static const Color _primaryNavy = AppColors.primaryNavy;
  static const Color _lightGrey = AppColors.background;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Sort Logic: false = Descending (Paling banyak submit), true = Ascending (Paling sedikit submit)
  bool _isSortAscending = false;

  // Date Filter Logic
  DateTime? _selectedFilterDate;

  String _selectedCategory = 'Semua Kategori';
  final List<String> _categoryOptions = [
    'Semua Kategori',
    'Ujian Mata Pelajaran atau Esai',
    'NKKP (Naskah Kuliah Kerja Profesi)',
    'NPKP (Naskah Praktek Kerja Profesi)',
    'NKP (Naskah Karya Perseorangan)',
    'Simulasi Kepemimpinan Kontemporer',
    'NPTT (Naskah Program Transformasi Teknis)'
  ];

  List<GadikAssignmentModel> _assignments = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _assignments = GadikAssignmentMockData.assignments
          .where((t) => t.createdBy == 'Efrianza')
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getTotalSerdik(String targetPokjar) {
    if (targetPokjar.toLowerCase() == 'semua pokjar') return 125;
    return 25;
  }

  int _getSubmittedCount(String assignmentId) {
    return GadikAssignmentMockData.submissions
        .where((s) => s.assignmentId == assignmentId)
        .length;
  }

  int _getGradedCount(String assignmentId, int submittedCount) {
    // Mocking logic for "DINILAI"
    if (submittedCount == 0) return 0;
    int hash = assignmentId.hashCode.abs();
    int graded = hash % (submittedCount + 1);
    return graded;
  }

  String _formatDeadline(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy, \'Pukul\' HH:mm \'WIB\'', 'id_ID').format(date);
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryNavy,
              onPrimary: Colors.white,
              onSurface: _primaryNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GadikAssignmentModel> filteredAssignments = _assignments.where((t) {
      if (_searchQuery.isNotEmpty) {
        if (!t.judul.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_selectedCategory != 'Semua Kategori' && t.jenisTugas != _selectedCategory) {
        return false;
      }
      if (_selectedFilterDate != null) {
        // Assume deadline implies the date grouping they want to see, or we mock a creation date.
        // Usually tasks mock data only has deadline. We will filter by deadline date.
        if (!_isSameDate(t.deadline, _selectedFilterDate!)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sorting by submit count & date
    filteredAssignments.sort((a, b) {
      final aCount = _getSubmittedCount(a.id);
      final bCount = _getSubmittedCount(b.id);
      
      if (aCount != bCount) {
        return _isSortAscending 
            ? aCount.compareTo(bCount)   // Paling sedikit submit di atas
            : bCount.compareTo(aCount);  // Paling banyak submit di atas
      }
      // If submit count is same, sort by date
      return _isSortAscending
          ? a.deadline.compareTo(b.deadline)
          : b.deadline.compareTo(a.deadline);
    });

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Monitoring Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.xl,
              vertical: AppDimensions.lg,
            ),
            child: AssessmentSearchBarWidget(
              controller: _searchController,
              searchQuery: _searchQuery,
              hintText: 'Cari nama tugas...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          ),
          Divider(
            height: AppDimensions.dividerHeight,
            color: Colors.grey.shade200,
            thickness: AppDimensions.dividerHeight,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: _primaryNavy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'DAFTAR TUGAS',
                              style: TextStyle(
                                fontSize: AppDimensions.fontLg,
                                fontWeight: FontWeight.w800,
                                color: _primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryNavy,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusLg,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filteredAssignments.length}',
                                    style: const TextStyle(
                                      fontSize: AppDimensions.fontSm + 1,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Date Filter Toggle
                            InkWell(
                              onTap: _pickDateFilter,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              child: Container(
                                padding: const EdgeInsets.all(AppDimensions.sm),
                                decoration: BoxDecoration(
                                  color: _selectedFilterDate != null 
                                      ? _primaryNavy 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  border: Border.all(
                                    color: _selectedFilterDate != null 
                                        ? _primaryNavy 
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  size: 20,
                                  color: _selectedFilterDate != null 
                                      ? Colors.white 
                                      : _primaryNavy,
                                ),
                              ),
                            ),
                            if (_selectedFilterDate != null) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFilterDate = null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.all(AppDimensions.sm),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Icon(
                                    Icons.clear_rounded,
                                    size: 20,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            
                            // Sort Toggle
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isSortAscending = !_isSortAscending;
                                });
                              },
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              child: Container(
                                padding: const EdgeInsets.all(AppDimensions.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isSortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      size: 16,
                                      color: _primaryNavy,
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.sort_rounded,
                                      size: 20,
                                      color: _primaryNavy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Category Filter
                            _buildFilterDropdown(
                              icon: Icons.filter_list_rounded,
                              value: _selectedCategory,
                              options: _categoryOptions,
                              onChanged: (val) {
                                setState(() => _selectedCategory = val);
                              },
                              isCategory: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_selectedFilterDate != null) ...[
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        'Menampilkan tugas untuk tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedFilterDate!)}',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.md),
                    if (filteredAssignments.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredAssignments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
                        itemBuilder: (context, index) {
                          final task = filteredAssignments[index];
                          final totalTarget = _getTotalSerdik(task.targetPokjar);
                          final submittedCount = _getSubmittedCount(task.id);
                          final gradedCount = _getGradedCount(task.id, submittedCount);

                          String shortCat = task.jenisTugas;
                          if (shortCat.contains('(')) {
                            shortCat = shortCat.substring(0, shortCat.indexOf('(')).trim();
                          } else if (shortCat.toLowerCase().contains('ujian')) {
                            shortCat = 'Ujian MP';
                          }

                          return _buildTaskCard(
                            task, 
                            shortCat, 
                            submittedCount, 
                            totalTarget,
                            gradedCount,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GadikCreateAssignmentScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: _primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    Color? iconColor,
    bool isCategory = false,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor ?? _primaryNavy),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return options.map((String choice) {
          String displayChoice = choice;
          if (isCategory && choice.contains('(')) {
            displayChoice = choice.substring(0, choice.indexOf('(')).trim();
          }

          return PopupMenuItem<String>(
            value: choice,
            child: Row(
              children: [
                Icon(
                  value == choice
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: value == choice ? _primaryNavy : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayChoice,
                    style: TextStyle(
                      fontWeight: value == choice
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: value == choice ? _primaryNavy : Colors.black87,
                      fontSize: AppDimensions.fontSm + 1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: AppDimensions.iconDisplay,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Tidak Ditemukan',
              style: TextStyle(
                fontSize: AppDimensions.fontXxl,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Tidak ada tugas yang sesuai dengan pencarian atau filter Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontLg,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    GadikAssignmentModel task,
    String shortCat,
    int submittedCount,
    int totalTarget,
    int gradedCount,
  ) {
    // Determine Status Logic for the Left-side Icon
    IconData statusIcon;
    Color statusColor;
    String statusTooltip;

    if (submittedCount == 0) {
      statusIcon = Icons.pending_actions_rounded;
      statusColor = Colors.blueGrey;
      statusTooltip = "Tugas Sedang Berlangsung";
    } else if (gradedCount < totalTarget) {
      statusIcon = Icons.drive_file_rename_outline_rounded;
      statusColor = Colors.blue.shade700;
      statusTooltip = "Sudah & Sedang Dinilai";
    } else {
      statusIcon = Icons.verified_rounded;
      statusColor = Colors.green.shade700;
      statusTooltip = "Sudah Dinilai Semua & Submit Kabag Bindik";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GadikAssignmentDetailScreen(assignment: task),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // The Full Centered Status Icon
                Tooltip(
                  message: statusTooltip,
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 24),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.judul,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w800,
                          color: _primaryNavy,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Wrap(
                        spacing: AppDimensions.sm,
                        runSpacing: AppDimensions.sm,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryNavy,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Text(
                              shortCat,
                              style: const TextStyle(
                                fontSize: AppDimensions.fontXs + 1,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryNavy,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Text(
                              task.targetPokjar.toUpperCase(),
                              style: const TextStyle(
                                fontSize: AppDimensions.fontXs + 1,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Row(
                        children: [
                          Icon(
                            AppIcons.clock,
                            size: 14,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDeadline(task.deadline),
                              style: TextStyle(
                                fontSize: AppDimensions.fontSm,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                // Right side: DINILAI and SUBMIT counts
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(right: AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DINILAI',
                            style: TextStyle(
                              fontSize: AppDimensions.fontXs,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                gradedCount.toString(),
                                style: TextStyle(
                                  fontSize: AppDimensions.fontLg,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                '/$totalTarget',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: AppDimensions.fontXs,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                submittedCount.toString(),
                                style: TextStyle(
                                  fontSize: AppDimensions.fontLg,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              Text(
                                '/$totalTarget',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
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
