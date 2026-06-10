import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sespimma_mobile/injection_container.dart';

class LocationSyncService {
  static final LocationSyncService _instance = LocationSyncService._internal();
  factory LocationSyncService() => _instance;
  LocationSyncService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _syncTimer;

  Position? _lastPosition;
  bool _isSyncing = false;

  static const Duration syncInterval = Duration(seconds: 10);

  void startSyncing() {
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
          onError: (dynamic _) {},
          cancelOnError: false,
        );

    _syncTimer = Timer.periodic(syncInterval, (timer) {
      if (_lastPosition != null) {
        _sendToBackend(_lastPosition!);
      }
    });

    developer.log('LocationSyncService STARTED', name: 'LocationSync');
  }

  void stopSyncing() {
    _positionSubscription?.cancel();
    _syncTimer?.cancel();
    _isSyncing = false;
    developer.log('LocationSyncService STOPPED', name: 'LocationSync');
  }

  Future<void> _sendToBackend(Position pos) async {
    try {
      await sl<Dio>().put('/users/me/location', data: {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
      });
    } catch (_) {
      // best-effort — silently swallow to avoid UI noise
    }
  }
}
