import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/attendance/domain/models/map_tile_mode.dart';
import 'package:sespimma_mobile/features/attendance/presentation/pages/attendance_qr_scanner_screen.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/geofence_map_widget.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/zone_info_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/empty_zone_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/leave_form_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_status_chip.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_floating_info.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_action_buttons.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _isInRadius = false;
  bool _isGpsLoading = true;
  bool _isSubmitting = false;
  bool _isFakeGps = false;
  bool _isAttended = false;
  DateTime? _lastSubmitTime;

  List<AttendanceZone> _zones = AttendanceZones.activeZones;
  AttendanceZone? _activeZone;

  late final AnimationController _chipController;
  late final Animation<double> _chipScale;

  @override
  void initState() {
    super.initState();
    _chipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    _chipScale = CurvedAnimation(
      parent: _chipController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _chipController.dispose();
    super.dispose();
  }

  void _onLocationDetected(
    AttendanceZone? activeZone,
    double distance,
    bool isFakeGps,
  ) {
    final inRadius = activeZone != null;
    final changed = inRadius != _isInRadius;

    if (isFakeGps && !_isFakeGps) {
      HapticFeedback.heavyImpact();
      _showSnackBar(
        'Terdeteksi Manipulasi Lokasi (Fake GPS). Absensi diblokir!',
        AppColors.dangerRed,
        AppIcons.warningOctagonFill,
      );
    } else if (changed && !_isGpsLoading && !isFakeGps) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _activeZone = activeZone;
      _isInRadius = inRadius && !isFakeGps;
      _isFakeGps = isFakeGps;
      _isGpsLoading = false;
    });

    if (changed && !isFakeGps) {
      _chipController.forward(from: 0.0);
    }
  }

  void _onGpsError(String message, bool isPermissionError) {
    setState(() => _isGpsLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              AppIcons.warningCircleFill,
              color: Colors.white,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.fontXs + 1,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'PENGATURAN',
          textColor: Colors.yellowAccent,
          onPressed: () => isPermissionError
              ? Geolocator.openAppSettings()
              : Geolocator.openLocationSettings(),
        ),
        backgroundColor: AppColors.dangerRed.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.lg,
          0,
          AppDimensions.lg,
          AppDimensions.xxl,
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _openQRScanner() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceQrScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      final String scannedZoneId = result['zoneId'];
      final matchedZone = _zones
          .where((z) => z.id == scannedZoneId)
          .firstOrNull;

      if (matchedZone != null) {
        _showSnackBar(
          'QR Code Valid: ${matchedZone.activityName}. Mengirim presensi...',
          AppColors.successGreen,
          AppIcons.checkCircleFill,
        );
        setState(() => _activeZone = matchedZone);
        _submitAttendance(fromQr: true);
      } else {
        _showSnackBar(
          'Kegiatan tidak ditemukan atau tidak aktif saat ini.',
          AppColors.dangerRed,
          AppIcons.warningOctagonFill,
        );
      }
    }
  }

  Future<void> _submitAttendance({bool fromQr = false}) async {
    if (_isSubmitting ||
        (!fromQr && !_isInRadius) ||
        _isFakeGps ||
        _isAttended) {
      return;
    }

    if (_isAttended) {
      _showSnackBar(
        'Anda sudah melakukan presensi untuk sesi ini.',
        AppColors.warningOrange,
        AppIcons.infoFill,
      );
      return;
    }

    final bool isAlpha =
        _activeZone != null && DateTime.now().isAfter(_activeZone!.cutoffTime);
    if (isAlpha) {
      HapticFeedback.vibrate();
      _showErrorDialog(
        'Absensi Ditutup',
        'Waktu toleransi kehadiran untuk sesi ini telah sepenuhnya berakhir. Status Anda otomatis tercatat sebagai ALPHA.',
      );
      return;
    }

    if (_lastSubmitTime != null) {
      HapticFeedback.vibrate();
      _showErrorDialog(
        'Absensi Ditolak',
        'Sistem mendeteksi Anda telah berhasil melakukan presensi pada sesi kegiatan ini.',
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    HapticFeedback.heavyImpact();

    setState(() {
      _isSubmitting = false;
      _lastSubmitTime = DateTime.now();
      _isAttended = true;
      PimpinanMockData.attendanceReportCount += 1;
    });

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";
    PimpinanMockData.serdikAttendanceHistory.insert(0, {
      'id': 'att_${now.millisecondsSinceEpoch}',
      'title': _activeZone?.activityName ?? 'Kegiatan Presensi',
      'date': '${now.day}-${now.month}-${now.year}',
      'time': timeStr,
      'dateTime': now,
      'status': 'Hadir',
      'type': 'hadir',
      'method': fromQr ? 'QR Code' : 'Geofencing',
      'verification': 'Valid',
      'location': _activeZone?.name ?? 'Lokasi Sespimma',
      'device': 'Perangkat Serdik',
      'image': 'assets/images/avatar.png',
    });

    final activityName = _activeZone?.activityName ?? 'Kegiatan Presensi';
    final bool isLate =
        _activeZone != null && now.isAfter(_activeZone!.deadline);

    if (isLate) {
      _showSnackBar(
        'Tercatat masuk di jam $timeStr (Terlambat) untuk $activityName.',
        AppColors.warningOrange,
        AppIcons.clockClockwiseFill,
      );
    } else {
      _showSnackBar(
        'Berhasil absen di jam $timeStr untuk kegiatan $activityName.',
        AppColors.successGreen,
        AppIcons.checkCircleFill,
      );
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        title: Row(
          children: [
            const Icon(AppIcons.warningOctagonFill, color: AppColors.dangerRed),
            const SizedBox(width: AppDimensions.md),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.fontLg,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'MENGERTI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppDimensions.iconSm),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.fontSm,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl - 4),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.lg,
          0,
          AppDimensions.lg,
          AppDimensions.xxl,
        ),
        elevation: 8,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showZoneInfo(BuildContext context, [AttendanceZone? specificZone]) {
    final zoneToShow = specificZone ?? _activeZone;

    if (zoneToShow == null || _isGpsLoading) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXxl),
          ),
        ),
        builder: (sheetCtx) =>
            EmptyZoneSheet(onToggleMakerindo: _onToggleMakerindo),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      builder: (sheetCtx) => ZoneInfoSheet(
        zone: zoneToShow,
        onLeaveRequest: () {
          Navigator.pop(sheetCtx);
          _showLeaveForm(context);
        },
        onToggleMakerindo: _onToggleMakerindo,
      ),
    );
  }

  void _onToggleMakerindo(bool val) {
    Navigator.pop(context);
    setState(() {
      AttendanceZones.isMakerindoEnabled = val;
      _zones = AttendanceZones.activeZones;
    });
    HapticFeedback.mediumImpact();
    _showSnackBar(
      'Simulasi Zona Makerindo ${_resolveMakerindoStatusText(val)}!',
      _resolveMakerindoStatusColor(val),
      _resolveMakerindoStatusIcon(val),
    );
  }

  String _resolveMakerindoStatusText(bool val) {
    if (val) return "Diaktifkan";
    return "Dinonaktifkan";
  }

  Color _resolveMakerindoStatusColor(bool val) {
    if (val) return AppColors.successGreen;
    return AppColors.warningOrange;
  }

  IconData _resolveMakerindoStatusIcon(bool val) {
    if (val) return AppIcons.checkCircleFill;
    return AppIcons.infoFill;
  }

  void _showLeaveForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      builder: (ctx) => LeaveFormSheet(
        onSuccess: () {
          _showSnackBar(
            'Permohonan Izin Berhasil Diajukan ke Pimpinan.',
            AppColors.successGreen,
            AppIcons.checkCircleFill,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zona Apel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontLg,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_zones.isNotEmpty)
            IconButton(
              icon: const Icon(
                AppIcons.infoBold,
                size: AppDimensions.iconSm + 2,
              ),
              tooltip: 'Info Zona',
              splashRadius: AppDimensions.radiusXxl,
              onPressed: () {
                HapticFeedback.selectionClick();
                _showZoneInfo(context, _activeZone);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GeofenceMapWidget(
              zones: _zones,
              onLocationDetected: _onLocationDetected,
              onGpsError: _onGpsError,
              onReload: () {
                setState(() => _zones = AttendanceZones.activeZones);
                _showSnackBar(
                  'Daftar Radius dan Geofence berhasil diperbarui!',
                  AppColors.successGreen,
                  AppIcons.checkCircleFill,
                );
              },
              onRadiusTap: (tappedZone) => _showZoneInfo(context, tappedZone),
            ),
          ),
          Positioned(
            top: AppDimensions.lg,
            left: 0,
            right: 0,
            child: Center(
              child: AttendanceStatusChip(
                zones: _zones,
                activeZone: _activeZone,
                isGpsLoading: _isGpsLoading,
                isFakeGps: _isFakeGps,
                isInRadius: _isInRadius,
                chipScale: _chipScale,
              ),
            ),
          ),
          Positioned(
            bottom: AppDimensions.xxxl,
            left: AppDimensions.lg,
            right: AppDimensions.lg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child:
                      (_activeZone != null &&
                          !_isGpsLoading &&
                          _isInRadius &&
                          !_isFakeGps)
                      ? AttendanceFloatingInfo(
                          activeZone: _activeZone!,
                          isInRadius: _isInRadius,
                          onTapInfo: () => _showZoneInfo(context),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: AppDimensions.lg),
                AttendanceActionButtons(
                  isAttended: _isAttended,
                  isInRadius: _isInRadius,
                  isSubmitting: _isSubmitting,
                  activeZone: _activeZone,
                  onOpenQr: _openQRScanner,
                  onSubmit: _submitAttendance,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
