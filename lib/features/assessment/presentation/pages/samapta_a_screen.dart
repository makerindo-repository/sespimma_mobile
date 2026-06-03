// lib/features/assessment/presentation/pages/samapta_a_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sespimma_mobile/core/constants/app_dimensions.dart';
import 'package:sespimma_mobile/core/theme/app_colors.dart';
import 'package:sespimma_mobile/features/assessment/data/models/jasmani_grading_data.dart';
import 'package:sespimma_mobile/features/assessment/data/datasources/jasmani_lookup_tables.dart';

class SamaptaAScreen extends StatefulWidget {
  final Map<String, dynamic> serdik;
  final JasmaniGradingData gradingData;
  final String golongan;
  final String gender;

  const SamaptaAScreen({
    super.key,
    required this.serdik,
    required this.gradingData,
    required this.golongan,
    required this.gender,
  });

  @override
  State<SamaptaAScreen> createState() => _SamaptaAScreenState();
}

class _SamaptaAScreenState extends State<SamaptaAScreen> {
  final TextEditingController _distanceController = TextEditingController();
  double _ngaScore = 0.0;

  @override
  void initState() {
    super.initState();
    // If we have previous grading
    if (widget.gradingData.nilaiA != null) {
      // Actually we don't save distance, only the final score in the mock model.
      // In a real app we'd save both. For now, we just initialize the score.
      _ngaScore = widget.gradingData.nilaiA!;
      // Assume a default reverse calculation or just leave distance empty
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void _calculateScore(String value) {
    if (value.isEmpty) {
      setState(() => _ngaScore = 0.0);
      return;
    }
    
    final int? meters = int.tryParse(value);
    if (meters != null) {
      final double score = JasmaniLookupTables.getNilaiLari(meters, widget.gender, widget.golongan);
      setState(() {
        _ngaScore = score;
      });
    }
  }

  void _saveData() {
    if (_ngaScore == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jarak belum diisi atau tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    widget.gradingData.nilaiA = _ngaScore;
    JasmaniGradingData.saveJasmaniData(widget.gradingData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nilai Samapta A berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isGol4 = widget.golongan == 'GOL IV';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isGol4 ? 'Jalan Kaki 20 Menit' : 'Lari/Jalan 12 Menit',
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInsightInfo(isGol4),
            const SizedBox(height: AppDimensions.xl),
            
            // Calculator Section
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Jarak (Meter)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _distanceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: _calculateScore,
                          decoration: InputDecoration(
                            hintText: 'Misal: 2500',
                            filled: true,
                            fillColor: Colors.grey.shade50,
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
                              borderSide: const BorderSide(color: AppColors.primaryNavy),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('m', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.lg),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _ngaScore >= 70 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: _ngaScore >= 70 ? Colors.green.shade200 : Colors.red.shade200,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _ngaScore.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: AppDimensions.fontLg,
                              fontWeight: FontWeight.w800,
                              color: _ngaScore >= 70 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.xxxl),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: const Text(
                'SIMPAN NILAI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightInfo(bool isGol4) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insight Information',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'APA ITU:',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue.shade900, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            isGol4 
              ? 'Tes jalan kaki selama 20 menit untuk mengukur daya tahan kardiovaskuler serdik khusus Golongan IV.'
              : 'Tes lari atau jalan (tetap dihitung) selama 12 menit untuk mengukur daya tahan kardiovaskuler serdik.',
            style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'TEKNIS PELAKSANAAN:',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue.shade900, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            isGol4 
              ? '• Serdik berjalan kaki\n• Durasi: 20 MENIT\n• Yang diukur: JARAK yang ditempuh (dalam meter)'
              : '• Serdik berlari ATAU berjalan\n• Durasi: 12 MENIT\n• Yang diukur: JARAK yang ditempuh (dalam meter)',
            style: TextStyle(color: Colors.blue.shade800, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
