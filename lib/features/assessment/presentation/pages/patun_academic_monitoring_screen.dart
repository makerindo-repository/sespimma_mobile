import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/features/assessment/presentation/widgets/assessment_search_bar_widget.dart';
import 'package:sespimma_mobile/features/assessment/presentation/widgets/status_filter_button_widget.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';

class PatunAcademicMonitoringScreen extends StatefulWidget {
  const PatunAcademicMonitoringScreen({super.key});

  @override
  State<PatunAcademicMonitoringScreen> createState() =>
      _PatunAcademicMonitoringScreenState();
}

class _PatunAcademicMonitoringScreenState
    extends State<PatunAcademicMonitoringScreen> {
  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  String _searchQuery = '';
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['Semua', 'Aman', 'Warning', 'Kritis'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Monitoring Akademik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            final userPokjar = user.pokjar;

            final baseList = SerdikRealData.records
                .where((r) => r['kelompok_kelas'] == userPokjar)
                .toList();

            final listWithEWS = baseList.asMap().entries.map((entry) {
              final index = entry.key;
              final serdik = Map<String, dynamic>.from(entry.value);

              double score;
              String status;
              if (index % 5 == 0) {
                status = 'Kritis';
                score = 65.0 + (index % 5);
              } else if (index % 3 == 0) {
                status = 'Warning';
                score = 70.0 + (index % 3);
              } else {
                status = 'Aman';
                score = 80.0 + (index % 15);
              }

              serdik['_mock_score'] = score;
              serdik['_mock_status'] = status;
              return serdik;
            }).toList();

            var filteredList = listWithEWS.where((serdik) {
              final name = (serdik['nama_lengkap'] ?? '')
                  .toString()
                  .toLowerCase();
              final noSerdik = (serdik['no_serdik'] ?? '')
                  .toString()
                  .toLowerCase();
              final query = _searchQuery.toLowerCase();
              return name.contains(query) || noSerdik.contains(query);
            }).toList();

            if (_selectedFilter != 'Semua') {
              filteredList = filteredList
                  .where((serdik) => serdik['_mock_status'] == _selectedFilter)
                  .toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBlock(userPokjar, baseList.length),
                Divider(
                  height: AppDimensions.dividerHeight,
                  color: Colors.grey.shade200,
                  thickness: AppDimensions.dividerHeight,
                ),
                Expanded(
                  child: filteredList.isEmpty
                      ? _buildEmptyState(userPokjar)
                      : _buildSerdikList(filteredList),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: _primaryNavy),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBlock(String pokjar, int totalSerdik) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xl,
        vertical: AppDimensions.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AssessmentSearchBarWidget(
                  controller: _searchController,
                  searchQuery: _searchQuery,
                  hintText: 'Cari nama atau No. Serdik...',
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
              const SizedBox(width: AppDimensions.md),
              StatusFilterButtonWidget(
                selectedStatus: _selectedFilter,
                statuses: _filterOptions,
                onSelected: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'DAFTAR SERDIK ${pokjar.toUpperCase()}',
                  style: const TextStyle(
                    color: _primaryNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.fontLg,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primaryNavy,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$totalSerdik Serdik',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String pokjar) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'Tidak Ada Hasil',
            style: TextStyle(
              fontSize: AppDimensions.fontXxl,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Coba sesuaikan kata kunci atau filter status.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerdikList(List<Map<String, dynamic>> serdikList) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.xl),
      itemCount: serdikList.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.lg),
      itemBuilder: (context, index) {
        final serdik = serdikList[index];
        final name = serdik['nama_lengkap'] ?? '-';
        final noSerdik = serdik['no_serdik'] ?? '-';
        final pangkat = serdik['pangkat'] ?? '-';

        final double score = serdik['_mock_score'] as double;
        final String status = serdik['_mock_status'] as String;

        return _buildSerdikCard(serdik, name, noSerdik, pangkat, score, status);
      },
    );
  }

  Widget _buildSerdikCard(
    Map<String, dynamic> serdik,
    String name,
    String noSerdik,
    String pangkat,
    double score,
    String status,
  ) {
    Color statusColor;
    if (status == 'Aman') {
      statusColor = Colors.green.shade600;
    } else if (status == 'Warning') {
      statusColor = Colors.orange.shade600;
    } else {
      statusColor = Colors.red.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: () {
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              children: [
                _buildAvatar(serdik),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w800,
                          color: _primaryNavy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        '$pangkat • No. Serdik: $noSerdik',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
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
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: AppDimensions.fontXs,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NILAI',
                        style: TextStyle(
                          fontSize: AppDimensions.fontXs,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: AppDimensions.fontXl,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
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
    );
  }

  Widget _buildAvatar(Map<String, dynamic> serdik) {
    final String? profilePhoto =
        serdik['profile_photo'] ?? serdik['profilePhoto'];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _lightGrey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 2),
        image: DecorationImage(
          image: (profilePhoto != null && profilePhoto.isNotEmpty)
              ? FileImage(File(profilePhoto)) as ImageProvider
              : const AssetImage('assets/images/default_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
