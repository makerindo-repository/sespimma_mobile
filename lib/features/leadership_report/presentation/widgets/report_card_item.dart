import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import '../../data/models/final_recap_model.dart';

class ReportCardItem extends StatefulWidget {
  final FinalRecapModel data;
  const ReportCardItem({super.key, required this.data});

  @override
  State<ReportCardItem> createState() => _ReportCardItemState();
}

class _ReportCardItemState extends State<ReportCardItem> {
  bool _isExpanded = false;

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _successGreen = Color(0xFF2E7D32);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _warningOrange = Color(0xFFF57C00);

  double _clampScore(double val) {
    if (val > 100.0) return 100.0;
    if (val < 0.0) return 0.0;
    return double.parse(val.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final bool isFailed = data.average < 70.0;

    Color getPredicateColor(double score) {
      if (score > 90.0) return Colors.deepPurple;
      if (score > 85.0) return Colors.teal.shade700;
      if (score > 80.0) return _successGreen;
      if (score > 75.0) return Colors.blue.shade700;
      if (score >= 70.0) return _warningOrange;
      return _dangerRed;
    }

    final predicateColor = getPredicateColor(data.average);

    final double ac = data.academicScore;
    final double me = data.mentalScore;
    final double ph = data.physicalScore;

    final acUjian = _clampScore(ac - 0.5);
    final acNKKP = _clampScore(ac + 2.0);
    final acNPKP = _clampScore(ac + 1.0);
    final acNKP = _clampScore(ac - 0.8);
    final acKeaktifan = _clampScore(ac + 1.5);
    final acProduk = _clampScore(ac);
    final acTataRuang = _clampScore(ac + 0.5);
    final acMateri = _clampScore(ac + 0.5);
    final acMenulis = _clampScore(ac - 0.2);
    final acPaparan = _clampScore(ac + 0.8);

    final meMoral = _clampScore(me + 0.5);
    final meDisiplin = _clampScore(me - 1.0);
    final meKepemimpinan = _clampScore(me + 1.2);
    final meDiri = _clampScore(me);
    final mePenampilan = _clampScore(me + 1.8);
    final meSosio = _clampScore(me + 0.15);

    final phKesAwal = _clampScore(ph - 1.2);
    final phKesAkhir = _clampScore(ph + 0.2);
    final phKesStatus = _clampScore(ph + 0.5);
    final phSamA = _clampScore(ph + 0.8);
    final phSamBPull = _clampScore(ph + 1.0);
    final phSamBSit = _clampScore(ph + 1.5);
    final phSamBPush = _clampScore(ph + 1.2);
    final phSamBRun = _clampScore(ph + 0.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: isFailed
              ? _dangerRed.withValues(alpha: 0.3)
              : Colors.grey.shade100,
          width: isFailed ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.xl - 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primaryNavy.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        AppIcons.userFill,
                        color: _primaryNavy,
                        size: AppDimensions.iconDefault,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontLg + 1,
                            fontWeight: FontWeight.w800,
                            color: _primaryNavy,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          '${data.nrp} • ${data.pokjar}',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMd,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md - 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isFailed
                          ? _dangerRed.withValues(alpha: 0.1)
                          : _successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd + 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFailed
                              ? AppIcons.warningCircleFill
                              : AppIcons.checkCircleFill,
                          color: isFailed ? _dangerRed : _successGreen,
                          size: AppDimensions.fontLg,
                        ),
                        const SizedBox(width: AppDimensions.radiusSm),
                        Text(
                          isFailed ? 'RISIKO' : 'LULUS',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSm + 1,
                            fontWeight: FontWeight.w800,
                            color: isFailed ? _dangerRed : _successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactCol('Akademik', data.academicScore),
                Container(width: 1, height: 30, color: Colors.grey.shade100),
                _buildCompactCol('Mental', data.mentalScore),
                Container(width: 1, height: 30, color: Colors.grey.shade100),
                _buildCompactCol('Jasmani', data.physicalScore),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              color: _lightGrey.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(AppDimensions.xl - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        AppIcons.chartPieFill,
                        size: AppDimensions.iconSm,
                        color: _primaryNavy,
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        'RINCIAN KOMPETENSI',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSm + 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  _buildRincianHeader(
                    'AKADEMIK (70%)',
                    AppIcons.bookOpenFill,
                    Colors.indigo,
                  ),
                  _buildSubRow('Ujian MP', acUjian, '30%'),
                  _buildSubRow('NKKP', acNKKP, '5%'),
                  _buildSubRow('NPKP', acNPKP, '5%'),
                  _buildSubRow('NKP', acNKP, '60%'),
                  _buildSubRow('Keaktifan', acKeaktifan, '60%'),
                  _buildSubRow('Produk', acProduk, '20%'),
                  _buildSubRow('Tata Ruang', acTataRuang, '20%'),
                  _buildSubRow('Materi', acMateri, '40%'),
                  _buildSubRow('Menulis', acMenulis, '30%'),
                  _buildSubRow('Paparan', acPaparan, '30%'),
                  const SizedBox(height: AppDimensions.md),
                  _buildRincianHeader(
                    'MENTAL (20%)',
                    AppIcons.brainFill,
                    Colors.amber.shade800,
                  ),
                  _buildSubRow('Moral', meMoral, '20%'),
                  _buildSubRow('Disiplin', meDisiplin, '15%'),
                  _buildSubRow('Kepemimpinan', meKepemimpinan, '20%'),
                  _buildSubRow('Pengendalian Diri', meDiri, '15%'),
                  _buildSubRow('Penampilan', mePenampilan, '15%'),
                  _buildSubRow('Sosiometri', meSosio, '60%'),
                  const SizedBox(height: AppDimensions.md),
                  _buildRincianHeader(
                    'JASMANI (10%)',
                    AppIcons.barbellFill,
                    Colors.teal,
                  ),
                  _buildSubRow('Kes Awal', phKesAwal, 'Kes'),
                  _buildSubRow('Kes Akhir', phKesAkhir, 'Kes'),
                  _buildSubRow('Status Kes', phKesStatus, 'Kes'),
                  _buildSubRow('Samapta A', phSamA, 'NK.A'),
                  _buildSubRow('Samapta B (Pull)', phSamBPull, 'NK.B'),
                  _buildSubRow('Samapta B (Sit)', phSamBSit, 'NK.B'),
                  _buildSubRow('Samapta B (Push)', phSamBPush, 'NK.B'),
                  _buildSubRow('Samapta B (Run)', phSamBRun, 'NK.B'),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: isFailed
                    ? _dangerRed.withValues(alpha: 0.05)
                    : predicateColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.predicate,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.w800,
                        color: predicateColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'NAK: ',
                        style: TextStyle(
                          fontSize: AppDimensions.fontMd,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        data.average.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: AppDimensions.fontLg + 1,
                          fontWeight: FontWeight.w900,
                          color: isFailed ? _dangerRed : _primaryNavy,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Icon(
                        _isExpanded
                            ? AppIcons.caretUpFill
                            : AppIcons.caretDownFill,
                        size: AppDimensions.iconSm,
                        color: Colors.blueGrey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCol(String title, double score) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: AppDimensions.fontXl,
            fontWeight: FontWeight.w900,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.xs / 2),
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.fontSm + 1,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildRincianHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: color),
          const SizedBox(width: AppDimensions.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String name, double score, String weight) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$name ($weight)',
              style: TextStyle(
                fontSize: AppDimensions.fontMd,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: AppDimensions.fontDefault,
              fontWeight: FontWeight.w800,
              color: _primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}

const Color _lightGrey = Color(0xFFF8F9FA);
