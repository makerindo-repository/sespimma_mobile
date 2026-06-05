import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../assessment/data/models/korsis_inbox_mock_data.dart';
import '../../../gadik_assignment/data/datasources/gadik_assignment_mock_data.dart';
import '../../../attendance/domain/models/map_tile_mode.dart';
import '../../../assessment/data/models/sociometry_period_config.dart';
import '../../../auth/data/datasources/gadik_real_data.dart';
import '../../../auth/data/datasources/korsis_real_data.dart';
import '../../../auth/data/datasources/patun_real_data.dart';
import '../../../auth/data/datasources/operator_real_data.dart';

class NotificationMockData {
  NotificationMockData._();

  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static final List<Map<String, dynamic>> items = [];

  static String _getGadikFullName(String gadikId) {
    try {
      final gadik = GadikRealData.records.firstWhere(
        (r) =>
            r['nrp_nip'] == gadikId || r['nama'].toString().contains(gadikId),
        orElse: () => GadikRealData.records.first,
      );
      return gadik['nama'] as String;
    } catch (e) {
      return gadikId;
    }
  }

  static String _getZoneCreatorFullName(String creator) {
    if (creator.toLowerCase() == 'korsis') {
      return KorsisRealData.records.first['nama'] as String;
    }
    for (var k in KorsisRealData.records) {
      if (k['nama'].toString().toLowerCase().contains(creator.toLowerCase())) {
        return k['nama'] as String;
      }
    }
    for (var p in PatunRealData.records) {
      if (p['nama'].toString().toLowerCase().contains(creator.toLowerCase())) {
        return p['nama'] as String;
      }
    }
    for (var o in OperatorRealData.records) {
      if (o['nama'].toString().toLowerCase().contains(creator.toLowerCase())) {
        return o['nama'] as String;
      }
    }
    return creator;
  }

  static void initialize(UserEntity user) {
    items.clear();
    int unread = 0;

    for (var task in GadikAssignmentMockData.assignments) {
      if (task.status == 'Belum Mulai' || task.status == 'Sedang Berjalan') {
        items.add({
          'id': 'task_${task.id}',
          'title': task.judul,
          'message':
              'Segera kumpulkan tugas sebelum tenggat waktu ${_formatDateWithTime(task.deadline)}',
          'dateTime': task.createdAt,
          'isRead': false,
          'type': 'task',
          'person': _getGadikFullName(task.createdBy),
        });
        unread++;
      } else if (task.status == 'Selesai') {
        items.add({
          'id': 'task_${task.id}',
          'title': task.judul,
          'message':
              'Selamat tugas kamu sudah dikirim ke ${_getGadikFullName(task.createdBy)} terus pantau riwayat tugas untuk melihat nilai',
          'dateTime': task.createdAt,
          'isRead': true,
          'type': 'task_dikirim',
          'person': _getGadikFullName(task.createdBy),
        });
      } else if (task.status == 'Dinilai') {
        items.add({
          'id': 'task_${task.id}',
          'title': task.judul,
          'message':
              'Selamat tugas kamu sudah dinilai oleh ${_getGadikFullName(task.createdBy)} silahkan cek nilaimu segera',
          'dateTime': task.createdAt,
          'isRead': false,
          'type': 'task_dinilai',
          'person': _getGadikFullName(task.createdBy),
        });
        unread++;
      } else if (task.status == 'Remedial') {
        items.add({
          'id': 'task_${task.id}',
          'title': task.judul,
          'message':
              'Remedial untuk kamu, segera cek tugas aktif. Kumpulkan sebelum tenggat waktu (${_formatDateWithTime(task.deadline)})',
          'dateTime': task.createdAt,
          'isRead': false,
          'type': 'task_remedial',
          'person': _getGadikFullName(task.createdBy),
        });
        unread++;
      }
    }

    for (var item in KorsisInboxMockData.items) {
      if (item.status == 'disetujui') {
        items.add({
          'id': 'inbox_${item.id}',
          'title': item.rewardPunishmentName,
          'message': 'Diberikan oleh ${item.senderName}',
          'dateTime': item.timestamp,
          'isRead': false,
          'type': item.isReward ? 'reward' : 'punishment',
          'person': item.senderName,
        });
        unread++;
      }
    }

    if (SociometryPeriodConfig.isAwalActive()) {
      if (SociometryPeriodConfig.getFilledCount() < SociometryPeriodConfig.getTotalCount()) {
        final phaseStart = SociometryPeriodConfig.awalStartDate;
        items.add({
          'id': 'soc_awal',
          'title': 'Sosiometri Awal',
          'message': 'Penilaian terhadap sesama peleton sudah mulai, lihat pada beranda untuk mengisi kolom sosiometri.',
          'dateTime': phaseStart,
          'isRead': false,
          'type': 'sosiometri_start',
          'person': KorsisRealData.records.first['nama'],
        });
        unread++;
      } else {
        final fillDate = SociometryPeriodConfig.awalStartDate.add(const Duration(days: 1, hours: 14, minutes: 30));
        items.add({
          'id': 'soc_awal_done',
          'title': 'Sosiometri Selesai',
          'message': 'Selamat kamu telah mengisi sosiometri awal semuanya. Kamu merupakan orang yang paling rajin',
          'dateTime': fillDate,
          'isRead': false,
          'type': 'sosiometri_done',
          'person': KorsisRealData.records.first['nama'],
        });
        unread++;
      }
    } else if (SociometryPeriodConfig.isAkhirActive()) {
      if (SociometryPeriodConfig.getFilledCount() < SociometryPeriodConfig.getTotalCount()) {
        final phaseStart = SociometryPeriodConfig.akhirStartDate;
        items.add({
          'id': 'soc_akhir',
          'title': 'Sosiometri Akhir',
          'message': 'Penilaian terhadap sesama peleton akan berakhir 3 hari lagi, jangan lupa untuk menuntaskan pemberian nilai',
          'dateTime': phaseStart,
          'isRead': false,
          'type': 'sosiometri_reminder',
          'person': KorsisRealData.records.first['nama'],
        });
        unread++;
      } else {
        final fillDate = SociometryPeriodConfig.akhirStartDate.add(const Duration(days: 1, hours: 14, minutes: 30));
        items.add({
          'id': 'soc_akhir_done',
          'title': 'Sosiometri Selesai',
          'message': 'Selamat kamu telah mengisi sosiometri akhir semuanya. Kamu merupakan orang yang paling rajin',
          'dateTime': fillDate,
          'isRead': false,
          'type': 'sosiometri_done',
          'person': KorsisRealData.records.first['nama'],
        });
        unread++;
      }
    }

    final activeZones = AttendanceZones.activeZones;
    for (var zone in activeZones) {
      items.add({
        'id': 'zone_${zone.id}',
        'title': zone.name,
        'message':
            'Lokasi kegiatan telah dibuat oleh ${_getZoneCreatorFullName(zone.creator)}. Segera melakukan presensi.',
        'dateTime': zone.startTime,
        'isRead': false,
        'type': 'zone',
        'person': _getZoneCreatorFullName(zone.creator),
      });
      unread++;
    }

    items.sort(
      (a, b) =>
          (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime),
    );
    unreadCountNotifier.value = unread;
  }

  static void markAsRead(String id) {
    final index = items.indexWhere((i) => i['id'] == id);
    if (index != -1 && items[index]['isRead'] == false) {
      items[index]['isRead'] = true;
      unreadCountNotifier.value = (unreadCountNotifier.value - 1).clamp(0, 999);
    }
  }

  static void markAllAsRead() {
    for (var item in items) {
      item['isRead'] = true;
    }
    unreadCountNotifier.value = 0;
  }

  static String _formatDateWithTime(DateTime target) {
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
    final monthName = months[target.month - 1];
    final hr = target.hour.toString().padLeft(2, '0');
    final mn = target.minute.toString().padLeft(2, '0');
    return '${target.day.toString().padLeft(2, '0')} $monthName ${target.year}, $hr.$mn';
  }
}
