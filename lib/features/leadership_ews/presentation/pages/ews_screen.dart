import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/leadership_ews/data/models/ews_model.dart';

class EwsScreen extends StatefulWidget {
  const EwsScreen({super.key});

  @override
  State<EwsScreen> createState() => _EwsScreenState();
}

class _EwsScreenState extends State<EwsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  String _searchQuery = '';
  String _selectedPokjar = 'Semua Pokjar';
  String _selectedRiskFilter = 'Semua Risiko';

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _warningOrange = Color(0xFFF57C00);
  static const Color _dangerRed = Color(0xFFD32F2F);

  final List<String> _pokjars = [
    'Semua Pokjar',
    'POKJAR I',
    'POKJAR II',
    'POKJAR III',
    'POKJAR IV',
    'POKJAR V',
    'POKJAR VI',
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

  List<EwsModel> get _allReports => PimpinanMockData.sharedEwsData;

  String _mapRomanToArabic(String roman) {
    switch (roman) {
      case 'POKJAR I':
        return 'Pokjar 1';
      case 'POKJAR II':
        return 'Pokjar 2';
      case 'POKJAR III':
        return 'Pokjar 3';
      case 'POKJAR IV':
        return 'Pokjar 4';
      case 'POKJAR V':
        return 'Pokjar 5';
      case 'POKJAR VI':
        return 'Pokjar 6';
      default:
        return roman;
    }
  }

  List<EwsModel> get _filteredList {
    return _allReports.where((serdik) {
      final String mappedPokjar = _mapRomanToArabic(_selectedPokjar);
      final String selectedP = mappedPokjar.trim().toLowerCase();
      final bool matchesPokjar =
          selectedP == 'semua pokjar' ||
          serdik.pokjar.trim().toLowerCase() == selectedP;

      final bool matchesRisk =
          _selectedRiskFilter == 'Semua Risiko' ||
          (_selectedRiskFilter == 'Risiko Tinggi' && serdik.isHighRisk) ||
          (_selectedRiskFilter == 'Risiko Sedang' && serdik.isMediumRisk) ||
          (_selectedRiskFilter == 'Aman' && serdik.isSafe);

      final String query = _searchQuery.trim().toLowerCase();
      final bool matchesSearch =
          query.isEmpty ||
          serdik.name.toLowerCase().contains(query) ||
          serdik.nrp.toLowerCase().contains(query);

      return matchesPokjar && matchesRisk && matchesSearch;
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
                curve: Interval(
                  beginInterval,
                  endInterval,
                  curve: Curves.easeOutQuart,
                ),
              ),
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredList;
    final int highRiskCount = filteredList.where((s) => s.isHighRisk).length;
    final int medRiskCount = filteredList.where((s) => s.isMediumRisk).length;
    final int safeCount = filteredList.where((s) => s.isSafe).length;

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
          'Monitoring Serdik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              beginInterval: 0.0,
              endInterval: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.md),
                  _buildSectionTitle('RINGKASAN STATUS'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Tinggi',
                            '$highRiskCount',
                            _dangerRed,
                            AppIcons.warningCircleFill,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md - 4),
                        Expanded(
                          child: _buildSummaryCard(
                            'Sedang',
                            '$medRiskCount',
                            _warningOrange,
                            AppIcons.warningFill,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md - 4),
                        Expanded(
                          child: _buildSummaryCard(
                            'Aman',
                            '$safeCount',
                            _successGreen,
                            AppIcons.checkCircleFill,
                          ),
                        ),
                      ],
                    ),
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
                  const SizedBox(height: AppDimensions.md),
                  _buildSectionTitle('PENCARIAN & FILTER'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
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
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Cari Nama/NRP...',
                                hintStyle: TextStyle(
                                  color: Colors.blueGrey.shade200,
                                  fontSize: AppDimensions.fontDefault,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                            onChanged: (val) =>
                                setState(() => _selectedPokjar = val!),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          _buildFilterIcon(
                            icon: AppIcons.funnelFill,
                            label: 'Risiko',
                            value: _selectedRiskFilter,
                            items: const [
                              'Semua Risiko',
                              'Risiko Tinggi',
                              'Risiko Sedang',
                              'Aman',
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedRiskFilter = val!),
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
            sliver: filteredList.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildAnimatedSection(
                      beginInterval: 0.4,
                      endInterval: 0.8,
                      child: _buildEmptyState(),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnimatedSection(
                        beginInterval: 0.3 + (index * 0.05).clamp(0.0, 0.4),
                        endInterval: 0.7 + (index * 0.05).clamp(0.0, 0.2),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildEwsCard(context, filteredList[index]),
                        ),
                      ),
                      childCount: filteredList.length,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
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
          color: isFiltered
              ? _primaryNavy.withValues(alpha: 0.08)
              : Colors.transparent,
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

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconDefault),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            count,
            style: TextStyle(
              fontSize: AppDimensions.fontHuge,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppDimensions.fontSm,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEwsCard(BuildContext context, EwsModel serdik) {
    Color statusColor;
    String riskLabel;
    IconData riskIcon;
    String analysisText;

    if (serdik.isHighRisk) {
      statusColor = _dangerRed;
      riskLabel = 'TINGGI';
      riskIcon = AppIcons.warningCircleFill;
      analysisText =
          'Nilai di bawah passing grade ATAU pelanggaran disiplin mencapai ambang kritis.';
    } else if (serdik.isMediumRisk) {
      statusColor = _warningOrange;
      riskLabel = 'SEDANG';
      riskIcon = AppIcons.warningFill;
      analysisText =
          'Nilai mendekati batas bawah. Memerlukan bimbingan preventif dari Patun.';
    } else {
      statusColor = _successGreen;
      riskLabel = 'AMAN';
      riskIcon = AppIcons.checkCircleFill;
      analysisText =
          'Capaian nilai di atas standar dan riwayat disiplin terpantau baik.';
    }

    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              riskIcon,
              color: statusColor,
              size: AppDimensions.iconLg,
            ),
          ),
          title: Text(
            serdik.name,
            style: const TextStyle(
              fontSize: AppDimensions.fontLg + 1,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
            ),
          ),
          subtitle: Text(
            '${serdik.nrp} • ${serdik.pokjar}',
            style: TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade400,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              riskLabel,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: _lightGrey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Rerata Nilai',
                          serdik.averageScore.toStringAsFixed(2),
                          statusColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'Pelanggaran',
                          '${serdik.violationCount}',
                          statusColor,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Text(
                    'ANALISIS SISTEM',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSm,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.radiusSm),
                  Text(
                    analysisText,
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            if (!serdik.isSafe)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showViolationLog(context, serdik),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.receiptFill,
                            size: AppDimensions.iconSm,
                            color: _primaryNavy,
                          ),
                          SizedBox(width: AppDimensions.sm),
                          Text(
                            'Log',
                            style: TextStyle(
                              fontSize: AppDimensions.fontMd,
                              fontWeight: FontWeight.w800,
                              color: _primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md - 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _notifyPatun(context, serdik.name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryNavy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.paperPlaneTiltFill,
                            size: AppDimensions.iconSm,
                            color: Colors.white,
                          ),
                          SizedBox(width: AppDimensions.sm),
                          Text(
                            'Hubungi Patun',
                            style: TextStyle(
                              fontSize: AppDimensions.fontMd,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.fontXxl,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: AppDimensions.xs / 2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontSm + 1,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.magnifyingGlassFill,
            size: AppDimensions.iconDisplay,
            color: Colors.blueGrey.shade200,
          ),
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

  void _showViolationLog(BuildContext context, EwsModel serdik) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: const BoxDecoration(
            color: Color(0xFFD32F2F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXxl),
              topRight: Radius.circular(AppDimensions.radiusXxl),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                AppIcons.warningCircleFill,
                color: Colors.white,
                size: AppDimensions.iconXl,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log Pelanggaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppDimensions.fontXl,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs / 2),
                    Text(
                      serdik.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Builder(
          builder: (context) {
            final punishments = PimpinanMockData.customActivities
                .where(
                  (a) => a['nrp'] == serdik.nrp && a['type'] == 'punishment',
                )
                .toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: punishments.isEmpty
                  ? [
                      const SizedBox(height: AppDimensions.md),
                      const Text(
                        'Belum ada pelanggaran tercatat.',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]
                  : punishments.map((p) {
                      final dateStr =
                          (p['date'] != null && p['date'].toString().isNotEmpty)
                          ? p['date']
                          : p['timeRaw'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.md),
                        child: _buildLogItem(
                          p['subtitle'] ?? p['title'],
                          dateStr,
                          AppIcons.warningFill,
                        ),
                      );
                    }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF001C40),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const Text('TUTUP'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String title, String date, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD32F2F),
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontDefault,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001C40),
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: AppDimensions.fontSm + 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _notifyPatun(BuildContext context, String name) {
    AppNotifier.showInfo(
      context,
      'Notifikasi telah dikirim ke Patun untuk $name',
    );
  }
}
