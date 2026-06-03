import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';

class PatunKakorsisOutboxScreen extends StatefulWidget {
  const PatunKakorsisOutboxScreen({super.key});

  @override
  State<PatunKakorsisOutboxScreen> createState() =>
      _PatunKakorsisOutboxScreenState();
}

class _PatunKakorsisOutboxScreenState extends State<PatunKakorsisOutboxScreen> {
  static const Color _primaryNavy = Color(0xFF000B1D);
  static const Color _lightGrey = Color(0xFFF8F9FA);

  final List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _drafts.addAll([
      {
        'id': '1',
        ...SerdikRealData.records[0],
        'jenis': 'Pelanggaran',
        'indikator': RewardPunishmentData.punishments[3].description,
        'point': RewardPunishmentData.punishments[3].point,
        'waktu': 'Hari ini, 07:15',
      },
      {
        'id': '2',
        ...SerdikRealData.records[1],
        'jenis': 'Prestasi',
        'indikator': RewardPunishmentData.rewards[0].description,
        'point': RewardPunishmentData.rewards[0].point,
        'waktu': 'Kemarin, 18:30',
      },
      {
        'id': '3',
        ...SerdikRealData.records[2],
        'jenis': 'Pelanggaran',
        'indikator': RewardPunishmentData.punishments[4].description,
        'point': RewardPunishmentData.punishments[4].point,
        'waktu': 'Kemarin, 13:45',
      },
    ]);
  }

  void _confirmSubmitAll() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          title: Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kirim ke Kakorsis?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Catatan yang sudah dikirim ke Kakorsis tidak dapat diubah atau dihapus lagi secara manual. Anda yakin ingin melanjutkan?',
            style: TextStyle(
              fontSize: AppDimensions.fontMd,
              color: Colors.blueGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Kirim Semua',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processSubmit() {
    setState(() {
      _drafts.clear();
    });

    AppNotifier.showSuccess(
      context,
      'Semua draft berhasil dikirim ke Kakorsis!',
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _deleteDraft(String id) {
    setState(() {
      _drafts.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey,
      appBar: AppBar(
        backgroundColor: _primaryNavy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Draft Penilaian',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _drafts.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    itemCount: _drafts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _drafts[index];
                      return _buildDraftItem(item);
                    },
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drafts_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Draft Kosong',
            style: TextStyle(
              fontSize: AppDimensions.fontXl,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada draft penilaian baru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftItem(Map<String, dynamic> item) {
    final bool isReward = item['point'] > 0;
    final color = isReward ? Colors.green.shade600 : Colors.red.shade600;

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteDraft(item['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      image: DecorationImage(
                        image:
                            (item['profile_photo'] != null &&
                                item['profile_photo'].toString().isNotEmpty)
                            ? FileImage(File(item['profile_photo']))
                                  as ImageProvider
                            : const AssetImage(
                                'assets/images/default_avatar.png',
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_lengkap'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _primaryNavy,
                                      fontSize: AppDimensions.fontMd,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item['pangkat'] ?? '-'} · ${item['no_serdik'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: AppDimensions.fontSm,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                              child: Text(
                                '${isReward ? "+" : ""}${item['point']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['indikator'] ?? '-',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMd,
                            color: Colors.blueGrey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['waktu'] ?? '-',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSm,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _drafts.isEmpty ? null : _confirmSubmitAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryNavy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              elevation: 0,
            ),
            child: const Text(
              'KIRIM',
              style: TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
