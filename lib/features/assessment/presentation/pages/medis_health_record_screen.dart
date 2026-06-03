// lib/features/assessment/presentation/pages/medis_health_record_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/features/assessment/data/models/health_monitoring_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';

class MedisHealthRecordScreen extends StatefulWidget {
  final Map<String, dynamic> serdik;
  final VoidCallback onRecordAdded;

  const MedisHealthRecordScreen({
    super.key,
    required this.serdik,
    required this.onRecordAdded,
  });

  @override
  State<MedisHealthRecordScreen> createState() =>
      _MedisHealthRecordScreenState();
}

class _MedisHealthRecordScreenState extends State<MedisHealthRecordScreen> {
  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  String? _selectedType;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  String? _photoPath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  final List<String> _types = [
    'KUNJUNGAN POLIKLINIK',
    'RAWAT INAP TPS (Tempat Perawatan Sementara)',
    'RAWAT INAP RS (Rumah Sakit)',
  ];

  int _calculateMinusPoints(String type) {
    if (type.contains('POLIKLINIK')) {
      // Logic for Poliklinik is based on total visits, handled by the model or here.
      // But actually, we just need to know if THIS visit causes a deduction.
      final noSerdik = widget.serdik['no_serdik'].toString();
      final data = HealthMonitoringData.getHealthData(noSerdik);
      final totalPoli = data.records.where((r) => r.type.contains('POLIKLINIK')).length;
      final newTotal = totalPoli + 1;
      // 1-5x = -1, 6-10x = -2 (total). 
      // If newTotal is 1, 6, 11, etc. we deduct -1. Otherwise 0.
      if (newTotal % 5 == 1) {
        return 1;
      }
      return 0;
    } else {
      final days = int.tryParse(_daysController.text.trim()) ?? 1;
      if (type.contains('TPS')) {
        // 1-2 hari -> -1, 3-4 hari -> -2
        return (days / 2).ceil();
      } else if (type.contains('RS')) {
        // 1 hari -> -2, 2 hari -> -4
        return days * 2;
      }
    }
    return 0;
  }

  void _saveRecord(String medisName) {
    if (_selectedType == null || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis rawat dan isi keterangan medis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_selectedType!.contains('RAWAT INAP')) && _daysController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi durasi hari rawat inap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final noSerdik = widget.serdik['no_serdik'].toString();
    final minus = _calculateMinusPoints(_selectedType!);

    HealthMonitoringData.addHealthRecord(
      noSerdik,
      _selectedType!,
      _descController.text.trim(),
      medisName,
      minus,
      photoPath: _photoPath,
    );

    widget.onRecordAdded();
    setState(() {
      _selectedType = null;
      _descController.clear();
      _daysController.clear();
      _photoPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan kesehatan berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noSerdik = widget.serdik['no_serdik'].toString();
    final data = HealthMonitoringData.getHealthData(noSerdik);
    final name = widget.serdik['nama_lengkap'].toString();

    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Catat Rawat Inap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXl,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String medisName = 'Tenaga Medis';
          if (state is AuthSuccess) {
            medisName = state.user.name;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderInfo(name, noSerdik, data),
                const SizedBox(height: AppDimensions.xl),
                _buildForm(medisName),
                const SizedBox(height: AppDimensions.xxl),
                const Text(
                  'CATATAN STATUS KESEHATAN',
                  style: TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                _buildRecordList(data.records),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(String name, String noSerdik, SerdikHealthData data) {
    final score = data.currentNilaiC;
    Color statusColor = Colors.green;
    if (score < 70) {
      statusColor = Colors.red;
    } else if (score < 80) {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(widget.serdik),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NO SERDIK: $noSerdik',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSm,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'NILAI',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSm,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: AppDimensions.fontXxl,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> serdik) {
    final String? profilePhoto = serdik['profile_photo'] ?? serdik['profilePhoto'];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _lightGrey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 2),
        image: DecorationImage(
          image: (profilePhoto != null && profilePhoto.isNotEmpty)
              ? FileImage(File(profilePhoto)) as ImageProvider
              : const AssetImage('assets/images/default_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildForm(String medisName) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tambah Catatan Baru',
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: _lightGrey,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedType,
                isExpanded: true,
                hint: const Text('Pilih Jenis Perawatan'),
                items: _types.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedType = val;
                  });
                },
              ),
            ),
          ),
          if (_selectedType != null && _selectedType!.contains('RAWAT INAP')) ...[
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Durasi Hari',
                filled: true,
                fillColor: _lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ],
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Keterangan Medis',
              filled: true,
              fillColor: _lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              _photoPath != null ? Icons.check_circle : Icons.camera_alt,
              color: _photoPath != null ? Colors.green : _primaryNavy,
            ),
            label: Text(_photoPath != null ? 'Bukti Foto Terlampir' : 'Upload Bukti Foto'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: _photoPath != null ? Colors.green : _primaryNavy,
              side: BorderSide(color: _photoPath != null ? Colors.green : _primaryNavy),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
          if (_selectedType != null) ...[
            const SizedBox(height: AppDimensions.lg),
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Text(
                      'Potongan Nilai: -${_calculateMinusPoints(_selectedType!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                        fontSize: AppDimensions.fontMd,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.xl),
          ElevatedButton(
            onPressed: () => _saveRecord(medisName),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(List<HealthRecord> records) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: const Center(
          child: Text(
            'Belum ada catatan rawat inap',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
      itemBuilder: (context, index) {
        final record = records[index];
        final timeStr = DateFormat('dd MMM yyyy HH:mm').format(record.timestamp);

        return Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medical_services, color: Colors.red.shade400, size: 20),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.description,
                      style: TextStyle(color: Colors.blueGrey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$timeStr • ${record.medisName}',
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade300),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Text(
                '-${record.minusPoints}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: AppDimensions.fontLg,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
