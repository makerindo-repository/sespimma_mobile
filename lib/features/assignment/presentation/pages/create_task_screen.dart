import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sespimma_mobile/features/assignment/data/models/tugas_model.dart';
import 'package:sespimma_mobile/features/leadership_dashboard/data/datasources/pimpinan_mock_data.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sespimma_mobile/features/auth/presentation/bloc/auth_state.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedSubject;

  late AnimationController _animController;
  late Animation<double> _formAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  String? _selectedPokjar;
  DateTime? _selectedDeadline;
  String? _attachedFileName;
  bool _isAttaching = false;

  static const Color _primaryNavy = Color(0xFF001C40);
  static const Color _lightGrey = Color(0xFFF8F9FA);
  static const Color _successGreen = Color(0xFF2E7D32);

  final List<String> _pokjarList = [
    'Semua POKJAR',
    'POKJAR 1',
    'POKJAR 2',
    'POKJAR 3',
    'POKJAR 4',
    'POKJAR 5',
  ];

  final List<String> _subjectList = [
    'NKP (Naskah Karya Perseorangan)',
    'NKKP (Naskah Kuliah Kerja Profesi)',
    'NPKP (Naskah Praktek Kerja Profesi)',
    'Ujian MP / Esai',
    'Mental Kepribadian',
    'Etika & Kepemimpinan',
    'Manajemen Strategis',
    'Sistem Informasi Publik',
  ];

  @override
  void dispose() {
    _animController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isAttaching = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal memilih file. Silakan coba lagi.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAttaching = false);
      }
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryNavy,
              onPrimary: Colors.white,
              onSurface: _primaryNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _primaryNavy,
                onPrimary: Colors.white,
                onSurface: _primaryNavy,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _publishTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Silahkan pilih mata pelajaran terlebih dahulu'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedPokjar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Silahkan pilih target POKJAR terlebih dahulu'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Silahkan tentukan tenggat waktu tugas'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      String currentNrp = '';
      String currentName = 'Pengajar';
      
      if (authState is AuthSuccess) {
        currentNrp = authState.user.nrp;
        currentName = authState.user.name;
      }

      final newTask = TugasModel(
        id: 'TSK-${DateTime.now().millisecondsSinceEpoch}',
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        mapel: _selectedSubject!,
        deadline: _selectedDeadline!,
        status: 'Aktif',
        createdBy: currentNrp,
        createdByName: currentName,
      );

      setState(() {
        PimpinanMockData.sharedTasks.insert(0, newTask);

        for (var serdik in PimpinanMockData.sharedReportData.take(5)) {
          PimpinanMockData.sharedTaskSubmissions.add({
            'taskId': newTask.id,
            'name': serdik.name,
            'nrp': serdik.nrp,
            'pokjar': serdik.pokjar.toUpperCase(),
            'status': 'belum',
            'file': null,
            'time': '-',
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: AppDimensions.sm),
              Expanded(child: Text('Tugas berhasil dipublikasikan ke Serdik.')),
            ],
          ),
          backgroundColor: _successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          margin: const EdgeInsets.all(AppDimensions.lg),
        ),
      );
      Navigator.pop(context);
    }
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
          'Buat Tugas Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.fontXxl,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _formAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_formAnimation),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.xxl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          const Text(
                            'Informasi Tugas',
                            style: TextStyle(
                              fontSize: AppDimensions.fontXl,
                              fontWeight: FontWeight.w800,
                              color: _primaryNavy,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),

                          _buildTextField(
                            controller: _judulController,
                            label: 'Judul Tugas',
                            hint: 'Masukkan judul tugas...',
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: AppDimensions.md),

                          _buildSubjectDropdownField(),
                          const SizedBox(height: AppDimensions.md),

                          _buildDropdownField(),
                          const SizedBox(height: AppDimensions.md),

                          _buildDeadlineField(),
                          const SizedBox(height: AppDimensions.md),

                          _buildTextField(
                            controller: _deskripsiController,
                            label: 'Deskripsi dan Instruksi',
                            hint: 'Tuliskan instruksi tugas secara detail...',
                            icon: Icons.description_outlined,
                            maxLines: 5,
                          ),
                          const SizedBox(height: AppDimensions.md),

                          _buildAttachmentField(),
                          const SizedBox(height: AppDimensions.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _buttonAnimation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_buttonAnimation),
                child: _buildBottomActionButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppDimensions.fontDefault,
            fontWeight: FontWeight.w700,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label wajib diisi';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.blueGrey.shade300,
                fontSize: AppDimensions.fontLg,
              ),
              prefixIcon: maxLines == 1
                  ? Icon(icon, color: Colors.blueGrey.shade400, size: AppDimensions.iconDefault)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Icon(
                        icon,
                        color: Colors.blueGrey.shade400,
                        size: AppDimensions.iconDefault,
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: _primaryNavy, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mata Pelajaran',
          style: TextStyle(
            fontSize: AppDimensions.fontDefault,
            fontWeight: FontWeight.w700,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.blueGrey.shade400,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.menu_book_rounded,
                color: Colors.blueGrey.shade400,
                size: AppDimensions.iconDefault,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: _primaryNavy, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Pilih mata pelajaran',
              style: TextStyle(color: Colors.blueGrey.shade300, fontSize: AppDimensions.fontLg),
            ),
            items: _subjectList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                    color: _primaryNavy,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedSubject = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Distribusi (POKJAR)',
          style: TextStyle(
            fontSize: AppDimensions.fontDefault,
            fontWeight: FontWeight.w700,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedPokjar,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.blueGrey.shade400,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.groups_rounded,
                color: Colors.blueGrey.shade400,
                size: AppDimensions.iconDefault,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: _primaryNavy, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Pilih kelompok belajar sasaran',
              style: TextStyle(color: Colors.blueGrey.shade300, fontSize: AppDimensions.fontLg),
            ),
            items: _pokjarList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.w600,
                    color: _primaryNavy,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedPokjar = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    final String displayDate = _selectedDeadline != null
        ? '${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year} - ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')} WIB'
        : 'Pilih Tenggat Waktu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tenggat Waktu',
          style: TextStyle(
            fontSize: AppDimensions.fontDefault,
            fontWeight: FontWeight.w700,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _selectedDeadline != null
                  ? _primaryNavy
                  : Colors.grey.shade200,
              width: _selectedDeadline != null ? 1.5 : 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              onTap: _selectDeadline,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: _selectedDeadline != null
                          ? _primaryNavy
                          : Colors.blueGrey.shade400,
                      size: AppDimensions.iconDefault,
                    ),
                    const SizedBox(width: AppDimensions.md - 4),
                    Expanded(
                      child: Text(
                        displayDate,
                        style: TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: _selectedDeadline != null
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: _selectedDeadline != null
                              ? _primaryNavy
                              : Colors.blueGrey.shade300,
                        ),
                      ),
                    ),
                    if (_selectedDeadline != null)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _successGreen,
                        size: AppDimensions.iconDefault,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _publishTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.send_rounded, size: AppDimensions.iconDefault),
            label: const Text(
              'PUBLIKASIKAN TUGAS',
              style: TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampiran',
          style: TextStyle(
            fontSize: AppDimensions.fontDefault,
            fontWeight: FontWeight.w700,
            color: _primaryNavy,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        InkWell(
          onTap: _isAttaching ? null : _pickFile,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: _attachedFileName != null
                    ? _primaryNavy.withValues(alpha: 0.5)
                    : Colors.grey.shade300,
                width: _attachedFileName != null ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm + 2),
                  decoration: BoxDecoration(
                    color: _attachedFileName != null
                        ? _primaryNavy.withValues(alpha: 0.1)
                        : _lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: _isAttaching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryNavy,
                          ),
                        )
                      : Icon(
                          _attachedFileName != null
                              ? Icons.description_rounded
                              : Icons.attach_file_rounded,
                          color: _attachedFileName != null
                              ? _primaryNavy
                              : Colors.blueGrey.shade400,
                          size: AppDimensions.iconDefault,
                        ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _attachedFileName ?? 'Pilih file lampiran tugas',
                        style: TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: _attachedFileName != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _attachedFileName != null
                              ? _primaryNavy
                              : Colors.blueGrey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_attachedFileName == null)
                        Text(
                          'Format: PDF, DOC, PPT',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMd,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_attachedFileName != null)
                  IconButton(
                    onPressed: () => setState(() => _attachedFileName = null),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.red.shade400,
                      size: AppDimensions.iconDefault,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
