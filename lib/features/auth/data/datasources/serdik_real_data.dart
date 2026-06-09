import 'dart:convert';
import 'package:flutter/services.dart';

class SerdikRealData {
  static List<Map<String, dynamic>> records = const [];

  static Future<void> loadFromAsset() async {
    final raw = await rootBundle.loadString('assets/serdik_clean.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    records = List<Map<String, dynamic>>.from(json['data'] as List);
  }
}
