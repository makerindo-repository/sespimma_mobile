enum MapTileMode {
  normal,
  satellite,
  terrain;

  String get label {
    switch (this) {
      case MapTileMode.normal:
        return 'Normal';
      case MapTileMode.satellite:
        return 'Satelit';
      case MapTileMode.terrain:
        return 'Terrain';
    }
  }

  String get emoji {
    switch (this) {
      case MapTileMode.normal:
        return '🗺';
      case MapTileMode.satellite:
        return '🛰';
      case MapTileMode.terrain:
        return '🏔';
    }
  }

  String get tileUrl {
    switch (this) {
      case MapTileMode.normal:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapTileMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapTileMode.terrain:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  String get attribution {
    switch (this) {
      case MapTileMode.normal:
        return '© OpenStreetMap contributors';
      case MapTileMode.satellite:
        return '© Esri, Maxar, Earthstar Geographics';
      case MapTileMode.terrain:
        return '© OpenStreetMap contributors, SRTM | Map style: © OpenTopoMap';
    }
  }
}

class AttendanceZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String activityName;
  final String creator;
  final DateTime startTime;
  final DateTime endTime;

  const AttendanceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.activityName,
    required this.creator,
    required this.startTime,
    required this.endTime,
  });

  String get timeString {
    final startStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr WIB';
  }

  DateTime get deadline => endTime.subtract(const Duration(minutes: 30));

  DateTime get cutoffTime => endTime.subtract(const Duration(minutes: 15));
}

class AttendanceZones {
  AttendanceZones._();

  static bool isMakerindoEnabled = false;

  static List<AttendanceZone> get activeZones {
    final List<AttendanceZone> zones = [];

    if (isMakerindoEnabled) {
      zones.add(
        AttendanceZone(
          id: 'zone_apel_makerindo',
          name: 'PT. Makerindo Prima Solusi',
          latitude: -6.967639,
          longitude: 107.659083,
          radiusMeters: 50.0,
          activityName: 'Apel Pagi',
          creator: 'Korsis',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
        ),
      );
    }

    zones.addAll([
      AttendanceZone(
        id: 'zone_aula_widya',
        name: 'Gedung Rapat Widya Swara',
        latitude: -6.200500,
        longitude: 106.817500,
        radiusMeters: 45.0,
        activityName: 'Rapat Akademik Bulanan',
        creator: 'Korsis',
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      ),
      AttendanceZone(
        id: 'zone_aula_tribrata',
        name: 'Aula Tribrata Sespimma',
        latitude: -6.199500,
        longitude: 106.816000,
        radiusMeters: 60.0,
        activityName: 'Kuliah Umum Kebangsaan',
        creator: 'Binkar Sespimma',
        startTime: DateTime.now().subtract(const Duration(minutes: 50)),
        endTime: DateTime.now().add(const Duration(minutes: 10)),
      ),
      AttendanceZone(
        id: 'zone_masjid',
        name: 'Masjid Al-Ikhlas Sespimma',
        latitude: -6.201200,
        longitude: 106.816300,
        radiusMeters: 40.0,
        activityName: 'Kajian Siang Serdik',
        creator: 'Pokjar',
        startTime: DateTime.now().add(const Duration(minutes: 30)),
        endTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      ),
      AttendanceZone(
        id: 'zone_tembak',
        name: 'Lapangan Tembak Sespimma',
        latitude: -6.198500,
        longitude: 106.815500,
        radiusMeters: 70.0,
        activityName: 'Latihan Menembak Presisi',
        creator: 'Instruktur',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
      ),
    ]);

    return zones;
  }

  static AttendanceZone get apelHarian => activeZones.first;
}
