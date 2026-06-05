import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

class LocationSyncService {
  static final LocationSyncService _instance = LocationSyncService._internal();
  factory LocationSyncService() => _instance;
  LocationSyncService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _syncTimer;

  Position? _lastPosition;
  bool _isSyncing = false;

  static const Duration syncInterval = Duration(seconds: 10);

  void startSyncing(String serdikNrp) {
    if (_isSyncing) return;
    _isSyncing = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (position.latitude.isFinite && position.longitude.isFinite) {
              _lastPosition = position;
            }
          },
        );

    _syncTimer = Timer.periodic(syncInterval, (timer) {
      if (_lastPosition != null) {
        _sendToBackendAPI(serdikNrp, _lastPosition!);
      }
    });

    developer.log(
      'LocationSyncService STARTED for NRP: $serdikNrp',
      name: 'LocationSync',
    );
  }

  void stopSyncing() {
    _positionSubscription?.cancel();
    _syncTimer?.cancel();
    _isSyncing = false;
    developer.log('LocationSyncService STOPPED', name: 'LocationSync');
  }

  Future<void> _sendToBackendAPI(String nrp, Position pos) async {
    MockBackendDatabase.serdikLocations[nrp] = {
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'timestamp': DateTime.now(),
    };

    developer.log(
      'MENGIRIM LOKASI REALTIME KE BACKEND -> NRP: $nrp | Lat: ${pos.latitude}, Lng: ${pos.longitude}',
      name: 'LocationSyncAPI',
    );
  }
}

class MockBackendDatabase {
  static final Map<String, Map<String, dynamic>> serdikLocations = {};
}
