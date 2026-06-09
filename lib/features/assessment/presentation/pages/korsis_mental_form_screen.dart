import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import 'package:sespimma_mobile/core/utils/app_notifier.dart';
import 'package:sespimma_mobile/features/assessment/utils/reward_punishment_eligibility.dart';
import 'package:sespimma_mobile/features/assessment/data/models/korsis_inbox_mock_data.dart';
import 'package:sespimma_mobile/features/leadership_report/domain/services/score_calculator_service.dart';
import 'package:sespimma_mobile/features/leadership_report/data/models/final_recap_model.dart';
import 'package:sespimma_mobile/core/utils/avatar_helper.dart';

// ---------------------------------------------------------------------------
// File-level constants shared across private widgets in this file
// ---------------------------------------------------------------------------
const Color _kPrimaryNavy = Color(0xFF000B1D);
const Color _kLightGrey = Color(0xFFF8F9FA);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class KorsisMentalFormScreen extends StatefulWidget {
  final bool isReward;

  const KorsisMentalFormScreen({super.key, required this.isReward});

  @override
  State<KorsisMentalFormScreen> createState() => _KorsisMentalFormScreenState();
}

class _KorsisMentalFormScreenState extends State<KorsisMentalFormScreen> {
  Map<String, dynamic>? _selectedSerdik;
  RewardPunishmentItem? _selectedCategory;
  File? _selectedPhoto;
  final TextEditingController _justificationController =
      TextEditingController();

  final List<Map<String, dynamic>> _serdikList = SerdikRealData.records;

  final List<String> _pokjarOptions = const [
    'Semua',
    'POKJAR I',
    'POKJAR II',
    'POKJAR III',
    'POKJAR IV',
    'POKJAR V',
  ];

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Score computation
  // -------------------------------------------------------------------------

  List<RewardPunishmentItem> get _currentOptions => widget.isReward
      ? RewardPunishmentData.rewards
      : RewardPunishmentData.punishments;

  double get _calculatedFinalScore {
    final base = _currentBaseScore;
    if (_selectedCategory == null) return base;
    return base + _selectedCategory!.point;
  }

  double get _currentBaseScore {
    if (_selectedSerdik == null) return 80.0;
    if (_selectedSerdik!.containsKey('_mock_score')) {
      return (_selectedSerdik!['_mock_score'] as num).toDouble();
    }
    final targetNrp = _selectedSerdik!['nrp'] ?? '';
    final report = ScoreCalculatorService.generateRealReports().firstWhere(
      (r) => r.nrp == targetNrp,
      orElse: () => FinalRecapModel.empty(),
    );
    return report.mentalScore > 0 ? report.mentalScore : 80.0;
  }

  Color _getScoreColor(double s) {
    if (s == 0) return Colors.blueGrey.shade800;
    if (s > 85.00) return Colors.green.shade800;
    if (s > 80.00) return Colors.green.shade500;
    if (s > 75.00) return Colors.lime.shade700;
    if (s > 70.00) return Colors.amber.shade500;
    return Colors.red.shade700;
  }

  // -------------------------------------------------------------------------
  // Photo actions
  // -------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _selectedPhoto = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removePhoto() {
    Navigator.pop(context);
    setState(() => _selectedPhoto = null);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.xs / 2),
                  ),
                ),
                const Text(
                  'Unggah Bukti Foto',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXxl,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryNavy,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),
                _BottomSheetTile(
                  icon: AppIcons.camera,
                  title: 'Ambil dari Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedPhoto != null)
                  _BottomSheetTile(
                    icon: AppIcons.trash,
                    title: 'Hapus Foto',
                    color: Colors.red.shade600,
                    onTap: _removePhoto,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Lookup sheets
  // -------------------------------------------------------------------------

  void _showSerdikLookup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SerdikLookupSheet(
        serdikList: _serdikList,
        pokjarOptions: _pokjarOptions,
        onSelected: (serdik) => setState(() => _selectedSerdik = serdik),
      ),
    );
  }

  void _showIndicatorLookup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IndicatorLookupSheet(
        options: _currentOptions,
        isReward: widget.isReward,
        selectedSerdikId: _selectedSerdik?['no_serdik']?.toString(),
        onSelected: (opt) => setState(() => _selectedCategory = opt),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Section-level build helpers
  // -------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w800,
          color: _kPrimaryNavy,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSerdikSelectionCard(Color pointColor) {
    final bool isSelected = _selectedSerdik != null;

    return InkWell(
      onTap: _showSerdikLookup,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected
                ? _kPrimaryNavy.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            if (isSelected)
              _SerdikAvatar(photoPath: _selectedSerdik!['profile_photo'])
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.user,
                  color: Colors.grey.shade400,
                  size: AppDimensions.iconLg,
                ),
              ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSelected
                        ? _selectedSerdik!['nama_lengkap']
                        : 'Pilih Target Serdik',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? _kPrimaryNavy
                          : Colors.blueGrey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected
                        ? '${_selectedSerdik!['pangkat']} • No. ${_selectedSerdik!['no_serdik']}'
                        : 'Tekan untuk mencari Serdik',
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.blueGrey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.caretDown,
              color: Colors.grey.shade400,
              size: AppDimensions.iconLg,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorSelectionCard(Color pointColor) {
    final bool isSelected = _selectedCategory != null;

    return InkWell(
      onTap: _showIndicatorLookup,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected
                ? _kPrimaryNavy.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? pointColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isReward ? Icons.stars_rounded : Icons.warning_rounded,
                color: isSelected ? pointColor : Colors.grey.shade400,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSelected
                        ? _selectedCategory!.description
                        : 'Pilih Indikator',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLg,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? _kPrimaryNavy
                          : Colors.blueGrey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (isSelected && _selectedCategory!.note != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        _selectedCategory!.note!,
                        style: TextStyle(
                          fontSize: AppDimensions.fontXs,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        _selectedCategory!.aspect.toUpperCase(),
                        style: TextStyle(
                          fontSize: AppDimensions.fontXs,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.isReward
                          ? 'Pilih jenis indikator prestasi'
                          : 'Pilih jenis indikator pelanggaran',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(left: AppDimensions.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pointColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Text(
                  '${_selectedCategory!.point > 0 ? "+" : ""}${_selectedCategory!.point}',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w900,
                    color: pointColor,
                  ),
                ),
              )
            else
              Icon(
                AppIcons.caretDown,
                color: Colors.grey.shade400,
                size: AppDimensions.iconLg,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploader() {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: _selectedPhoto != null
                ? _kPrimaryNavy.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: _selectedPhoto != null ? 2 : 1,
          ),
          image: _selectedPhoto != null
              ? DecorationImage(
                  image: FileImage(_selectedPhoto!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: _selectedPhoto != null
                      ? _kPrimaryNavy.withValues(alpha: 0.2)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedPhoto != null
                      ? Icons.check_circle_rounded
                      : AppIcons.cameraFill,
                  size: AppDimensions.iconXxl,
                  color: _selectedPhoto != null
                      ? Colors.white
                      : Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                _selectedPhoto != null
                    ? 'Ketuk untuk ubah foto'
                    : 'Ambil dari Kamera',
                style: TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w700,
                  color: _selectedPhoto != null
                      ? Colors.white
                      : Colors.blueGrey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJustificationField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _justificationController,
        maxLines: 4,
        minLines: 3,
        style: const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
          color: _kPrimaryNavy,
        ),
        decoration: InputDecoration(
          hintText: 'Masukkan keterangan justifikasi...',
          hintStyle: TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.lg),
        ),
      ),
    );
  }

  Widget _buildPreviewSection(Color pointColor) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kPrimaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: _kPrimaryNavy,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              const Text(
                'PREVIEW NILAI AKHIR',
                style: TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w800,
                  color: _kPrimaryNavy,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: _kLightGrey,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: _selectedSerdik == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.lg),
                    child: Center(
                      child: Text(
                        'Pilih target serdik terlebih dahulu',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nilai Saat Ini',
                            style: TextStyle(
                              fontSize: AppDimensions.fontMd,
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getScoreColor(_currentBaseScore)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm),
                            ),
                            child: Text(
                              _currentBaseScore.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: AppDimensions.fontLg,
                                color: _getScoreColor(_currentBaseScore),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.isReward
                                  ? 'Penambahan Poin'
                                  : 'Pengurangan Poin',
                              style: TextStyle(
                                fontSize: AppDimensions.fontMd,
                                color: Colors.blueGrey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: pointColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_selectedCategory!.point > 0 ? "+" : ""}${_selectedCategory!.point}',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontMd,
                                  color: pointColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
          if (_selectedSerdik != null) ...[
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimasi Nilai Baru',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLg,
                    color: _kPrimaryNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(_calculatedFinalScore)
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    _calculatedFinalScore.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: AppDimensions.fontXxl,
                      color: _getScoreColor(_calculatedFinalScore),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.isReward ? 'Input Reward' : 'Input Punishment';
    final Color pointColor =
        widget.isReward ? Colors.green.shade600 : Colors.red.shade600;

    return Scaffold(
      backgroundColor: _kLightGrey,
      appBar: AppBar(
        backgroundColor: _kPrimaryNavy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.fontXxl,
            letterSpacing: 0.5,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Target Serdik'),
            _buildSerdikSelectionCard(pointColor),
            const SizedBox(height: AppDimensions.xl),

            _buildSectionTitle(
              widget.isReward
                  ? 'Indikator Prestasi'
                  : 'Indikator Pelanggaran',
            ),
            _buildIndicatorSelectionCard(pointColor),
            const SizedBox(height: AppDimensions.xl),

            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bukti Foto',
                    style: TextStyle(
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.w800,
                      color: _kPrimaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '(Wajib)',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: AppDimensions.fontSm,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _buildPhotoUploader(),
            const SizedBox(height: AppDimensions.xxl),

            _buildSectionTitle('Keterangan Justifikasi'),
            _buildJustificationField(),
            const SizedBox(height: AppDimensions.xxl),

            _buildPreviewSection(pointColor),
            const SizedBox(height: AppDimensions.xxl),

            ElevatedButton(
              onPressed: (_selectedSerdik != null &&
                      _selectedCategory != null &&
                      _selectedPhoto != null)
                  ? () {
                      HapticFeedback.heavyImpact();
                      final newItem = InboxItem(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        serdikName: _selectedSerdik!['nama_lengkap'],
                        pangkat: _selectedSerdik!['pangkat'],
                        nosis: _selectedSerdik!['no_serdik'],
                        pokjar: _selectedSerdik!['kelompok_kelas'],
                        isReward: widget.isReward,
                        senderName: 'Kombes Pol. Ahmad Setiawan',
                        timestamp: DateTime.now(),
                        points: _selectedCategory!.point,
                        description:
                            _justificationController.text.isNotEmpty
                                ? _justificationController.text
                                : 'Telah dilakukan observasi dan pencatatan oleh Korsis.',
                        rewardPunishmentName:
                            _selectedCategory!.description,
                        status: 'disetujui',
                        photoPath: _selectedPhoto?.path,
                        rewardPunishmentId: _selectedCategory!.id,
                      );
                      KorsisInboxMockData.addRecord(newItem);
                      Navigator.pop(context);
                      AppNotifier.showSuccess(
                        context,
                        'Catatan berhasil ditambahkan ke sistem!',
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: pointColor,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SIMPAN KE SISTEM',
                style: TextStyle(
                  fontSize: AppDimensions.fontLg,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SerdikLookupSheet
// Bottom sheet for searching and selecting a serdik. Owns its own search
// query and POKJAR filter state so the parent form state stays clean.
// ---------------------------------------------------------------------------

class _SerdikLookupSheet extends StatefulWidget {
  final List<Map<String, dynamic>> serdikList;
  final List<String> pokjarOptions;
  final ValueChanged<Map<String, dynamic>> onSelected;

  const _SerdikLookupSheet({
    required this.serdikList,
    required this.pokjarOptions,
    required this.onSelected,
  });

  @override
  State<_SerdikLookupSheet> createState() => _SerdikLookupSheetState();
}

class _SerdikLookupSheetState extends State<_SerdikLookupSheet> {
  String _searchQuery = '';
  String _selectedFilterPokjar = 'Semua';

  static String _mapRomanToArabic(String roman) {
    switch (roman) {
      case 'POKJAR I':   return 'POKJAR 1';
      case 'POKJAR II':  return 'POKJAR 2';
      case 'POKJAR III': return 'POKJAR 3';
      case 'POKJAR IV':  return 'POKJAR 4';
      case 'POKJAR V':   return 'POKJAR 5';
      default:           return roman;
    }
  }

  static String _mapArabicToRoman(String arabic) {
    switch (arabic) {
      case 'POKJAR 1': return 'POKJAR I';
      case 'POKJAR 2': return 'POKJAR II';
      case 'POKJAR 3': return 'POKJAR III';
      case 'POKJAR 4': return 'POKJAR IV';
      case 'POKJAR 5': return 'POKJAR V';
      default:         return arabic;
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final query = _searchQuery.toLowerCase();
    return widget.serdikList.where((serdik) {
      final name = (serdik['nama_lengkap'] ?? '').toString().toLowerCase();
      final noSerdik = (serdik['no_serdik'] ?? '').toString().toLowerCase();
      final pokjar = (serdik['kelompok_kelas'] ?? '').toString();
      final matchQuery = name.contains(query) || noSerdik.contains(query);
      final matchPokjar = _selectedFilterPokjar == 'Semua' ||
          pokjar == _mapRomanToArabic(_selectedFilterPokjar);
      return matchQuery && matchPokjar;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BottomSheetHeader(
            title: 'Cari Serdik',
            onClose: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau nomor serdik...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: _kLightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Container(
                  decoration: BoxDecoration(
                    color: _selectedFilterPokjar == 'Semua'
                        ? _kLightGrey
                        : _kPrimaryNavy.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: _selectedFilterPokjar == 'Semua'
                          ? Colors.grey.shade600
                          : _kPrimaryNavy,
                    ),
                    onSelected: (val) =>
                        setState(() => _selectedFilterPokjar = val),
                    itemBuilder: (context) =>
                        widget.pokjarOptions.map((opt) {
                      return PopupMenuItem<String>(
                        value: opt,
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontWeight: _selectedFilterPokjar == opt
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: _selectedFilterPokjar == opt
                                ? _kPrimaryNavy
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final serdik = filtered[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xl,
                      vertical: 4,
                    ),
                    leading:
                        _SerdikAvatar(photoPath: serdik['profile_photo']),
                    title: Text(
                      serdik['nama_lengkap'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kPrimaryNavy,
                      ),
                    ),
                    subtitle: Text(
                      '${serdik['pangkat']} • ${serdik['no_serdik']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      child: Text(
                        _mapArabicToRoman(
                          serdik['kelompok_kelas']?.toString() ?? '-',
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onSelected(serdik);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _IndicatorLookupSheet
// Bottom sheet for searching and selecting a reward/punishment indicator.
// Owns its own search query state.
// ---------------------------------------------------------------------------

class _IndicatorLookupSheet extends StatefulWidget {
  final List<RewardPunishmentItem> options;
  final bool isReward;
  final String? selectedSerdikId;
  final ValueChanged<RewardPunishmentItem> onSelected;

  const _IndicatorLookupSheet({
    required this.options,
    required this.isReward,
    required this.selectedSerdikId,
    required this.onSelected,
  });

  @override
  State<_IndicatorLookupSheet> createState() =>
      _IndicatorLookupSheetState();
}

class _IndicatorLookupSheetState extends State<_IndicatorLookupSheet> {
  String _searchQuery = '';

  List<RewardPunishmentItem> get _filtered {
    final query = _searchQuery.toLowerCase();
    return widget.options.where((opt) {
      return opt.description.toLowerCase().contains(query) ||
          opt.aspect.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pointColor =
        widget.isReward ? Colors.green.shade600 : Colors.red.shade600;
    final filtered = _filtered;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: _kLightGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BottomSheetHeader(
            title: widget.isReward
                ? 'Indikator Prestasi'
                : 'Indikator Pelanggaran',
            onClose: () => Navigator.pop(context),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: widget.isReward
                    ? 'Cari indikator prestasi...'
                    : 'Cari indikator pelanggaran...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: _kLightGrey,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.lg),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.md),
              itemBuilder: (context, index) {
                final opt = filtered[index];
                EligibilityStatus eligibility = EligibilityStatus(true);
                if (widget.selectedSerdikId != null) {
                  eligibility =
                      RewardPunishmentEligibility.checkEligibility(
                    widget.selectedSerdikId!,
                    opt,
                  );
                }
                final bool isGreyedOut = !eligibility.isEligible;
                final Color effectiveColor =
                    isGreyedOut ? Colors.grey.shade400 : pointColor;

                return InkWell(
                  onTap: () {
                    if (widget.selectedSerdikId == null) {
                      AppNotifier.showError(
                        context,
                        'Silakan pilih serdik terlebih dahulu',
                      );
                      return;
                    }
                    if (isGreyedOut) {
                      AppNotifier.showError(
                        context,
                        eligibility.message ??
                            'Item ini sudah mencapai batas maksimum',
                      );
                      return;
                    }
                    widget.onSelected(opt);
                    Navigator.pop(context);
                  },
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    decoration: BoxDecoration(
                      color: isGreyedOut
                          ? Colors.grey.shade50
                          : Colors.white,
                      border:
                          Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: 0.01),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: effectiveColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isReward
                                ? Icons.stars_rounded
                                : Icons.warning_rounded,
                            color: effectiveColor,
                            size: AppDimensions.iconLg,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      opt.description,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize:
                                            AppDimensions.fontMd,
                                        color: isGreyedOut
                                            ? Colors.grey.shade500
                                            : _kPrimaryNavy,
                                        decoration: isGreyedOut
                                            ? TextDecoration
                                                .lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 8),
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4),
                                    decoration: BoxDecoration(
                                      color: pointColor
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                        AppDimensions.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      '${opt.point > 0 ? "+" : ""}${opt.point}',
                                      style: TextStyle(
                                        fontSize:
                                            AppDimensions.fontLg,
                                        fontWeight: FontWeight.w900,
                                        color: effectiveColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius:
                                          BorderRadius.circular(
                                        AppDimensions.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      opt.aspect.toUpperCase(),
                                      style: TextStyle(
                                        fontSize:
                                            AppDimensions.fontXs,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            Colors.blueGrey.shade600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  if (opt.note != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius:
                                            BorderRadius.circular(
                                          AppDimensions.radiusSm,
                                        ),
                                      ),
                                      child: Text(
                                        opt.note!,
                                        style: TextStyle(
                                          fontSize:
                                              AppDimensions.fontXs,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared private widgets
// ---------------------------------------------------------------------------

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _BottomSheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xl,
        vertical: AppDimensions.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppDimensions.fontXl,
              fontWeight: FontWeight.w800,
              color: _kPrimaryNavy,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onClose,
            color: Colors.grey.shade600,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _kPrimaryNavy;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: effectiveColor, size: AppDimensions.iconLg),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: effectiveColor,
            fontSize: AppDimensions.fontLg + 1,
          ),
        ),
        trailing: Icon(AppIcons.caretRight, color: Colors.grey.shade400),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }
}

class _SerdikAvatar extends StatelessWidget {
  final String? photoPath;

  const _SerdikAvatar({this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
        image: DecorationImage(
          image: AvatarHelper.getAvatar(photoPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
