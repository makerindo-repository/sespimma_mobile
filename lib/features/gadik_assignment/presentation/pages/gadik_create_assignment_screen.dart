import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';
import '../../data/models/gadik_assignment_model.dart';
import '../../data/datasources/gadik_assignment_mock_data.dart';

class GadikCreateAssignmentScreen extends StatefulWidget {
  const GadikCreateAssignmentScreen({super.key});

  @override
  State<GadikCreateAssignmentScreen> createState() =>
      _GadikCreateAssignmentScreenState();
}

class _GadikCreateAssignmentScreenState
    extends State<GadikCreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _instruksiController = TextEditingController();

  String _jenisTugas = 'Ujian Mata Pelajaran atau Esai';
  String? _turunanTugas;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  String _targetPokjar = 'Semua Pokjar';

  final List<String> _jenisTugasList = [
    'Ujian Mata Pelajaran atau Esai',
    'NKKP (Naskah Kuliah Kerja Profesi)',
    'NPKP (Naskah Praktek Kerja Profesi)',
    'NKP (Naskah Karya Perseorangan)',
    'Simulasi Kepemimpinan Kontemporer',
    'NPTT (Naskah Program Transformasi Teknis)'
  ];

  final List<String> _kompetensiNKP = [
    'Kemampuan Membuat Keputusan Strategis',
    'Kecerdasan Emosional (EQ)',
    'Komunikasi Efektif',
    'Kemampuan Membangun dan Memimpin',
    'Adaptabilitas & Pembelajaran Kontinu',
    'Visi & Strategic Thinking',
    'Integritas & Etika',
    'Kemampuan Mendayagunakan Teknologi',
    'Empati & Pelayanan',
    'Resilience & Ketahanan Mental'
  ];

  final List<String> _pokjarList = [
    'Semua Pokjar',
    'Pokjar I',
    'Pokjar II',
    'Pokjar III',
    'Pokjar IV',
    'Pokjar V',
  ];

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = GadikAssignmentModel(
        id: 'GTSK-${DateTime.now().millisecondsSinceEpoch}',
        judul: _judulController.text,
        jenisTugas: _jenisTugas,
        turunanTugas: _jenisTugas == 'NKP (Naskah Karya Perseorangan)' ? _turunanTugas : null,
        deadline: _deadline,
        targetPokjar: _targetPokjar,
        instruksi: _instruksiController.text,
        status: 'Sedang Mulai',
        createdBy: 'Efrianza',
        createdAt: DateTime.now(),
      );

      GadikAssignmentMockData.assignments.add(newTask);
      Navigator.pop(context, true);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.caretLeft, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Tugas Baru',
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Judul Tugas'),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration('Masukkan judul tugas'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Jenis Tugas'),
              DropdownButtonFormField<String>(
                initialValue: _jenisTugas,
                decoration: _inputDecoration('Pilih jenis tugas'),
                items: _jenisTugasList
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _jenisTugas = val!;
                    if (_jenisTugas == 'NKP (Naskah Karya Perseorangan)') {
                      _turunanTugas = _kompetensiNKP.first;
                    } else {
                      _turunanTugas = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              if (_jenisTugas == 'NKP (Naskah Karya Perseorangan)') ...[
                _buildLabel('Kompetensi Utama (Khusus NKP)'),
                DropdownButtonFormField<String>(
                  initialValue: _turunanTugas,
                  decoration: _inputDecoration('Pilih kompetensi'),
                  items: _kompetensiNKP
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setState(() => _turunanTugas = val),
                ),
                const SizedBox(height: 20),
              ],

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Batas Pengumpulan'),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: _inputDecoration('Pilih Tanggal'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_deadline.toString().substring(0, 10)),
                                const Icon(AppIcons.calendarBlank, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Target Distribusi'),
                        DropdownButtonFormField<String>(
                          initialValue: _targetPokjar,
                          decoration: _inputDecoration('Pilih Target'),
                          items: _pokjarList
                              .map((p) =>
                                  DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (val) => setState(() => _targetPokjar = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Instruksi Tugas'),
              TextFormField(
                controller: _instruksiController,
                maxLines: 4,
                decoration: _inputDecoration('Ketik instruksi atau deskripsi tugas'),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Simpan & Distribusikan',
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
      ),
    );
  }
}
