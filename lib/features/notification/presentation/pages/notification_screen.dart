import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../assessment/data/models/sociometry_period_config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Map<String, dynamic>> _mockNotifications;
  bool _isDataPopulated = false;

  String _getDynamicDateStr(int daysAgo) {
    final target = DateTime.now().subtract(Duration(days: daysAgo));
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    final dayIndex = target.weekday == 7 ? 0 : target.weekday;
    final dayName = days[dayIndex];
    final monthName = months[target.month - 1];
    return '$dayName, ${target.day} $monthName ${target.year}';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    _mockNotifications = [];
  }

  void _populateNotifications(UserEntity user) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final role = user.roleId.toLowerCase();

    final List<Map<String, dynamic>> list = [];

    if (role == 'siswa') {
      if (SociometryPeriodConfig.isAnyActive()) {
        final count = SociometryPeriodConfig.getFilledCount();
        final total = SociometryPeriodConfig.getTotalCount();
        final remaining = total - count;

        list.add({
          'id': 'notif_sosio_start',
          'title': 'Sosiometri Peleton Dimulai',
          'body':
              'Hari ini sosiometri telah dimulai. Silakan isi penilaian untuk seluruh rekan peleton Anda.',
          'date': _getDynamicDateStr(0),
          'time': '07:00 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'sosiometri_start',
        });

        if (remaining > 0) {
          list.add({
            'id': 'notif_sosio_remind',
            'title': 'Pengingat Sosiometri',
            'body':
                '$remaining rekan lagi belum Anda isi sosiometrinya. Tenggat waktu hampir habis, segera lengkapi.',
            'date': _getDynamicDateStr(0),
            'time': '12:00 WIB',
            'dateTime': today,
            'isRead': false,
            'type': 'sosiometri_reminder',
          });
        } else {
          list.add({
            'id': 'notif_sosio_done',
            'title': 'Sosiometri Selesai',
            'body':
                'Terima kasih, Anda telah mengisi sosiometri untuk seluruh rekan peleton Anda dengan lengkap.',
            'date': _getDynamicDateStr(0),
            'time': '14:00 WIB',
            'dateTime': today,
            'isRead': false,
            'type': 'sosiometri_done',
          });
        }
      }

      list.addAll([
        {
          'id': 'n_kegiatan_baru',
          'title': 'Kegiatan Baru dari Korsis',
          'body':
              'Korsis telah membuat kegiatan "Apel Pagi Gabungan". Harap bersiap dan pastikan kehadiran Anda.',
          'date': _getDynamicDateStr(0),
          'time': '06:00 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'info',
        },
        {
          'id': 'n_reward',
          'title': 'Reward: Menjadi Imam Shalat',
          'body':
              'Selamat! Anda mendapatkan reward +0.50 nilai mental dari Patun A.',
          'date': _getDynamicDateStr(0),
          'time': '18:30 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'reward',
        },
        {
          'id': 'n_punish',
          'title': 'Punishment: Terlambat Apel',
          'body':
              'Tercatat keterlambatan apel pagi via geofencing. Pengurangan nilai -0.50.',
          'date': _getDynamicDateStr(0),
          'time': '07:15 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'punishment',
        },
        {
          'id': 'n_task_done',
          'title': 'Tugas: Naskah Karya Perseorangan',
          'body':
              'Tugas Anda telah selesai dinilai oleh Patun. Nilai Anda: 88.5.',
          'date': _getDynamicDateStr(1),
          'time': '09:00 WIB',
          'dateTime': yesterday,
          'isRead': true,
          'type': 'task_dinilai',
        },
        {
          'id': 'n_task_wait',
          'title': 'Tugas: Resume Kepemimpinan',
          'body':
              'Berhasil mengumpulkan tepat waktu. Status saat ini: Sedang dinilai oleh Patun.',
          'date': _getDynamicDateStr(1),
          'time': '14:00 WIB',
          'dateTime': yesterday,
          'isRead': true,
          'type': 'task_sedang_dinilai',
        },
        {
          'id': 'n_task_late',
          'title': 'Tugas Terlambat: Esai Pengendalian Diri',
          'body':
              'Anda mengumpulkan tugas melewati batas waktu yang ditentukan. Menunggu penilaian.',
          'date': _getDynamicDateStr(2),
          'time': '16:00 WIB',
          'dateTime': today.subtract(const Duration(days: 2)),
          'isRead': true,
          'type': 'task_telat',
        },
        {
          'id': 'n_task_miss',
          'title': 'Tugas Tidak Dikumpulkan: Sistem Informasi',
          'body':
              'Batas waktu telah habis dan Anda belum mengumpulkan tugas ini.',
          'date': _getDynamicDateStr(2),
          'time': '23:59 WIB',
          'dateTime': today.subtract(const Duration(days: 2)),
          'isRead': true,
          'type': 'task_alpha',
        },
        {
          'id': 'n_att_hadir',
          'title': 'Kehadiran: Kelas Kepemimpinan',
          'body': 'Status kehadiran Anda tercatat: Hadir.',
          'date': _getDynamicDateStr(3),
          'time': '08:30 WIB',
          'dateTime': today.subtract(const Duration(days: 3)),
          'isRead': true,
          'type': 'hadir',
        },
        {
          'id': 'n_att_telat',
          'title': 'Kehadiran: Apel Pagi',
          'body': 'Status kehadiran Anda tercatat: Telat (Terlambat 15 menit).',
          'date': _getDynamicDateStr(3),
          'time': '07:15 WIB',
          'dateTime': today.subtract(const Duration(days: 3)),
          'isRead': true,
          'type': 'telat',
        },
        {
          'id': 'n_att_izin',
          'title': 'Kehadiran: Kelas Manajemen',
          'body':
              'Status kehadiran Anda tercatat: Izin. Surat sakit telah divalidasi.',
          'date': _getDynamicDateStr(4),
          'time': '08:30 WIB',
          'dateTime': today.subtract(const Duration(days: 4)),
          'isRead': true,
          'type': 'izin',
        },
        {
          'id': 'n_att_alpha',
          'title': 'Kehadiran: Olahraga Bersama',
          'body': 'Status kehadiran Anda tercatat: Alpha (Tanpa keterangan).',
          'date': _getDynamicDateStr(4),
          'time': '06:00 WIB',
          'dateTime': today.subtract(const Duration(days: 4)),
          'isRead': true,
          'type': 'alpha',
        },
      ]);
    } else if (role == 'gadik' || role == 'patun' || role == 'instruktur') {
      if (SociometryPeriodConfig.isAnyActive()) {
        list.add({
          'id': 'notif_gadik_sosio',
          'title': 'Monitoring Sosiometri Aktif',
          'body':
              'Periode sosiometri peleton sedang berjalan di aplikasi siswa. Silakan pantau rekapitulasi progres partisipasi.',
          'date': _getDynamicDateStr(0),
          'time': 'Baru saja',
          'dateTime': today,
          'isRead': false,
          'type': 'task',
        });
      }

      list.addAll([
        {
          'id': 'notif_g001',
          'title': 'Laporan Fisik Jasmani Baru',
          'body':
              'Data mentah (Hasil Gerakan) penilaian jasmani baru saja disinkronisasikan dari Pleton B.',
          'date': _getDynamicDateStr(0),
          'time': '11:00 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'task',
        },
        {
          'id': 'notif_g002',
          'title': 'Tugas Dikumpulkan',
          'body':
              'Sebanyak 25 / 30 Siswa telah mengumpulkan Resume Kepemimpinan dan siap dilakukan penilaian.',
          'date': _getDynamicDateStr(0),
          'time': '09:00 WIB',
          'dateTime': today,
          'isRead': false,
          'type': 'info',
        },
        {
          'id': 'notif_g003',
          'title': 'Jadwal Mengajar Besok',
          'body':
              'Kelas Etika Kepemimpinan dan Administrasi Polri besok pukul 08:00 WIB di Gedung C.',
          'date': _getDynamicDateStr(1),
          'time': '17:00 WIB',
          'dateTime': yesterday,
          'isRead': true,
          'type': 'info',
        },
      ]);
    } else {
      list.add({
        'id': 'notif_p002',
        'title': 'Peringatan Zona Tinggi',
        'body':
            'Sistem EWS mendeteksi adanya serdik yang berada pada zona risiko tinggi. Mohon segera lakukan peninjauan.',
        'date': _getDynamicDateStr(0),
        'time': 'Baru saja',
        'dateTime': today,
        'isRead': false,
        'type': 'punishment',
      });
    }

    setState(() {
      _mockNotifications = list;
      _isDataPopulated = true;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  DateTimeRange? _selectedDateRange;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day),
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      initialDateRange: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryNavy,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess && !_isDataPopulated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDataPopulated) {
              _populateNotifications(state.user);
            }
          });
        }

        final filteredNotifs = _selectedDateRange == null
            ? _mockNotifications
            : _mockNotifications.where((notif) {
                final dt = notif['dateTime'] as DateTime;
                final start = DateTime(
                  _selectedDateRange!.start.year,
                  _selectedDateRange!.start.month,
                  _selectedDateRange!.start.day,
                );
                final end = DateTime(
                  _selectedDateRange!.end.year,
                  _selectedDateRange!.end.month,
                  _selectedDateRange!.end.day,
                  23,
                  59,
                  59,
                );
                return dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
                    dt.isBefore(end.add(const Duration(seconds: 1)));
              }).toList();

        final Map<String, List<Map<String, dynamic>>> groupedNotifs = {};
        for (var notif in filteredNotifs) {
          final date = notif['date'] as String;
          if (!groupedNotifs.containsKey(date)) {
            groupedNotifs[date] = [];
          }
          groupedNotifs[date]!.add(notif);
        }

        if (state is AuthInitial ||
            (state is AuthSuccess && !_isDataPopulated)) {
          return const Scaffold(
            backgroundColor: _lightGrey,
            body: Center(child: CircularProgressIndicator(color: _primaryNavy)),
          );
        }

        return Scaffold(
          backgroundColor: _lightGrey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Notifikasi',
              style: TextStyle(
                color: _primaryNavy,
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.fontXl,
              ),
            ),
            leading: IconButton(
              icon: const Icon(AppIcons.caretLeft, color: _primaryNavy),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _selectedDateRange != null
                      ? AppIcons.calendarFill
                      : AppIcons.calendarBlank,
                  color: _selectedDateRange != null
                      ? Colors.teal.shade600
                      : _primaryNavy,
                  size: AppDimensions.iconDefault + 2,
                ),
                tooltip: 'Filter Tanggal',
                onPressed: _pickDateRange,
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  AppIcons.dotsThreeVertical,
                  color: _primaryNavy,
                ),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                onSelected: (value) {
                  if (value == 'refresh') {
                    setState(() {
                      _animController.reset();
                      _animController.forward();
                    });
                  } else if (value == 'read_all') {
                    setState(() {
                      for (var element in _mockNotifications) {
                        element['isRead'] = true;
                      }
                    });
                  } else if (value == 'clear_filter') {
                    setState(() {
                      _selectedDateRange = null;
                    });
                    _animController.reset();
                    _animController.forward();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'refresh',
                    child: Text(
                      'Refresh',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'read_all',
                    child: Text(
                      'Tandai sudah dibaca',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_selectedDateRange != null) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'clear_filter',
                      child: Text(
                        'Bersihkan Filter',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: AppDimensions.sm),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: filteredNotifs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount: groupedNotifs.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedNotifs.keys.elementAt(index);
                        final items = groupedNotifs[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 12,
                                top: index == 0 ? 0 : 16,
                              ),
                              child: Text(
                                dateKey,
                                style: TextStyle(
                                  fontSize: AppDimensions.fontLg,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                            ...items.map((notif) {
                              final itemIndex = filteredNotifs.indexOf(notif);
                              final animation = CurvedAnimation(
                                parent: _animController,
                                curve: Interval(
                                  (itemIndex / filteredNotifs.length).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              );
                              return Dismissible(
                                key: ValueKey(notif['id']),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD32F2F),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusLg,
                                    ),
                                  ),
                                  child: const Icon(
                                    AppIcons.trashFill,
                                    color: Colors.white,
                                    size: AppDimensions.iconDefault + 2,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  HapticFeedback.mediumImpact();
                                  final String deletedId =
                                      notif['id'] as String;
                                  setState(() {
                                    _mockNotifications.removeWhere(
                                      (item) => item['id'] == deletedId,
                                    );
                                  });
                                  AppNotifier.showSuccess(
                                    context,
                                    'Notifikasi berhasil dihapus',
                                  );
                                },
                                child: _AnimatedNotificationTile(
                                  notification: notif,
                                  animation: animation,
                                  onTap: () {
                                    final String currentId =
                                        notif['id'] as String;
                                    setState(() {
                                      final foundIndex = _mockNotifications
                                          .indexWhere(
                                            (n) => n['id'] == currentId,
                                          );
                                      if (foundIndex != -1) {
                                        _mockNotifications[foundIndex]['isRead'] =
                                            true;
                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _animController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.bellSlash,
                size: AppDimensions.iconDisplay,
                color: Colors.blueGrey.shade300,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Tidak Ada Notifikasi',
              style: TextStyle(
                fontSize: AppDimensions.fontXxl,
                fontWeight: FontWeight.w800,
                color: _primaryNavy,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Belum ada aktivitas atau pemberitahuan.',
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
    );
  }
}

class _AnimatedNotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _AnimatedNotificationTile({
    required this.notification,
    required this.animation,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification['type']) {
      case 'reward':
        return AppIcons.thumbUp;
      case 'punishment':
        return AppIcons.thumbDown;
      case 'task_dinilai':
        return AppIcons.checkCircleFill;
      case 'task_sedang_dinilai':
        return AppIcons.clipboardTextFill;
      case 'task_telat':
        return AppIcons.clockFill;
      case 'task_alpha':
        return AppIcons.xCircleFill;
      case 'sosiometri_start':
        return AppIcons.usersThreeFill;
      case 'sosiometri_reminder':
        return AppIcons.usersThreeFill;
      case 'sosiometri_done':
        return AppIcons.checkCircleFill;
      case 'hadir':
        return AppIcons.userFocusFill;
      case 'telat':
        return AppIcons.clockFill;
      case 'izin':
        return AppIcons.filePdfFill;
      case 'alpha':
        return AppIcons.warningOctagonFill;
      case 'task':
        return AppIcons.clipboardTextFill;
      default:
        return AppIcons.infoFill;
    }
  }

  Color _getColor() {
    switch (notification['type']) {
      case 'reward':
        return const Color(0xFF2E7D32);
      case 'punishment':
        return const Color(0xFFD32F2F);
      case 'task_dinilai':
        return const Color(0xFF2E7D32);
      case 'task_sedang_dinilai':
        return Colors.blue.shade600;
      case 'task_telat':
        return const Color(0xFFFBC02D);
      case 'task_alpha':
        return const Color(0xFFD32F2F);
      case 'sosiometri_start':
        return const Color(0xFF4F46E5);
      case 'sosiometri_reminder':
        return const Color(0xFFF57C00);
      case 'sosiometri_done':
        return const Color(0xFF2E7D32);
      case 'hadir':
        return const Color(0xFF2E7D32);
      case 'telat':
        return const Color(0xFFFBC02D);
      case 'izin':
        return const Color(0xFFF57C00);
      case 'alpha':
        return const Color(0xFFD32F2F);
      case 'task':
        return Colors.blue.shade600;
      case 'info':
        return Colors.amber.shade700;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['isRead'];
    final iconColor = _getColor();

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isRead ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isRead
                  ? Colors.grey.shade300
                  : iconColor.withValues(alpha: 0.3),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: isRead
                ? []
                : [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.sm + 2),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.grey.shade100
                            : iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(),
                        color: isRead ? Colors.grey.shade500 : iconColor,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontSize: AppDimensions.fontLg,
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: const Color(0xFF001C40),
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD32F2F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.radiusSm),
                          Text(
                            notification['body'],
                            style: TextStyle(
                              fontSize: AppDimensions.fontDefault,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            notification['time'],
                            style: TextStyle(
                              fontSize: AppDimensions.fontSm + 1,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade400,
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
        ),
      ),
    );
  }
}
