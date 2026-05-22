import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/features/leadership_report/domain/services/pdf_report_service.dart';
import 'package:sespimma_mobile/features/leadership_report/presentation/widgets/ai_recommendation_card.dart';
import 'package:sespimma_mobile/features/leadership_report/presentation/widgets/average_stats_card.dart';
import 'package:sespimma_mobile/features/leadership_report/presentation/widgets/report_card_item.dart';
import 'package:sespimma_mobile/features/leadership_report/presentation/widgets/summary_stats_cards.dart';

class LeadershipReportScreen extends StatefulWidget {
  const LeadershipReportScreen({super.key});

  @override
  State<LeadershipReportScreen> createState() => _LeadershipReportScreenState();
}

class _LeadershipReportScreenState extends State<LeadershipReportScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  String _searchQuery = '';
  String _selectedPokjar = 'Semua Pokjar';
  String _selectedStatusFilter = 'Semua Status';

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  final List<String> _pokjars = [
    'Semua Pokjar',
    'Pokjar 1',
    'Pokjar 2',
    'Pokjar 3',
    'Pokjar 4',
    'Pokjar 5',
    'Pokjar 6',
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController?.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  List<FinalRecapModel> get _allReports => PimpinanMockData.sharedReportData;

  List<FinalRecapModel> get _filteredReports {
    return _allReports.where((report) {
      final String selectedP = _selectedPokjar.trim().toLowerCase();
      final bool matchesPokjar = selectedP == 'semua pokjar' ||
          report.pokjar.trim().toLowerCase() == selectedP;

      final bool matchesStatus = _selectedStatusFilter == 'Semua Status' ||
          (_selectedStatusFilter == 'Lulus' && report.average >= 70.0) ||
          (_selectedStatusFilter == 'Tidak Lulus' && report.average < 70.0);

      final String query = _searchQuery.trim().toLowerCase();
      final bool matchesSearch = query.isEmpty ||
          report.name.toLowerCase().contains(query) ||
          report.nrp.toLowerCase().contains(query);

      return matchesPokjar && matchesStatus && matchesSearch;
    }).toList();
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required double beginInterval,
    required double endInterval,
  }) {
    if (_animController == null) return child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController!,
          curve: Interval(beginInterval, endInterval, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animController!,
                curve: Interval(beginInterval, endInterval, curve: Curves.easeOutQuart),
              ),
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    final int lulusCount = filtered.where((r) => r.average >= 70.0).length;
    final int peringatanCount = filtered.where((r) => r.average < 70.0).length;

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.caretLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Kepemimpinan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.downloadSimple, color: Colors.white),
            onPressed: () => _handleExportPdf(context, filtered),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              beginInterval: 0.0,
              endInterval: 0.4,
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SummaryStatsCards(
                      lulusCount: lulusCount,
                      peringatanCount: peringatanCount,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AverageStatsCard(data: _allReports),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AiRecommendationCard(selectedPokjar: _selectedPokjar),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              beginInterval: 0.2,
              endInterval: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.lg),
                  _buildSectionTitle('DAFTAR REKAPITULASI NILAI'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Cari Nama/NRP...',
                                hintStyle: TextStyle(
                                  color: Colors.blueGrey.shade200,
                                  fontSize: AppDimensions.fontDefault,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              style: const TextStyle(
                                color: _primaryNavy,
                                fontSize: AppDimensions.fontDefault,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _buildFilterIcon(
                            icon: AppIcons.treeStructureFill,
                            label: 'Pokjar',
                            value: _selectedPokjar,
                            items: _pokjars,
                            onChanged: (val) => setState(() => _selectedPokjar = val!),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          _buildFilterIcon(
                            icon: AppIcons.funnelFill,
                            label: 'Status',
                            value: _selectedStatusFilter,
                            items: const ['Semua Status', 'Lulus', 'Tidak Lulus'],
                            onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xl)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnimatedSection(
                        beginInterval: 0.4 + (index * 0.05).clamp(0.0, 0.4),
                        endInterval: 0.8 + (index * 0.05).clamp(0.0, 0.2),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ReportCardItem(data: filtered[index]),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final bool isFiltered = value != items.first;
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      offset: const Offset(0, 45),
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem(
          value: item,
          child: Row(
            children: [
              Icon(
                item == value ? AppIcons.checkCircleFill : null,
                size: AppDimensions.iconMd,
                color: _primaryNavy,
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                item,
                style: TextStyle(
                  fontSize: AppDimensions.fontDefault,
                  fontWeight: item == value ? FontWeight.w800 : FontWeight.w600,
                  color: _primaryNavy,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: isFiltered ? _primaryNavy.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd + 2),
        ),
        child: Icon(
          icon,
          size: AppDimensions.iconDefault,
          color: isFiltered ? _primaryNavy : Colors.blueGrey.shade300,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppDimensions.fontSm + 1,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppDimensions.avatarMd),
          Icon(AppIcons.magnifyingGlassFill,
              size: AppDimensions.iconDisplay, color: Colors.blueGrey.shade200),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: AppDimensions.fontXl,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportPdf(
      BuildContext context, List<FinalRecapModel> data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: _primaryNavy),
      ),
    );

    try {
      await PdfReportService.generateLeadershipReport(
        data: data,
        pokjar: _selectedPokjar,
      );
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan PDF berhasil diunduh'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat laporan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
