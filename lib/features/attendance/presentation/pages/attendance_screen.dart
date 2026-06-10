import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/features/attendance/domain/models/map_tile_mode.dart';
import 'package:sespimma_mobile/features/attendance/presentation/pages/attendance_qr_scanner_screen.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/geofence_map_widget.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/zone_info_sheet.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/assessment/data/models/korsis_inbox_mock_data.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/empty_zone_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/leave_form_sheet.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_status_chip.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_floating_info.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/attendance_action_buttons.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:dio/dio.dart';
import 'package:sespimma_mobile/features/attendance/data/services/location_sync_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:sespimma_mobile/injection_container.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _isInRadius = false;
  bool _isGpsLoading = true;
  bool _isFakeGps = false;
  DateTime? _lastSubmitTime;

  final _hasGpsError = ValueNotifier<bool>(false);
  final _isSubmitting = ValueNotifier<bool>(false);
  final _isAttended = ValueNotifier<bool>(false);

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

    LocationSyncService().startSyncing();
    _loadZonesFromApi();
  }

  @override
  void dispose() {
    LocationSyncService().stopSyncing();
    _chipController.dispose();
    _hasGpsError.dispose();
    _isSubmitting.dispose();
    _isAttended.dispose();
    super.dispose();
  }

  Future<void> _loadZonesFromApi() async {
    await AttendanceZones.loadFromApi(sl<Dio>());
    if (mounted) {
      setState(() {
        _zones = AttendanceZones.activeZones;
      });
    }
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
      AppNotifier.showError(
        context,
        'Terdeteksi Manipulasi Lokasi (Fake GPS). Absensi diblokir!',
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
        final bool isNotStarted = DateTime.now().isBefore(
          matchedZone.startTime,
        );
        if (isNotStarted) {
          AppNotifier.showWarning(context, 'Maaf kegiatan ini belum dimulai');
          return;
        }

        AppNotifier.showSuccess(
          context,
          'QR Code Valid: ${matchedZone.activityName}. Mengirim presensi...',
        );
        setState(() => _activeZone = matchedZone);
        _submitAttendance(fromQr: true);
      } else {
        AppNotifier.showError(
          context,
          'Kegiatan tidak ditemukan atau tidak aktif saat ini.',
        );
      }
    }
  }

  Future<void> _submitAttendance({bool fromQr = false}) async {
    final bool isNotStarted =
        _activeZone != null && DateTime.now().isBefore(_activeZone!.startTime);
    if (isNotStarted) {
      AppNotifier.showWarning(context, 'Maaf kegiatan ini belum dimulai');
      return;
    }

    if (_isSubmitting.value ||
        (!fromQr && !_isInRadius) ||
        _isFakeGps ||
        _isAttended.value) {
      return;
    }

    if (_isAttended.value) {
      AppNotifier.showWarning(
        context,
        'Anda sudah melakukan presensi untuk sesi ini.',
      );
      return;
    }

    final bool isAlpha =
        _activeZone != null && DateTime.now().isAfter(_activeZone!.cutoffTime);
    if (isAlpha) {
      HapticFeedback.vibrate();
      final punishmentCode = _activeZone!.isTraining
          ? 'P_D_12 (-0.80)'
          : 'P_D_05 (-0.90)';
      _showErrorDialog(
        'Absensi Ditutup',
        'Waktu toleransi kehadiran untuk sesi ini telah sepenuhnya berakhir. Status Anda otomatis tercatat sebagai TANPA KETERANGAN.\n\nSanksi pelanggaran: $punishmentCode',
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
    _isSubmitting.value = true;

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    HapticFeedback.heavyImpact();

    _isSubmitting.value = false;
    _lastSubmitTime = DateTime.now();
    _isAttended.value = true;
    PimpinanMockData.attendanceReportCount += 1;

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB";
    final activityName = _activeZone?.activityName ?? 'Kegiatan Presensi';
    bool isLate = _activeZone != null && now.isAfter(_activeZone!.deadline);
    final approvedIzins = KorsisInboxMockData.items
        .where((i) => i.isIzin && i.status == 'disetujui' && i.izinStartTime != null && i.izinEndTime != null);

    bool isOnIzin = false;
    for (var izin in approvedIzins) {
      if (now.isAfter(izin.izinStartTime!) && now.isBefore(izin.izinEndTime!) ||
          now.isAtSameMomentAs(izin.izinStartTime!) || now.isAtSameMomentAs(izin.izinEndTime!)) {
        isOnIzin = true;
        break;
      }
    }

    if (isOnIzin) {
      _isSubmitting.value = false;
      _showErrorDialog(
        'Status Izin Aktif',
        'Anda saat ini dalam masa Izin Khusus yang disetujui Korsis. Sistem otomatis mencatat absensi Anda sebagai IZIN.',
      );
      return;
    }

    String sName = 'Dummy User';
    String sNrp = '00000000';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      sName = authState.user.name;
      sNrp = authState.user.nrp;
    }

    PimpinanMockData.serdikAttendanceHistory.insert(0, {
      'id': 'att_${now.millisecondsSinceEpoch}',
      'title': activityName,
      'date': '${now.day}-${now.month}-${now.year}',
      'time': timeStr,
      'dateTime': now,
      'status': isLate ? 'Terlambat' : 'Hadir',
      'type': isLate ? 'telat' : 'hadir',
      'method': fromQr ? 'QR Code' : 'Geofencing',
      'verification': 'Valid',
      'location': _activeZone?.name ?? 'Lokasi Sespimma',
      'device': 'Perangkat Serdik',
      'image': 'assets/images/avatar.png',
      'nama': sName,
      'nrp': sNrp,
    });

    if (isLate) {
      final actLower = activityName.toLowerCase();
      final isApelOrOlga =
          actLower.contains('apel pagi') ||
          actLower.contains('apel malam') ||
          actLower.contains('olahraga pagi') ||
          actLower.contains('olga pagi');
      String punishmentCode = 'P_D_02';
      double pointsToDeduct = -0.53;
      String desc = 'Terlambat mengikuti kegiatan kelas/ceramah/pengarahan';

      if (isApelOrOlga) {
        punishmentCode = 'P_D_04';
        pointsToDeduct = -0.50;
        desc = 'Terlambat mengikuti apel/olahraga/kegiatan lain';
      } else if (fromQr || _isInRadius) {
        punishmentCode = 'P_D_01';
        pointsToDeduct = -0.50;
        desc = 'Terlambat mengikuti kegiatan yang telah ditentukan';
      }

      String sName = 'Dummy User';
      String sPangkat = 'AKP';
      String sNosis = '000000';
      String sPokjar = 'POKJAR 1';

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        sName = authState.user.name;
        sPangkat = authState.user.pangkat;
        sNosis = authState.user.noSerdik.isNotEmpty
            ? authState.user.noSerdik
            : authState.user.nrp;
        sPokjar = authState.user.pokjar.isNotEmpty
            ? authState.user.pokjar
            : 'POKJAR 1';
      }

      KorsisInboxMockData.addRecord(
        InboxItem(
          id: 'auto_punish_${now.millisecondsSinceEpoch}',
          serdikName: sName,
          pangkat: sPangkat,
          nosis: sNosis,
          pokjar: sPokjar,
          isReward: false,
          senderName: 'Sistem (Otomatis)',
          timestamp: now,
          points: pointsToDeduct,
          description: desc,
          rewardPunishmentName: '$punishmentCode | PUNISHMENT | DISIPLIN',
          status: 'disetujui',
        ),
      );

      AppNotifier.showWarning(
        context,
        'Tercatat masuk di jam $timeStr (Terlambat) untuk $activityName.\nSanksi pelanggaran: $punishmentCode ($pointsToDeduct)',
      );
    } else {
      AppNotifier.showSuccess(
        context,
        'Berhasil absen di jam $timeStr untuk kegiatan $activityName.',
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
      isScrollControlled: true,
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
    final status = val ? 'Diaktifkan' : 'Dinonaktifkan';
    if (val) {
      AppNotifier.showSuccess(context, 'Simulasi Zona Makerindo $status!');
    } else {
      AppNotifier.showWarning(context, 'Simulasi Zona Makerindo $status!');
    }
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
          AppNotifier.showSuccess(
            context,
            'Permohonan Izin Berhasil Diajukan ke Korsis.',
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
          'Zona',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
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
              onGpsStateChanged: (hasError) {
                if (mounted && _hasGpsError.value != hasError) {
                  _hasGpsError.value = hasError;
                }
              },
              onReload: () {
                setState(() => _zones = AttendanceZones.activeZones);
                AppNotifier.showSuccess(
                  context,
                  'Daftar Radius dan Geofence berhasil diperbarui!',
                );
              },
              onRadiusTap: (tappedZone) => _showZoneInfo(context, tappedZone),
            ),
          ),
          Positioned(
            top: AppDimensions.lg,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _hasGpsError,
              builder: (_, hasError, child) =>
                  hasError ? const SizedBox.shrink() : child!,
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
          ),
          Positioned(
            bottom: AppDimensions.xxxl,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _hasGpsError,
              builder: (_, hasError, _) => hasError
                  ? const SizedBox.shrink()
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.lg,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: (_activeZone != null &&
                                        !_isGpsLoading &&
                                        _isInRadius &&
                                        !_isFakeGps)
                                    ? AttendanceFloatingInfo(
                                        activeZone: _activeZone!,
                                        isInRadius: _isInRadius,
                                        onTapInfo: () =>
                                            _showZoneInfo(context),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(width: AppDimensions.lg),
                              ListenableBuilder(
                                listenable: Listenable.merge(
                                    [_isSubmitting, _isAttended]),
                                builder: (_, _) => AttendanceActionButtons(
                                  isAttended: _isAttended.value,
                                  isInRadius: _isInRadius,
                                  isSubmitting: _isSubmitting.value,
                                  activeZone: _activeZone,
                                  onOpenQr: _openQRScanner,
                                  onSubmit: _submitAttendance,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
