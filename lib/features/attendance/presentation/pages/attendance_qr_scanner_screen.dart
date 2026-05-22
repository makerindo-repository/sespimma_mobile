import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:flutter/services.dart';

class AttendanceQrScannerScreen extends StatefulWidget {
  const AttendanceQrScannerScreen({super.key});

  @override
  State<AttendanceQrScannerScreen> createState() =>
      _AttendanceQrScannerScreenState();
}

class _AttendanceQrScannerScreenState extends State<AttendanceQrScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanned = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _processQrCode(code);
                  break;
                }
              }
            },
          ),
          _buildOverlay(),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Pindai QR Presensi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDimensions.fontXxl,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.xxl * 2),
              ],
            ),
          ),

          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: const Text(
                  'Arahkan kamera tepat ke tengah kode QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontDefault,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.xBold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              children: [
                _buildCorner(0, 0, 0, 0),
                _buildCorner(null, 0, 0, null),
                _buildCorner(0, null, null, 0),
                _buildCorner(null, null, null, null),

                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: 260 * _animationController.value,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withValues(alpha: 0.0),
                              Colors.blueAccent,
                              Colors.blueAccent.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(
    double? top,
    double? right,
    double? bottom,
    double? left,
  ) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: top == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: left == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: right == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: bottom == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _processQrCode(String code) {
    setState(() => _isScanned = true);
    HapticFeedback.vibrate();

    try {
      final Map<String, dynamic> data = json.decode(code);

      if (data['type'] == 'attendance_sespimma' && data['zoneId'] != null) {
        Navigator.pop(context, data);
      } else {
        _showError('Format QR Code tidak valid untuk absensi SESPIMMA.');
      }
    } catch (e) {
      _showError('Gagal membaca data QR Code.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanned = false);
    });
  }
}
