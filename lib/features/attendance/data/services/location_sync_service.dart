import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

/// Arsitektur Sinkronisasi Lokasi Real-time ke Backend
/// Service ini bertugas membaca stream GPS dan mengirimkan koordinat ke server
/// dalam interval tertentu (throttling/debouncing) agar tidak membebani server
/// namun tetap realtime.
class LocationSyncService {
  static final LocationSyncService _instance = LocationSyncService._internal();
  factory LocationSyncService() => _instance;
  LocationSyncService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _syncTimer;

  Position? _lastPosition;
  bool _isSyncing = false;
  
  // Konfigurasi Interval Sinkronisasi ke Backend (Contoh: 10 detik)
  static const Duration syncInterval = Duration(seconds: 10);

  /// Memulai tracking dan sinkronisasi berkala
  void startSyncing(String serdikNrp) {
    if (_isSyncing) return;
    _isSyncing = true;

    // 1. Dengarkan pergerakan GPS secara Real-Time dengan akurasi tinggi
    // Hanya membaca update jika ada pergerakan lebih dari 2 meter.
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, 
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (position.latitude.isFinite && position.longitude.isFinite) {
          _lastPosition = position;
        }
      },
    );

    // 2. Jalankan background interval (Timer) untuk mengirim ke Backend secara efisien
    // Hal ini mencegah aplikasi melakukan 'spam' request ke backend setiap detik.
    _syncTimer = Timer.periodic(syncInterval, (timer) {
      if (_lastPosition != null) {
        _sendToBackendAPI(serdikNrp, _lastPosition!);
      }
    });
    
    developer.log('LocationSyncService STARTED for NRP: $serdikNrp', name: 'LocationSync');
  }

  /// Menghentikan tracking
  void stopSyncing() {
    _positionSubscription?.cancel();
    _syncTimer?.cancel();
    _isSyncing = false;
    developer.log('LocationSyncService STOPPED', name: 'LocationSync');
  }


  /// PONDASI INTEGRASI API BACKEND
  /// Method ini disiapkan untuk melakukan POST request ke server
  Future<void> _sendToBackendAPI(String nrp, Position pos) async {
    // Menyimpan ke database tiruan memori lokal (pengganti backend nyata)
    MockBackendDatabase.serdikLocations[nrp] = {
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'timestamp': DateTime.now(),
    };

    // TODO: Implementasi pemanggilan HTTP / WebSocket Server
    /*
    try {
      await dio.post('/api/v1/attendance/sync-location', data: {
        'nrp': nrp,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Gagal sync lokasi', error: e);
    }
    */
    
    // Bukti log di terminal IDE bahwa data dikirim setiap interval 10 detik!
    developer.log(
      'MENGIRIM LOKASI REALTIME KE BACKEND -> NRP: $nrp | Lat: ${pos.latitude}, Lng: ${pos.longitude}',
      name: 'LocationSyncAPI',
    );
  }
}

/// Database Tiruan Sementara untuk mensimulasikan Backend Server
class MockBackendDatabase {
  // Map <NRP, DataLokasi>
  static final Map<String, Map<String, dynamic>> serdikLocations = {};
}
