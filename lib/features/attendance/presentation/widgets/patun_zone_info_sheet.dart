import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/attendance/domain/models/map_tile_mode.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';

class PatunZoneInfoSheet extends StatefulWidget {
  final String pokjar;

  const PatunZoneInfoSheet({super.key, required this.pokjar});

  @override
  State<PatunZoneInfoSheet> createState() => _PatunZoneInfoSheetState();
}

class _PatunZoneInfoSheetState extends State<PatunZoneInfoSheet> {
  static const Color _primaryNavy = Color(0xFF001C40);

  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(start: now, end: now);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allZones = AttendanceZones.activeZones;
    final zones = allZones.where((z) {
      if (_dateRange == null) return true;
      final start = DateTime(
        _dateRange!.start.year,
        _dateRange!.start.month,
        _dateRange!.start.day,
      );
      final end = DateTime(
        _dateRange!.end.year,
        _dateRange!.end.month,
        _dateRange!.end.day,
        23,
        59,
        59,
      );
      return (z.startTime.isAfter(start) ||
              z.startTime.isAtSameMomentAs(start)) &&
          (z.startTime.isBefore(end) || z.startTime.isAtSameMomentAs(end));
    }).toList();

    final baseList = SerdikRealData.records
        .where(
          (r) => widget.pokjar.isEmpty || r['kelompok_kelas'] == widget.pokjar,
        )
        .toList();
    final totalSerdik = baseList.length;

    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info Kegiatan Aktif',
                          style: TextStyle(
                            fontSize: AppDimensions.fontXl,
                            fontWeight: FontWeight.w800,
                            color: _primaryNavy,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Daftar zona geofencing yang sedang berlangsung',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMd,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _pickDateRange,
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          color: _primaryNavy,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade50,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryNavy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.pokjar.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: AppDimensions.fontSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            if (zones.isEmpty)
              _buildEmptyState()
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(24),
                  itemCount: zones.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final zone = zones[i];
                    return _buildZoneCard(zone, totalSerdik, i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Kegiatan',
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saat ini tidak ada kegiatan atau zona apel aktif untuk pokjar Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimensions.fontMd,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(AttendanceZone zone, int totalSerdik, int index) {
    final random = Random(index + 42);
    int hadir = 0, izin = 0, telat = 0, alpha = 0;

    if (totalSerdik > 0) {
      if (index == 0) {
        hadir = (totalSerdik * 0.8).floor();
        izin = (totalSerdik * 0.1).floor();
        telat = (totalSerdik * 0.05).floor();
        alpha = totalSerdik - hadir - izin - telat;
      } else {
        hadir = random.nextInt(totalSerdik + 1);
        int remaining = totalSerdik - hadir;
        izin = remaining > 0 ? random.nextInt(remaining + 1) : 0;
        remaining -= izin;
        telat = remaining > 0 ? random.nextInt(remaining + 1) : 0;
        alpha = remaining - telat;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    AppIcons.buildingsFill,
                    color: _primaryNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.activityName,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.w800,
                          color: _primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        zone.name,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                zone.timeString,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSm,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                zone.creator,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSm,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Hadir', hadir, Colors.green),
                _buildStatItem('Telat', telat, Colors.orange),
                _buildStatItem('Izin', izin, Colors.blue),
                _buildStatItem('Alpha', alpha, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, MaterialColor color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: AppDimensions.fontXxl,
            fontWeight: FontWeight.w900,
            color: color.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontXs,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
