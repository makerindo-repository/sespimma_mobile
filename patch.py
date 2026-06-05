import re

with open('lib/features/activity/presentation/pages/activity_history_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
content = re.sub(
    r"import '../../../leadership_dashboard/data/datasources/pimpinan_mock_data.dart';",
    "import '../../../leadership_dashboard/data/datasources/pimpinan_mock_data.dart';\nimport '../../../assignment/data/models/tugas_model.dart';\nimport '../../../attendance/domain/models/map_tile_mode.dart';\nimport '../../../assessment/data/models/korsis_inbox_mock_data.dart';",
    content
)

# 2. Filters
content = re.sub(
    r"final List<String> _filters = \['Semua', 'Reward', 'Punishment', 'Tugas'\];",
    "final List<String> _filters = ['Semua', 'Reward', 'Punishment', 'Tugas', 'Zona'];",
    content
)

# 3. Filter Logic
filter_logic_old = """                if (_selectedFilter == 'Reward') return a['type'] == 'reward';
                if (_selectedFilter == 'Punishment') {
                  return a['type'] == 'punishment';
                }
                if (_selectedFilter == 'Tugas') return a['type'] == 'task';
                return true;"""
filter_logic_new = """                if (_selectedFilter == 'Reward') return a['type'] == 'reward';
                if (_selectedFilter == 'Punishment') {
                  return a['type'] == 'punishment';
                }
                if (_selectedFilter == 'Tugas') return a['type'] == 'task' || a['type'] == 'task_dikirim' || a['type'] == 'task_dinilai' || a['type'] == 'task_remedial';
                if (_selectedFilter == 'Zona') return a['type'] == 'zone';
                return true;"""
content = content.replace(filter_logic_old, filter_logic_new)

# 4. _getDynamicDateStr and _formatDynamicTime
time_funcs_old = """  String _getDynamicDateStr(int daysAgo) {
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

  String _formatDynamicTime(String rawTimeWib, String targetTz) {
    final parts = rawTimeWib.split(':');
    if (parts.length < 2) return rawTimeWib;
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    int shift = 0;
    if (targetTz == 'WITA') shift = 1;
    if (targetTz == 'WIT') shift = 2;

    int targetHour = (hour + shift) % 24;
    final hourStr = targetHour.toString().padLeft(2, '0');

    return '$hourStr:$minute $targetTz';
  }"""

time_funcs_new = """  String _getDynamicDateStr(DateTime target) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final monthName = months[target.month - 1];
    return '${target.day} $monthName ${target.year}';
  }

  String _formatDynamicTime(DateTime target) {
    final hourStr = target.hour.toString().padLeft(2, '0');
    final minStr = target.minute.toString().padLeft(2, '0');
    return '$hourStr.$minStr';
  }

  String _getGadikFullName(String sender) {
    if (sender == 'Gadik A') return 'Kombes Pol. Anton Suratto';
    if (sender == 'Gadik B') return 'Kombes Pol. Budi Santoso';
    if (sender == 'Gadik C') return 'Kombes Pol. Candra Muka';
    if (sender == 'Korsis A') return 'Kombes Pol. Ahmad Setiawan';
    if (sender == 'Patun A') return 'Kombes Pol. Bambang Sugeng';
    return sender;
  }"""
content = content.replace(time_funcs_old, time_funcs_new)

# 5. _populateActivities
populate_old = re.search(r"  void _populateActivities\(UserEntity user\) \{.*?(?=    setState\(\(\) \{)", content, re.DOTALL).group(0)

populate_new = """  void _populateActivities(UserEntity user) {
    final today = DateTime.now();
    final role = user.roleId.toLowerCase();

    final List<Map<String, dynamic>> list = [];

    if (role == 'siswa') {
      if (SociometryPeriodConfig.isAnyActive()) {
        final filledCount = SociometryPeriodConfig.getFilledCount();
        if (filledCount > 0) {
          final totalCount = SociometryPeriodConfig.getTotalCount();
          final phase = SociometryPeriodConfig.isAkhirActive() ? 'Akhir' : 'Awal';
          list.add({
            'id': 'act_dyn_sosiometri',
            'title': 'Pengisian Sosiometri $phase',
            'subtitle': 'Telah berhasil mengisi partisipasi evaluasi sosiometri untuk $filledCount / $totalCount rekan peleton.',
            'timeRaw': _formatDynamicTime(today),
            'date': _getDynamicDateStr(today),
            'dateTime': today,
            'points': '',
            'type': 'task',
          });
        }
      }

      if (user.isNakApproved == true) {
        list.add({
          'id': 'act_dyn_nak',
          'title': 'Nilai Akhir Disetujui',
          'subtitle': 'Nilai Akhir Keseluruhan (NAK) Anda telah disetujui dan divalidasi oleh Pimpinan Sespimma.',
          'timeRaw': _formatDynamicTime(today),
          'date': _getDynamicDateStr(today),
          'dateTime': today,
          'points': '',
          'type': 'info',
        });
      }

      for (var inbox in KorsisInboxMockData.items) {
        if (inbox.status == 'disetujui') {
          final isReward = inbox.isReward;
          final typeStr = isReward ? 'reward' : 'punishment';
          final pointStr = isReward ? '+${inbox.points.toStringAsFixed(2)}' : inbox.points.toStringAsFixed(2);
          list.add({
            'id': inbox.id,
            'title': inbox.rewardPunishmentName,
            'subtitle': 'Diberikan oleh ${_getGadikFullName(inbox.senderName)}',
            'timeRaw': _formatDynamicTime(inbox.createdAt),
            'date': _getDynamicDateStr(inbox.createdAt),
            'dateTime': inbox.createdAt,
            'points': pointStr,
            'type': typeStr,
            'photoPath': inbox.photoPath,
          });
        }
      }

      for (var zone in AttendanceZones.activeZones) {
        list.add({
          'id': 'zone_${zone.id}',
          'title': zone.title,
          'subtitle': '${zone.locationName} telah dibuat oleh ${_getGadikFullName(zone.createdBy)}. Segera melakukan presensi.',
          'timeRaw': _formatDynamicTime(zone.createdAt),
          'date': _getDynamicDateStr(zone.createdAt),
          'dateTime': zone.createdAt,
          'points': '',
          'type': 'zone',
        });
      }

      for (var task in GadikAssignmentMockData.assignments) {
        if (task.status == 'Belum Mulai' || task.status == 'Sedang Berjalan') {
          list.add({
            'id': 'task_${task.id}',
            'title': task.judul,
            'subtitle': 'Segera kumpulkan tugas sebelum tenggat waktu ${_getDynamicDateStr(task.deadline)}, ${_formatDynamicTime(task.deadline)}.',
            'timeRaw': _formatDynamicTime(task.deadline.subtract(const Duration(days: 1))),
            'date': _getDynamicDateStr(task.deadline.subtract(const Duration(days: 1))),
            'dateTime': task.deadline.subtract(const Duration(days: 1)),
            'points': '',
            'type': 'task',
          });
        } else if (task.status == 'Selesai') {
          list.add({
            'id': 'task_${task.id}',
            'title': task.judul,
            'subtitle': 'Selamat tugas kamu sudah dikirim ke ${_getGadikFullName(task.createdBy)}. Terus pantau riwayat tugas untuk melihat nilai',
            'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 2))),
            'date': _getDynamicDateStr(today.subtract(const Duration(hours: 2))),
            'dateTime': today.subtract(const Duration(hours: 2)),
            'points': '',
            'type': 'task_dikirim',
          });
        } else if (task.status == 'Dinilai') {
          list.add({
            'id': 'task_${task.id}',
            'title': task.judul,
            'subtitle': 'Selamat tugas kamu sudah dinilai oleh ${_getGadikFullName(task.createdBy)}. Silahkan cek nilaimu segera',
            'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 4))),
            'date': _getDynamicDateStr(today.subtract(const Duration(hours: 4))),
            'dateTime': today.subtract(const Duration(hours: 4)),
            'points': '',
            'type': 'task_dinilai',
          });
        } else if (task.status == 'Remedial') {
          list.add({
            'id': 'task_${task.id}',
            'title': task.judul,
            'subtitle': 'Remedial untuk kamu, segera cek tugas aktif. Kumpulkan sebelum tenggat waktu (${_getDynamicDateStr(task.deadline)}, ${_formatDynamicTime(task.deadline)})',
            'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 1))),
            'date': _getDynamicDateStr(today.subtract(const Duration(hours: 1))),
            'dateTime': today.subtract(const Duration(hours: 1)),
            'points': '',
            'type': 'task_remedial',
          });
        }
      }

    } else if (role == 'gadik' || role == 'patun' || role == 'instruktur') {
      if (SociometryPeriodConfig.isAnyActive()) {
        list.add({
          'id': 'act_gadik_dyn_sosiometri',
          'title': 'Memonitor Progres Sosiometri',
          'subtitle': 'Mengakses panel rekapitulasi pengisian evaluasi sosiometri peleton yang sedang berlangsung.',
          'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 1))),
          'date': _getDynamicDateStr(today),
          'dateTime': today,
          'points': '',
          'type': 'task',
        });
      }

      list.addAll([
        {
          'id': 'act_g001',
          'title': 'Penilaian Resume Kepemimpinan',
          'subtitle': 'Selesai melakukan penilaian dan input skor ke portal akademik untuk 25 Siswa.',
          'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 2))),
          'date': _getDynamicDateStr(today),
          'dateTime': today,
          'points': '',
          'type': 'task',
        },
        {
          'id': 'act_g002',
          'title': 'Pemberian Reward Karakter Siswa',
          'subtitle': 'Pemberian +0.50 poin mental kepada Siswa Budi Hartono atas prakarsa ketertiban.',
          'timeRaw': _formatDynamicTime(today.subtract(const Duration(hours: 4))),
          'date': _getDynamicDateStr(today),
          'dateTime': today,
          'points': '',
          'type': 'task',
        },
      ]);
    }

"""
content = content.replace(populate_old, populate_new)

# 6. Item build mapping (photoPath)
item_mapping_old = """                                    final formattedTime = _formatDynamicTime(
                                      item['timeRaw'],
                                      _selectedTimezone,
                                    );
                                    return _AnimatedActivityTile(
                                      key: ValueKey(item['id']),
                                      title: item['title'],
                                      subtitle: item['subtitle'],
                                      time: formattedTime,
                                      points: item['points'],
                                      type: item['type'],
                                      animation: animation,
                                    );"""
item_mapping_new = """                                    return _AnimatedActivityTile(
                                      key: ValueKey(item['id']),
                                      title: item['title'],
                                      subtitle: item['subtitle'],
                                      time: item['timeRaw'],
                                      points: item['points'],
                                      type: item['type'],
                                      photoPath: item['photoPath'],
                                      animation: animation,
                                    );"""
content = content.replace(item_mapping_old, item_mapping_new)

# 7. _AnimatedActivityTile parameters & UI
tile_old = """class _AnimatedActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String points;
  final String type;
  final Animation<double> animation;

  const _AnimatedActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.points,
    required this.type,
    required this.animation,
  });"""
tile_new = """class _AnimatedActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String points;
  final String type;
  final String? photoPath;
  final Animation<double> animation;

  const _AnimatedActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.points,
    required this.type,
    this.photoPath,
    required this.animation,
  });"""
content = content.replace(tile_old, tile_new)

tile_switch_old = """    switch (type) {
      case 'task':
        iconColor = Colors.blue.shade600;
        iconData = AppIcons.clipboardTextFill;
        break;
      case 'reward':
        iconColor = const Color(0xFF2E7D32);
        iconData = AppIcons.thumbUp;
        break;
      case 'punishment':
        iconColor = const Color(0xFFD32F2F);
        iconData = AppIcons.thumbDown;
        break;
      case 'info':
      default:
        iconColor = Colors.amber.shade700;
        iconData = AppIcons.infoFill;
        break;
    }"""
tile_switch_new = """    switch (type) {
      case 'task':
      case 'task_dikirim':
      case 'task_dinilai':
      case 'task_remedial':
        iconColor = Colors.blue.shade600;
        iconData = AppIcons.clipboardTextFill;
        break;
      case 'reward':
        iconColor = const Color(0xFF2E7D32);
        iconData = AppIcons.thumbUp;
        break;
      case 'punishment':
        iconColor = const Color(0xFFD32F2F);
        iconData = AppIcons.thumbDown;
        break;
      case 'zone':
        iconColor = Colors.teal.shade600;
        iconData = AppIcons.mapPinLineFill;
        break;
      case 'info':
      default:
        iconColor = Colors.amber.shade700;
        iconData = AppIcons.infoFill;
        break;
    }"""
content = content.replace(tile_switch_old, tile_switch_new)

tile_ontap_old = """              onTap: (type == 'task' || points.isEmpty)
                  ? null
                  : () {
                      EvidenceBottomSheet.show(
                        context,
                        title: title,
                        description: title,
                        evaluatorName: subtitle,
                        timeText: time,
                        points: points,
                        type: type,
                      );
                    },"""
tile_ontap_new = """              onTap: (type == 'reward' || type == 'punishment')
                  ? () {
                      EvidenceBottomSheet.show(
                        context,
                        title: title,
                        description: title,
                        evaluatorName: subtitle,
                        timeText: time,
                        points: points,
                        type: type,
                        photoPath: photoPath,
                      );
                    }
                  : null,"""
content = content.replace(tile_ontap_old, tile_ontap_new)

with open('lib/features/activity/presentation/pages/activity_history_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Patched successfully!")

