import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/attendance/domain/models/map_tile_mode.dart';
import 'package:sespimma_mobile/features/attendance/presentation/pages/korsis_zone_marking_screen.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/geofence_map_widget.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/korsis_zone_info_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/korsis_zone_qr_sheet.dart';

class KorsisZoneScreen extends StatefulWidget {
  const KorsisZoneScreen({super.key});

  @override
  State<KorsisZoneScreen> createState() => _KorsisZoneScreenState();
}

class _KorsisZoneScreenState extends State<KorsisZoneScreen> {
  List<AttendanceZone> _zones = [];
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  void _loadZones() {
    setState(() => _zones = AttendanceZones.activeZones);
  }

  void _showZoneInfo(BuildContext context, AttendanceZone zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      builder: (_) => KorsisZoneInfoSheet(
        zone: zone,
        onDeleted: () {
          AttendanceZones.removeZone(zone.id);
          _loadZones();
          AppNotifier.showSuccess(context, 'Zona berhasil dihapus.');
        },
      ),
    );
  }

  void _showQrCodes() {
    if (_zones.isEmpty) {
      AppNotifier.showWarning(
        context,
        'Belum ada zona aktif untuk menampilkan QR Code',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KorsisZoneQrSheet(zones: _zones),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const fabHeight = 56.0;
    const gap = 8.0;
    final fabBase = bottomPad + fabHeight + gap + 16;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Manajemen Zona',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.qrCode, color: Colors.white),
            tooltip: 'Tampilkan QR Code Zona',
            onPressed: () {
              HapticFeedback.selectionClick();
              _showQrCodes();
            },
          ),
        ],
      ),
      body: GeofenceMapWidget(
        zones: _zones,
        onLocationDetected: (zone, dist, isFake) {
          if (_isLocating) {
            setState(() => _isLocating = false);
          }
        },
        onGpsStateChanged: (hasError) {
          if (hasError && _isLocating) {
            setState(() => _isLocating = false);
          }
        },
        onReload: _loadZones,
        fabBottomBase: fabBase,
        onRadiusTap: (tappedZone) {
          HapticFeedback.selectionClick();
          _showZoneInfo(context, tappedZone);
        },
      ),
      floatingActionButton: _isLocating
          ? null
          : FloatingActionButton(
              onPressed: () async {
                HapticFeedback.selectionClick();
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KorsisZoneMarkingScreen(),
                  ),
                );
                if (result == true) _loadZones();
              },
              backgroundColor: AppColors.primaryNavy,
              elevation: 6,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
    );
  }
}
