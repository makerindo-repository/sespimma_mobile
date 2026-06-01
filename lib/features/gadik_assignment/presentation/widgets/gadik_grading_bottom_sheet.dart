import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import '../../data/models/gadik_assignment_model.dart';
import '../../data/models/gadik_submission_model.dart';

class GadikGradingBottomSheet extends StatefulWidget {
  final GadikAssignmentModel assignment;
  final GadikSubmissionModel submission;
  final Function(GadikSubmissionModel) onSaved;

  const GadikGradingBottomSheet({
    super.key,
    required this.assignment,
    required this.submission,
    required this.onSaved,
  });

  @override
  State<GadikGradingBottomSheet> createState() => _GadikGradingBottomSheetState();
}

class _GadikGradingBottomSheetState extends State<GadikGradingBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Components for NKKP/NPKP/NKP/TASKAP
  late TextEditingController _materiCtrl;
  late TextEditingController _penulisanCtrl;
  late TextEditingController _paparanCtrl;
  late TextEditingController _keaktifanCtrl;

  // Components for Ujian
  late TextEditingController _ujianCtrl;

  // Components for Simulasi
  late TextEditingController _keaktifanPerseoranganCtrl;
  late TextEditingController _produkPerseoranganCtrl;
  late TextEditingController _tataRuangCtrl;

  late TextEditingController _catatanCtrl;

  double _calculatedNA = 0.0;

  @override
  void initState() {
    super.initState();
    final s = widget.submission;

    _materiCtrl = TextEditingController(text: s.scoreMateri?.toString() ?? '');
    _penulisanCtrl = TextEditingController(text: s.scorePenulisan?.toString() ?? '');
    _paparanCtrl = TextEditingController(text: s.scorePaparan?.toString() ?? '');
    _keaktifanCtrl = TextEditingController(text: s.scoreKeaktifan?.toString() ?? '');
    _ujianCtrl = TextEditingController(text: s.scoreUjian?.toString() ?? '');
    _keaktifanPerseoranganCtrl =
        TextEditingController(text: s.scoreKeaktifanPerseorangan?.toString() ?? '');
    _produkPerseoranganCtrl =
        TextEditingController(text: s.scoreProdukPerseorangan?.toString() ?? '');
    _tataRuangCtrl = TextEditingController(text: s.scoreTataRuang?.toString() ?? '');
    _catatanCtrl = TextEditingController(text: s.catatanPengajar ?? '');

    _materiCtrl.addListener(_calculate);
    _penulisanCtrl.addListener(_calculate);
    _paparanCtrl.addListener(_calculate);
    _keaktifanCtrl.addListener(_calculate);
    _ujianCtrl.addListener(_calculate);
    _keaktifanPerseoranganCtrl.addListener(_calculate);
    _produkPerseoranganCtrl.addListener(_calculate);
    _tataRuangCtrl.addListener(_calculate);

    _calculate();
  }

  @override
  void dispose() {
    _materiCtrl.dispose();
    _penulisanCtrl.dispose();
    _paparanCtrl.dispose();
    _keaktifanCtrl.dispose();
    _ujianCtrl.dispose();
    _keaktifanPerseoranganCtrl.dispose();
    _produkPerseoranganCtrl.dispose();
    _tataRuangCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  double _parse(String val) {
    if (val.isEmpty) return 0.0;
    return double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
  }

  void _calculate() {
    double total = 0.0;
    final jenis = widget.assignment.jenisTugas;

    if (jenis == 'Ujian Mata Pelajaran atau Esai') {
      total = _parse(_ujianCtrl.text);
    } else if (jenis == 'NKKP (Naskah Kuliah Kerja Profesi)' || jenis == 'NPKP (Naskah Praktek Kerja Profesi)') {
      double m = _parse(_materiCtrl.text);
      double p = _parse(_paparanCtrl.text);
      double k = _parse(_keaktifanCtrl.text);
      total = ((m * 35) + (p * 35) + (k * 30)) / 100;
    } else if (jenis == 'NKP (Naskah Karya Perseorangan)') {
      double m = _parse(_materiCtrl.text);
      double p = _parse(_paparanCtrl.text);
      total = ((m * 50) + (p * 50)) / 100;
    } else if (jenis == 'Simulasi Kepemimpinan Kontemporer') {
      double k = _parse(_keaktifanPerseoranganCtrl.text);
      double p = _parse(_produkPerseoranganCtrl.text);
      double t = _parse(_tataRuangCtrl.text);
      total = ((k * 60) + (p * 20) + (t * 20)) / 100;
    } else if (jenis == 'NPTT (Naskah Program Transformasi Teknis)') {
      double m = _parse(_materiCtrl.text);
      double pe = _parse(_penulisanCtrl.text);
      double p = _parse(_paparanCtrl.text);
      total = ((m * 40) + (pe * 30) + (p * 30)) / 100;
    }

    setState(() {
      _calculatedNA = total;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final s = GadikSubmissionModel(
        id: widget.submission.id,
        assignmentId: widget.submission.assignmentId,
        serdikName: widget.submission.serdikName,
        serdikNrp: widget.submission.serdikNrp,
        submittedAt: widget.submission.submittedAt,
        fileName: widget.submission.fileName,
        fileUrl: widget.submission.fileUrl,
        isGraded: true,
        nilaiAkhir: _calculatedNA,
        catatanPengajar: _catatanCtrl.text,
        scoreMateri: _materiCtrl.text.isNotEmpty ? _parse(_materiCtrl.text) : null,
        scorePenulisan: _penulisanCtrl.text.isNotEmpty ? _parse(_penulisanCtrl.text) : null,
        scorePaparan: _paparanCtrl.text.isNotEmpty ? _parse(_paparanCtrl.text) : null,
        scoreKeaktifan: _keaktifanCtrl.text.isNotEmpty ? _parse(_keaktifanCtrl.text) : null,
        scoreUjian: _ujianCtrl.text.isNotEmpty ? _parse(_ujianCtrl.text) : null,
        scoreKeaktifanPerseorangan:
            _keaktifanPerseoranganCtrl.text.isNotEmpty ? _parse(_keaktifanPerseoranganCtrl.text) : null,
        scoreProdukPerseorangan:
            _produkPerseoranganCtrl.text.isNotEmpty ? _parse(_produkPerseoranganCtrl.text) : null,
        scoreTataRuang: _tataRuangCtrl.text.isNotEmpty ? _parse(_tataRuangCtrl.text) : null,
      );

      widget.onSaved(s);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Penilaian Serdik',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.submission.serdikName} - ${widget.submission.serdikNrp}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Rendering Form based on jenisTugas
                  _buildDynamicForm(),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kalkulasi Nilai Akhir:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Text(
                          _calculatedNA.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Catatan Pengajar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _catatanCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Masukkan catatan, saran, atau komentar',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                      child: const Text(
                        'Simpan Nilai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildDynamicForm() {
    final jenis = widget.assignment.jenisTugas;

    if (jenis == 'Ujian Mata Pelajaran atau Esai') {
      return _buildInputRow('Nilai Ujian / Esai (100%)', _ujianCtrl);
    } else if (jenis == 'NKKP (Naskah Kuliah Kerja Profesi)' || jenis == 'NPKP (Naskah Praktek Kerja Profesi)') {
      return Column(
        children: [
          _buildInputRow('Materi & Penulisan (35%)', _materiCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Paparan (35%)', _paparanCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Keaktifan (30%)', _keaktifanCtrl),
        ],
      );
    } else if (jenis == 'NKP (Naskah Karya Perseorangan)') {
      return Column(
        children: [
          _buildInputRow('Materi & Penulisan (50%)', _materiCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Paparan (50%)', _paparanCtrl),
        ],
      );
    } else if (jenis == 'Simulasi Kepemimpinan Kontemporer') {
      return Column(
        children: [
          _buildInputRow('Keaktifan Perseorangan (60%)', _keaktifanPerseoranganCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Produk Perseorangan (20%)', _produkPerseoranganCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Tata Ruang Kelompok (20%)', _tataRuangCtrl),
        ],
      );
    } else if (jenis == 'NPTT (Naskah Program Transformasi Teknis)') {
      return Column(
        children: [
          _buildInputRow('Materi NPTT/Taskap (40%)', _materiCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Penulisan Efektif (30%)', _penulisanCtrl),
          const SizedBox(height: 12),
          _buildInputRow('Paparan & Diskusi (30%)', _paparanCtrl),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryNavy),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Isi';
              final d = double.tryParse(value.replaceAll(',', '.'));
              if (d == null || d < 0 || d > 100) return '0-100';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
