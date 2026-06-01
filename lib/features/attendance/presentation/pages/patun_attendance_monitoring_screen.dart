import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/patun_geofence_map_widget.dart';
import 'package:sespimma_mobile/features/attendance/presentation/widgets/patun_zone_info_sheet.dart';

class PatunAttendanceMonitoringScreen extends StatefulWidget {
  const PatunAttendanceMonitoringScreen({super.key});

  @override
  State<PatunAttendanceMonitoringScreen> createState() =>
      _PatunAttendanceMonitoringScreenState();
}

class _PatunAttendanceMonitoringScreenState
    extends State<PatunAttendanceMonitoringScreen> {
  static const Color _primaryNavy = Color(0xFF000B1D);

  void _showInfoKegiatan(BuildContext context, String pokjar) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PatunZoneInfoSheet(pokjar: pokjar),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userPokjar = '';
        if (state is AuthSuccess) {
          userPokjar = state.user.pokjar;
        }

        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: _primaryNavy,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Monitoring Absen',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.fontXxl,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
                tooltip: 'Info Kegiatan',
                onPressed: () => _showInfoKegiatan(context, userPokjar),
              ),
            ],
          ),
          body: PatunGeofenceMapWidget(pokjar: userPokjar),
        );
      },
    );
  }
}
