import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

import '../../domain/models/map_tile_mode.dart';

const bool showAuditDebug = false;
const bool showGeofenceCircles = true;

class GeofenceMapWidget extends StatefulWidget {
  final List<AttendanceZone> zones;
  final Function(
    AttendanceZone? activeZone,
    double distanceMeters,
    bool isFakeGps,
  )
  onLocationDetected;
  final Function(String message, bool isPermissionError)? onGpsError;
  final VoidCallback? onReload;
  final Function(AttendanceZone tappedZone)? onRadiusTap;

  const GeofenceMapWidget({
    super.key,
    required this.zones,
    required this.onLocationDetected,
    this.onGpsError,
    this.onReload,
    this.onRadiusTap,
  });

  @override
  State<GeofenceMapWidget> createState() => _GeofenceMapWidgetState();
}

class _GeofenceMapWidgetState extends State<GeofenceMapWidget>
    with TickerProviderStateMixin {
  bool _isInRadius = false;
  bool _isLoading = true;
  bool _isRefreshingMap = false;
  LatLng? _userLatLng;

  MapTileMode _tileMode = MapTileMode.normal;

  StreamSubscription<Position>? _positionStreamSubscription;
  late final MapController _mapController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const double _defaultZoom = 19.0;

  LatLng get _firstZoneLatLng {
    if (widget.zones.isEmpty) return const LatLng(-6.200000, 106.816666);
    return LatLng(widget.zones.first.latitude, widget.zones.first.longitude);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setupPulseAnimation();
    _checkPermissionsAndStartTracking();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndStartTracking() async {
    if (!mounted) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLoadingState(false);
      widget.onGpsError?.call(
        'Layanan GPS mati. Harap aktifkan lokasi di pengaturan HP.',
        false,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLoadingState(false);
        widget.onGpsError?.call('Izin akses lokasi ditolak.', true);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setLoadingState(false);
      widget.onGpsError?.call(
        'Izin lokasi ditolak permanen. Silakan aktifkan melalui Pengaturan HP.',
        true,
      );
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position pos) {
            if (pos.isMocked) {
              if (mounted) {
                setState(() {
                  _isInRadius = false;
                  _isLoading = false;
                });
                widget.onLocationDetected(null, -1.0, true);
              }
              return;
            }
            _updateFromPosition(pos.latitude, pos.longitude, false);
          },
        );

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        if (current.isMocked) {
          setState(() {
            _isInRadius = false;
            _isLoading = false;
          });
          widget.onLocationDetected(null, -1.0, true);
        } else {
          _updateFromPosition(current.latitude, current.longitude, false);
          _animateTo(LatLng(current.latitude, current.longitude));
        }
      }
    } catch (_) {
      _setLoadingState(false);
      widget.onGpsError?.call('Gagal mendapatkan posisi GPS.', false);
    }
  }

  void _updateFromPosition(
    double lat,
    double lng,
    bool isFakeGps, {
    List<AttendanceZone>? overrideZones,
  }) {
    final zonesToUse = overrideZones ?? widget.zones;

    if (zonesToUse.isEmpty) {
      if (mounted) {
        setState(() {
          _userLatLng = LatLng(lat, lng);
          _isInRadius = false;
          _isLoading = false;
        });
        widget.onLocationDetected(null, -1.0, isFakeGps);
      }
      return;
    }

    AttendanceZone? matchedZone;
    double finalDistance = -1.0;

    for (final zone in zonesToUse) {
      final distance = Geolocator.distanceBetween(
        zone.latitude,
        zone.longitude,
        lat,
        lng,
      );
      if (distance <= zone.radiusMeters) {
        matchedZone = zone;
        finalDistance = distance;
        break;
      }
    }

    if (matchedZone == null && zonesToUse.isNotEmpty) {
      finalDistance = Geolocator.distanceBetween(
        zonesToUse.first.latitude,
        zonesToUse.first.longitude,
        lat,
        lng,
      );
    }

    bool inRadius = matchedZone != null;

    if (mounted) {
      setState(() {
        _userLatLng = LatLng(lat, lng);
        _isInRadius = inRadius;
        _isLoading = false;
      });
      widget.onLocationDetected(matchedZone, finalDistance, isFakeGps);
    }
  }

  void _setLoadingState(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _animateTo(LatLng target) {
    _mapController.move(target, _defaultZoom);
  }

  void _centerOnUser() {
    if (_userLatLng != null) {
      _animateTo(_userLatLng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMap(),
        _buildReloadFab(),
        _buildLayerFab(),
        _buildCenterFab(),
        if (_isLoading) _buildLoadingOverlay(),
        _buildAuditDebugPanel(),
      ],
    );
  }

  Widget _buildAuditDebugPanel() {
    if (!showAuditDebug || _userLatLng == null) return const SizedBox.shrink();

    double minDistance = double.infinity;
    AttendanceZone? nearest;

    for (final zone in widget.zones) {
      final d = Geolocator.distanceBetween(
        zone.latitude,
        zone.longitude,
        _userLatLng!.latitude,
        _userLatLng!.longitude,
      );
      if (d < minDistance) {
        minDistance = d;
        nearest = zone;
      }
    }

    return Positioned(
      top: 80,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm + 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🛰️ AUDIT LOCATION DEBUG',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppDimensions.fontSm,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24, height: 8),
            Text(
              'User: ${_userLatLng!.latitude.toStringAsFixed(6)}, ${_userLatLng!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: AppDimensions.fontSm,
                fontFamily: 'monospace',
              ),
            ),
            if (nearest != null) ...[
              Text(
                'Zone: ${nearest.name}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: AppDimensions.fontSm,
                ),
              ),
              Text(
                'Dist: ${minDistance.toStringAsFixed(2)}m / Radius: ${nearest.radiusMeters}m',
                style: TextStyle(
                  color: minDistance <= nearest.radiusMeters
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: AppDimensions.fontSm + 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _firstZoneLatLng,
        initialZoom: _defaultZoom,
        minZoom: 10,
        maxZoom: 22,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          for (final zone in widget.zones) {
            final distance = Geolocator.distanceBetween(
              zone.latitude,
              zone.longitude,
              point.latitude,
              point.longitude,
            );
            if (distance <= zone.radiusMeters) {
              HapticFeedback.selectionClick();
              widget.onRadiusTap?.call(zone);
              break;
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: _tileMode.tileUrl,
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.sespimma.mobile',
          maxZoom: 22,
          maxNativeZoom: 19,
        ),
        if (showGeofenceCircles)
          CircleLayer(
            circles: widget.zones.map((zone) {
              bool isUserInsideThisZone = false;
              if (_userLatLng != null) {
                final distance = Geolocator.distanceBetween(
                  zone.latitude,
                  zone.longitude,
                  _userLatLng!.latitude,
                  _userLatLng!.longitude,
                );
                isUserInsideThisZone = distance <= zone.radiusMeters;
              }

              final Color ringColor = isUserInsideThisZone
                  ? _successGreen
                  : _dangerRed;

              return CircleMarker(
                point: LatLng(zone.latitude, zone.longitude),
                radius: zone.radiusMeters,
                useRadiusInMeter: true,
                color: ringColor.withValues(alpha: 0.15),
                borderColor: ringColor,
                borderStrokeWidth: 2.0,
              );
            }).toList(),
          ),
        MarkerLayer(
          markers: [
            ...widget.zones.map(
              (zone) => Marker(
                point: LatLng(zone.latitude, zone.longitude),
                width: 44,
                height: 44,
                child: _buildZoneMarker(),
              ),
            ),
            if (_userLatLng != null)
              Marker(
                point: _userLatLng!,
                width: 60,
                height: 60,
                child: _buildUserMarker(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneMarker() {
    return const Tooltip(
      message: 'Zona Apel',
      child: Icon(
        AppIcons.buildingsFill,
        color: Color(0xFF001C40),
        size: AppDimensions.iconXxl,
        shadows: [Shadow(color: Colors.white, blurRadius: 6)],
      ),
    );
  }

  Widget _buildUserMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1.0 + (_pulseAnimation.value * 0.8),
              child: Opacity(
                opacity: (1.0 - _pulseAnimation.value).clamp(0.0, 1.0),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_isInRadius ? _successGreen : _dangerRed)
                        .withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isInRadius ? _successGreen : _dangerRed,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: (_isInRadius ? _successGreen : _dangerRed)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReloadFab() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25 + 120,
      right: 16,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
          onTap: _isRefreshingMap
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  setState(() => _isRefreshingMap = true);
                  await Future.delayed(const Duration(milliseconds: 1200));
                  if (mounted) {
                    setState(() => _isRefreshingMap = false);
                    widget.onReload?.call();
                    final latestZones = AttendanceZones.activeZones;
                    if (_userLatLng != null) {
                      _updateFromPosition(
                        _userLatLng!.latitude,
                        _userLatLng!.longitude,
                        false,
                        overrideZones: latestZones,
                      );
                    }

                    if (latestZones.isNotEmpty) {
                      final firstZone = LatLng(
                        latestZones.first.latitude,
                        latestZones.first.longitude,
                      );
                      _animateTo(firstZone);
                    }
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.sm + 2),
            child: _isRefreshingMap
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _primaryNavy,
                    ),
                  )
                : const Icon(
                    AppIcons.arrowsClockwiseBold,
                    color: _primaryNavy,
                    size: AppDimensions.iconDefault + 2,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerFab() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25 + 60,
      right: 16,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
          onTap: () {
            HapticFeedback.lightImpact();
            _showLayerBottomSheet();
          },
          child: const Padding(
            padding: EdgeInsets.all(AppDimensions.sm + 2),
            child: Icon(
              AppIcons.stackBold,
              color: Color(0xFF001C40),
              size: AppDimensions.iconDefault + 2,
            ),
          ),
        ),
      ),
    );
  }

  void _showLayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              const Text(
                'Jenis Peta',
                style: TextStyle(
                  fontSize: AppDimensions.fontXl + 1,
                  fontWeight: FontWeight.w800,
                  color: _primaryNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildLayerOption(
                      ctx,
                      'Normal',
                      MapTileMode.normal,
                      'assets/images/map_normal.png',
                      AppIcons.mapTrifoldFill,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _buildLayerOption(
                      ctx,
                      'Satelit',
                      MapTileMode.satellite,
                      'assets/images/map_satellite.png',
                      AppIcons.globeHemisphereWestFill,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerOption(
    BuildContext ctx,
    String title,
    MapTileMode mode,
    String imageFallback,
    IconData fallbackIcon,
  ) {
    final isActive = _tileMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tileMode = mode);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? _primaryNavy.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isActive ? _primaryNavy : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              fallbackIcon,
              size: 36,
              color: isActive ? _primaryNavy : Colors.blueGrey,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.fontDefault,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? _primaryNavy : Colors.blueGrey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.25,
      right: 16,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg + 2),
          onTap: () {
            HapticFeedback.lightImpact();
            _centerOnUser();
          },
          child: const Padding(
            padding: EdgeInsets.all(AppDimensions.sm + 2),
            child: Icon(
              AppIcons.crosshairBold,
              color: Color(0xFF001C40),
              size: AppDimensions.iconDefault + 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: AppDimensions.md),
            Text(
              'Mendeteksi lokasi GPS...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
