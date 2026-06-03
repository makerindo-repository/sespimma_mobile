// lib/features/assessment/data/datasources/jasmani_lookup_tables.dart
import 'package:intl/intl.dart';

class JasmaniLookupTables {
  static String getGolongan(String tanggalLahir, [DateTime? testDate]) {
    if (tanggalLahir.isEmpty || tanggalLahir == '-') {
      {
        return 'GOL II';
      }
    }
    try {
      final dob = DateFormat('yyyy-MM-dd').parse(tanggalLahir);
      final test = testDate ?? DateTime.now();
      int age = test.year - dob.year;
      if (test.month < dob.month ||
          (test.month == dob.month && test.day < dob.day)) {
        age--;
      }
      if (test.month == dob.month && test.day == dob.day) {
        age++;
      }
      if (age <= 30) {
        {
          return 'GOL I';
        }
      }
      if (age <= 40) {
        {
          return 'GOL II';
        }
      }
      if (age <= 50) {
        {
          return 'GOL III';
        }
      }
      return 'GOL IV';
    } catch (e) {
      {
        return 'GOL II';
      }
    }
  }

  static double getNilaiLari(int value, String gender, String gol) {
    bool isPria =
        gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'pria';
    Map<double, int> map;
    if (gol == 'GOL I') {
      map = isPria ? _datagetNilaiLariPriaGol1 : _datagetNilaiLariWanitaGol1;
    } else if (gol == 'GOL II') {
      map = isPria ? _datagetNilaiLariPriaGol2 : _datagetNilaiLariWanitaGol2;
    } else {
      map = isPria ? _datagetNilaiLariPriaGol3 : _datagetNilaiLariWanitaGol3;
    }

    // Find exact or nearest
    if (map.containsKey(value.toDouble())) {
      return map[value.toDouble()]!.toDouble();
    }

    // Nearest logic
    double bestVal = -1;
    for (var k in map.keys) {
      if (value >= k) {
        if (bestVal == -1 || (k > bestVal)) {
          bestVal = k;
        }
      }
    }
    if (bestVal != -1) {
      {
        return map[bestVal]!.toDouble();
      }
    }

    // If worse than lowest in map
    double worstVal = -1;
    for (var k in map.keys) {
      if (worstVal == -1 || (k < worstVal)) {
        worstVal = k;
      }
    }
    if (worstVal != -1) {
      // proportional penalty below lowest
      double lowestScore = map[worstVal]!.toDouble();
      if (value < worstVal) {
        double diff = worstVal - value;
        double penalty = diff * (lowestScore / worstVal);
        return (lowestScore - penalty).clamp(0.0, lowestScore);
      }
    }

    return 0.0;
  }

  static double getNilaiPullUp(int value, String gender, String gol) {
    bool isPria =
        gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'pria';
    Map<double, int> map;
    if (gol == 'GOL I') {
      map = isPria
          ? _datagetNilaiPullUpPriaGol1
          : _datagetNilaiPullUpWanitaGol1;
    } else if (gol == 'GOL II') {
      map = isPria
          ? _datagetNilaiPullUpPriaGol2
          : _datagetNilaiPullUpWanitaGol2;
    } else {
      map = isPria
          ? _datagetNilaiPullUpPriaGol3
          : _datagetNilaiPullUpWanitaGol3;
    }

    // Find exact or nearest
    if (map.containsKey(value.toDouble())) {
      return map[value.toDouble()]!.toDouble();
    }

    // Nearest logic
    double bestVal = -1;
    for (var k in map.keys) {
      if (value >= k) {
        if (bestVal == -1 || (k > bestVal)) {
          bestVal = k;
        }
      }
    }
    if (bestVal != -1) {
      {
        return map[bestVal]!.toDouble();
      }
    }

    // If worse than lowest in map
    double worstVal = -1;
    for (var k in map.keys) {
      if (worstVal == -1 || (k < worstVal)) {
        worstVal = k;
      }
    }
    if (worstVal != -1) {
      // proportional penalty below lowest
      double lowestScore = map[worstVal]!.toDouble();
      if (value < worstVal) {
        double diff = worstVal - value;
        double penalty = diff * (lowestScore / worstVal);
        return (lowestScore - penalty).clamp(0.0, lowestScore);
      }
    }

    return 0.0;
  }

  static double getNilaiPushUp(int value, String gender, String gol) {
    bool isPria =
        gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'pria';
    Map<double, int> map;
    if (gol == 'GOL I') {
      map = isPria
          ? _datagetNilaiPushUpPriaGol1
          : _datagetNilaiPushUpWanitaGol1;
    } else if (gol == 'GOL II') {
      map = isPria
          ? _datagetNilaiPushUpPriaGol2
          : _datagetNilaiPushUpWanitaGol2;
    } else {
      map = isPria
          ? _datagetNilaiPushUpPriaGol3
          : _datagetNilaiPushUpWanitaGol3;
    }

    // Find exact or nearest
    if (map.containsKey(value.toDouble())) {
      return map[value.toDouble()]!.toDouble();
    }

    // Nearest logic
    double bestVal = -1;
    for (var k in map.keys) {
      if (value >= k) {
        if (bestVal == -1 || (k > bestVal)) {
          bestVal = k;
        }
      }
    }
    if (bestVal != -1) {
      {
        return map[bestVal]!.toDouble();
      }
    }

    // If worse than lowest in map
    double worstVal = -1;
    for (var k in map.keys) {
      if (worstVal == -1 || (k < worstVal)) {
        worstVal = k;
      }
    }
    if (worstVal != -1) {
      // proportional penalty below lowest
      double lowestScore = map[worstVal]!.toDouble();
      if (value < worstVal) {
        double diff = worstVal - value;
        double penalty = diff * (lowestScore / worstVal);
        return (lowestScore - penalty).clamp(0.0, lowestScore);
      }
    }

    return 0.0;
  }

  static double getNilaiSitUp(int value, String gender, String gol) {
    bool isPria =
        gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'pria';
    Map<double, int> map;
    if (gol == 'GOL I') {
      map = isPria ? _datagetNilaiSitUpPriaGol1 : _datagetNilaiSitUpWanitaGol1;
    } else if (gol == 'GOL II') {
      map = isPria ? _datagetNilaiSitUpPriaGol2 : _datagetNilaiSitUpWanitaGol2;
    } else {
      map = isPria ? _datagetNilaiSitUpPriaGol3 : _datagetNilaiSitUpWanitaGol3;
    }

    // Find exact or nearest
    if (map.containsKey(value.toDouble())) {
      return map[value.toDouble()]!.toDouble();
    }

    // Nearest logic
    double bestVal = -1;
    for (var k in map.keys) {
      if (value >= k) {
        if (bestVal == -1 || (k > bestVal)) {
          bestVal = k;
        }
      }
    }
    if (bestVal != -1) {
      {
        return map[bestVal]!.toDouble();
      }
    }

    // If worse than lowest in map
    double worstVal = -1;
    for (var k in map.keys) {
      if (worstVal == -1 || (k < worstVal)) {
        worstVal = k;
      }
    }
    if (worstVal != -1) {
      // proportional penalty below lowest
      double lowestScore = map[worstVal]!.toDouble();
      if (value < worstVal) {
        double diff = worstVal - value;
        double penalty = diff * (lowestScore / worstVal);
        return (lowestScore - penalty).clamp(0.0, lowestScore);
      }
    }

    return 0.0;
  }

  static double getNilaiShuttleRun(double value, String gender, String gol) {
    bool isPria =
        gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'pria';
    Map<double, int> map;
    if (gol == 'GOL I') {
      map = isPria
          ? _datagetNilaiShuttleRunPriaGol1
          : _datagetNilaiShuttleRunWanitaGol1;
    } else if (gol == 'GOL II') {
      map = isPria
          ? _datagetNilaiShuttleRunPriaGol2
          : _datagetNilaiShuttleRunWanitaGol2;
    } else {
      map = isPria
          ? _datagetNilaiShuttleRunPriaGol3
          : _datagetNilaiShuttleRunWanitaGol3;
    }

    // Find exact or nearest
    if (map.containsKey(value.toDouble())) {
      return map[value.toDouble()]!.toDouble();
    }

    // Nearest logic
    double bestVal = -1;
    for (var k in map.keys) {
      if (value <= k) {
        if (bestVal == -1 || (k < bestVal)) {
          bestVal = k;
        }
      }
    }
    if (bestVal != -1) {
      {
        return map[bestVal]!.toDouble();
      }
    }

    // If worse than lowest in map
    double worstVal = -1;
    for (var k in map.keys) {
      if (worstVal == -1 || (k > worstVal)) {
        worstVal = k;
      }
    }
    if (worstVal != -1) {
      // proportional penalty below lowest
      double lowestScore = map[worstVal]!.toDouble();
      if (value > worstVal) {
        double diff = value - worstVal;
        double penalty = diff * (lowestScore / (worstVal * 0.2));
        return (lowestScore - penalty).clamp(0.0, lowestScore);
      }
    }

    return 0.0;
  }

  // INJECTED MAPS
  static final Map<double, int> _datagetNilaiLariPriaGol1 = {
    3444.0: 100,
    3422.0: 99,
    3401.0: 98,
    3380.0: 97,
    3369.0: 96,
    3338.0: 95,
    3317.0: 94,
    3296.0: 93,
    3274.0: 92,
    3253.0: 91,
    3232.0: 90,
    3211.0: 89,
    3190.0: 88,
    3169.0: 87,
    3148.0: 86,
    3126.0: 85,
    3105.0: 84,
    3084.0: 83,
    3062.0: 82,
    3041.0: 81,
    3021.0: 80,
    2999.0: 95,
    2978.0: 94,
    2957.0: 93,
    2936.0: 92,
    2914.0: 91,
    2893.0: 90,
    2872.0: 89,
    2851.0: 88,
    2820.0: 71,
    2809.0: 86,
    2722.0: 69,
    2767.0: 84,
    2746.0: 83,
    2725.0: 82,
    2703.0: 81,
    2682.0: 80,
    2661.0: 79,
    2639.0: 78,
    2618.0: 77,
    2597.0: 76,
    2567.0: 59,
    2555.0: 74,
    2534.0: 73,
    2513.0: 72,
    2491.0: 71,
    2470.0: 70,
    2449.0: 69,
    2428.0: 68,
    2407.0: 67,
    2386.0: 50,
    2364.0: 65,
    2343.0: 64,
    2322.0: 63,
    2301.0: 62,
    2280.0: 61,
    2259.0: 60,
    2237.0: 59,
    2216.0: 58,
    2195.0: 57,
    2174.0: 56,
    2153.0: 55,
    2132.0: 54,
    2111.0: 53,
    2090.0: 52,
    2069.0: 51,
    2048.0: 50,
    2026.0: 33,
    2005.0: 48,
    1984.0: 47,
    1962.0: 46,
    1941.0: 45,
    1920.0: 44,
    1899.0: 43,
    1878.0: 42,
    1857.0: 41,
    1836.0: 40,
    1814.0: 39,
    1793.0: 38,
    1772.0: 37,
    1750.0: 36,
    1729.0: 35,
    1708.0: 34,
    1687.0: 33,
    1666.0: 32,
    1645.0: 31,
    3020.0: 96,
    2830.0: 87,
    2788.0: 85,
    2576.0: 75,
    2385.0: 66,
    2062.0: 49,
    1624.0: 30,
    1603.0: 29,
    1582.0: 28,
    1561.0: 27,
    1539.0: 26,
    1578.0: 25,
    1497.0: 24,
    1476.0: 23,
    1455.0: 22,
    1434.0: 21,
    1412.0: 20,
    1391.0: 19,
    1370.0: 18,
    1349.0: 17,
    1328.0: 16,
    1307.0: 15,
    1286.0: 14,
    1265.0: 13,
    1244.0: 12,
    1223.0: 11,
    1202.0: 10,
    1181.0: 9,
    1160.0: 8,
    1139.0: 7,
    1118.0: 6,
    1097.0: 5,
    1076.0: 4,
    1055.0: 3,
    1034.0: 2,
    1013.0: 1,
  };
  static final Map<double, int> _datagetNilaiLariPriaGol2 = {
    3232.0: 100,
    3211.0: 99,
    3190.0: 98,
    3169.0: 97,
    3148.0: 96,
    3126.0: 95,
    3105.0: 94,
    3084.0: 93,
    3062.0: 92,
    3041.0: 91,
    3021.0: 90,
    2999.0: 89,
    2978.0: 88,
    2957.0: 87,
    2936.0: 86,
    2914.0: 85,
    2893.0: 96,
    2872.0: 95,
    2851.0: 94,
    2820.0: 81,
    2809.0: 92,
    2788.0: 91,
    2767.0: 90,
    2746.0: 89,
    2725.0: 88,
    2703.0: 87,
    2682.0: 86,
    2661.0: 85,
    2639.0: 84,
    2618.0: 83,
    2597.0: 82,
    2576.0: 81,
    2555.0: 80,
    2534.0: 79,
    2513.0: 78,
    2491.0: 77,
    2470.0: 76,
    2449.0: 75,
    2428.0: 74,
    2407.0: 73,
    2386.0: 60,
    2364.0: 71,
    2343.0: 70,
    2322.0: 69,
    2301.0: 56,
    2280.0: 67,
    2259.0: 66,
    2237.0: 65,
    2216.0: 64,
    2195.0: 63,
    2174.0: 62,
    2153.0: 61,
    2132.0: 60,
    2111.0: 59,
    2090.0: 58,
    2069.0: 57,
    2048.0: 56,
    2029.0: 43,
    2005.0: 54,
    1984.0: 53,
    1962.0: 52,
    1941.0: 51,
    1920.0: 50,
    1899.0: 49,
    1878.0: 48,
    1857.0: 47,
    1836.0: 46,
    1814.0: 45,
    1793.0: 44,
    1772.0: 43,
    1750.0: 42,
    1729.0: 41,
    1708.0: 40,
    1687.0: 39,
    1666.0: 38,
    1645.0: 37,
    1625.0: 24,
    1603.0: 35,
    1582.0: 34,
    1516.0: 21,
    1539.0: 32,
    1518.0: 31,
    1497.0: 30,
    1476.0: 29,
    1455.0: 28,
    1434.0: 27,
    2830.0: 93,
    2385.0: 72,
    2361.0: 68,
    2026.0: 55,
    1624.0: 36,
    1561.0: 33,
    1412.0: 26,
    1391.0: 25,
    1370.0: 24,
    1349.0: 23,
    1328.0: 22,
    1307.0: 21,
    1286.0: 20,
    1265.0: 19,
    1244.0: 18,
    1223.0: 17,
    1202.0: 16,
    1181.0: 15,
    1160.0: 14,
    1139.0: 13,
    1118.0: 12,
    1097.0: 11,
    1076.0: 10,
    1055.0: 9,
    1034.0: 8,
    1013.0: 7,
    992.0: 6,
    971.0: 5,
    950.0: 4,
    929.0: 3,
    908.0: 2,
    887.0: 1,
  };
  static final Map<double, int> _datagetNilaiLariPriaGol3 = {
    2936.0: 100,
    2914.0: 99,
    2893.0: 98,
    2872.0: 97,
    2851.0: 96,
    2820.0: 95,
    2809.0: 94,
    2788.0: 93,
    2767.0: 96,
    2746.0: 95,
    2725.0: 94,
    2703.0: 93,
    2682.0: 92,
    2661.0: 91,
    2639.0: 90,
    2618.0: 89,
    2597.0: 84,
    2576.0: 87,
    2555.0: 86,
    2534.0: 85,
    2513.0: 84,
    2491.0: 83,
    2470.0: 82,
    2449.0: 81,
    2428.0: 80,
    2407.0: 79,
    2386.0: 74,
    2364.0: 73,
    2343.0: 76,
    2322.0: 75,
    2301.0: 74,
    2280.0: 73,
    2239.0: 68,
    2237.0: 71,
    2216.0: 70,
    2195.0: 69,
    2174.0: 68,
    2153.0: 67,
    2132.0: 66,
    2111.0: 65,
    2090.0: 64,
    2069.0: 63,
    2048.0: 62,
    2026.0: 61,
    2005.0: 60,
    1984.0: 59,
    1962.0: 58,
    1941.0: 57,
    1920.0: 56,
    1899.0: 55,
    1878.0: 54,
    1857.0: 53,
    1836.0: 52,
    1814.0: 51,
    1793.0: 50,
    1772.0: 49,
    1750.0: 48,
    1729.0: 47,
    1708.0: 46,
    1687.0: 45,
    1666.0: 44,
    1645.0: 43,
    1625.0: 38,
    1603.0: 41,
    1582.0: 40,
    1561.0: 35,
    1539.0: 38,
    1518.0: 37,
    1497.0: 36,
    1476.0: 35,
    1455.0: 34,
    1434.0: 33,
    1412.0: 32,
    1391.0: 31,
    1370.0: 30,
    1349.0: 29,
    1328.0: 28,
    1307.0: 27,
    1286.0: 26,
    1265.0: 25,
    1244.0: 24,
    1223.0: 23,
    1202.0: 22,
    1811.0: 17,
    1160.0: 20,
    1139.0: 19,
    1597.0: 88,
    2385.0: 78,
    2564.0: 77,
    2259.0: 72,
    1624.0: 42,
    1516.0: 39,
    1181.0: 21,
    1118.0: 18,
    1097.0: 17,
    1076.0: 16,
    1055.0: 15,
    1034.0: 14,
    1013.0: 13,
    992.0: 12,
    971.0: 11,
    950.0: 10,
    929.0: 9,
    908.0: 8,
    887.0: 7,
    866.0: 6,
    845.0: 5,
    824.0: 4,
    803.0: 3,
    782.0: 2,
    761.0: 1,
  };
  static final Map<double, int> _datagetNilaiLariWanitaGol1 = {};
  static final Map<double, int> _datagetNilaiLariWanitaGol2 = {};
  static final Map<double, int> _datagetNilaiLariWanitaGol3 = {};
  static final Map<double, int> _datagetNilaiPullUpPriaGol1 = {
    17.0: 100,
    16.0: 94,
    15.0: 88,
    14.0: 82,
    13.0: 76,
    12.0: 70,
    11.0: 64,
    10.0: 58,
    9.0: 52,
    8.0: 46,
    7.0: 39,
    6.0: 32,
    5.0: 26,
    4.0: 20,
    3.0: 14,
  };
  static final Map<double, int> _datagetNilaiPullUpPriaGol2 = {
    15.0: 100,
    14.0: 95,
    13.0: 88,
    12.0: 82,
    11.0: 76,
    10.0: 70,
    9.0: 63,
    8.0: 58,
    7.0: 52,
    6.0: 46,
    5.0: 39,
    4.0: 32,
    3.0: 24,
    2.0: 8,
  };
  static final Map<double, int> _datagetNilaiPullUpPriaGol3 = {
    12.0: 100,
    11.0: 96,
    10.0: 91,
    9.0: 86,
    8.0: 81,
    7.0: 76,
    6.0: 71,
    5.0: 65,
    4.0: 59,
    3.0: 53,
    2.0: 47,
    1.0: 4,
  };
  static final Map<double, int> _datagetNilaiPullUpWanitaGol1 = {
    72.0: 100,
    71.0: 97,
    70.0: 95,
    69.0: 92,
    68.0: 90,
    67.0: 87,
    66.0: 85,
    65.0: 82,
    64.0: 80,
    63.0: 77,
    62.0: 75,
    61.0: 72,
    60.0: 70,
    59.0: 67,
    58.0: 65,
    57.0: 62,
    56.0: 60,
    55.0: 57,
    54.0: 55,
    53.0: 52,
    52.0: 50,
    51.0: 47,
    50.0: 45,
    49.0: 42,
    48.0: 40,
    47.0: 37,
    46.0: 35,
    45.0: 32,
    44.0: 30,
    43.0: 27,
    42.0: 25,
    41.0: 22,
    40.0: 20,
    39.0: 17,
    38.0: 15,
    37.0: 13,
    36.0: 11,
    35.0: 8,
    34.0: 5,
    33.0: 2,
  };
  static final Map<double, int> _datagetNilaiPullUpWanitaGol2 = {
    70.0: 100,
    69.0: 97,
    68.0: 95,
    67.0: 92,
    66.0: 90,
    65.0: 87,
    64.0: 85,
    63.0: 82,
    62.0: 80,
    61.0: 77,
    60.0: 75,
    59.0: 72,
    58.0: 70,
    57.0: 67,
    56.0: 65,
    55.0: 62,
    54.0: 60,
    53.0: 57,
    52.0: 55,
    51.0: 52,
    50.0: 50,
    49.0: 47,
    48.0: 45,
    47.0: 42,
    46.0: 40,
    45.0: 37,
    44.0: 35,
    43.0: 32,
    42.0: 30,
    41.0: 27,
    40.0: 25,
    39.0: 22,
    38.0: 20,
    37.0: 17,
    36.0: 15,
    35.0: 12,
    34.0: 10,
    33.0: 7,
    32.0: 5,
    31.0: 2,
  };
  static final Map<double, int> _datagetNilaiPullUpWanitaGol3 = {
    68.0: 100,
    67.0: 97,
    66.0: 95,
    65.0: 92,
    64.0: 90,
    63.0: 87,
    62.0: 85,
    61.0: 82,
    60.0: 80,
    59.0: 77,
    58.0: 75,
    57.0: 72,
    56.0: 70,
    55.0: 67,
    54.0: 65,
    53.0: 62,
    52.0: 60,
    51.0: 57,
    50.0: 55,
    49.0: 52,
    48.0: 50,
    47.0: 47,
    46.0: 45,
    45.0: 42,
    44.0: 40,
    43.0: 37,
    42.0: 35,
    41.0: 32,
    40.0: 30,
    39.0: 27,
    38.0: 25,
    37.0: 22,
    36.0: 20,
    35.0: 17,
    34.0: 15,
    33.0: 12,
    32.0: 10,
    31.0: 7,
    30.0: 5,
    29.0: 2,
  };
  static final Map<double, int> _datagetNilaiPushUpPriaGol1 = {
    42.0: 100,
    41.0: 97,
    40.0: 94,
    39.0: 91,
    38.0: 88,
    37.0: 85,
    36.0: 82,
    35.0: 79,
    34.0: 76,
    33.0: 73,
    32.0: 70,
    31.0: 67,
    30.0: 64,
    29.0: 61,
    28.0: 58,
    27.0: 55,
    26.0: 52,
    25.0: 50,
    24.0: 48,
    23.0: 46,
    22.0: 44,
    21.0: 42,
    20.0: 40,
    19.0: 38,
    18.0: 36,
    17.0: 34,
    16.0: 32,
    15.0: 29,
    14.0: 26,
    13.0: 23,
    12.0: 21,
    11.0: 19,
    10.0: 17,
    9.0: 15,
    8.0: 13,
    7.0: 11,
    6.0: 9,
    5.0: 7,
    4.0: 6,
  };
  static final Map<double, int> _datagetNilaiPushUpPriaGol2 = {
    36.0: 100,
    35.0: 97,
    34.0: 95,
    33.0: 93,
    32.0: 91,
    31.0: 88,
    30.0: 85,
    29.0: 82,
    28.0: 79,
    27.0: 76,
    26.0: 73,
    25.0: 70,
    24.0: 67,
    23.0: 64,
    22.0: 61,
    21.0: 58,
    20.0: 55,
    19.0: 52,
    18.0: 49,
    17.0: 46,
    16.0: 43,
    15.0: 41,
    14.0: 38,
    13.0: 35,
    12.0: 33,
    11.0: 30,
    10.0: 27,
    9.0: 24,
    8.0: 21,
    7.0: 18,
    6.0: 15,
    5.0: 12,
    4.0: 9,
    3.0: 5,
    2.0: 4,
  };
  static final Map<double, int> _datagetNilaiPushUpPriaGol3 = {
    30.0: 100,
    29.0: 98,
    28.0: 96,
    27.0: 94,
    26.0: 92,
    25.0: 90,
    24.0: 88,
    23.0: 85,
    22.0: 83,
    21.0: 81,
    20.0: 79,
    19.0: 77,
    18.0: 75,
    17.0: 72,
    16.0: 69,
    15.0: 67,
    14.0: 64,
    13.0: 60,
    12.0: 56,
    11.0: 52,
    10.0: 49,
    9.0: 47,
    8.0: 44,
    7.0: 41,
    6.0: 38,
    5.0: 35,
    4.0: 32,
    3.0: 29,
    2.0: 26,
    1.0: 1,
  };
  static final Map<double, int> _datagetNilaiPushUpWanitaGol1 = {
    37.0: 100,
    36.0: 97,
    35.0: 93,
    34.0: 90,
    33.0: 86,
    32.0: 83,
    31.0: 79,
    30.0: 76,
    29.0: 72,
    28.0: 69,
    27.0: 65,
    26.0: 62,
    25.0: 58,
    24.0: 55,
    23.0: 51,
    22.0: 48,
    21.0: 44,
    20.0: 41,
    19.0: 37,
    18.0: 34,
    17.0: 30,
    16.0: 27,
    15.0: 23,
    14.0: 20,
    13.0: 16,
    12.0: 13,
    11.0: 9,
    10.0: 6,
    9.0: 2,
  };
  static final Map<double, int> _datagetNilaiPushUpWanitaGol2 = {
    35.0: 100,
    34.0: 97,
    33.0: 93,
    32.0: 90,
    31.0: 86,
    30.0: 83,
    29.0: 79,
    28.0: 76,
    27.0: 72,
    26.0: 69,
    25.0: 65,
    24.0: 62,
    23.0: 58,
    22.0: 55,
    21.0: 51,
    20.0: 48,
    19.0: 44,
    18.0: 41,
    17.0: 37,
    16.0: 34,
    15.0: 30,
    14.0: 27,
    13.0: 23,
    12.0: 20,
    11.0: 16,
    10.0: 13,
    9.0: 9,
    8.0: 6,
    7.0: 2,
  };
  static final Map<double, int> _datagetNilaiPushUpWanitaGol3 = {
    33.0: 100,
    32.0: 97,
    31.0: 93,
    30.0: 90,
    29.0: 86,
    28.0: 83,
    27.0: 79,
    26.0: 76,
    25.0: 72,
    24.0: 69,
    23.0: 65,
    22.0: 62,
    21.0: 58,
    20.0: 55,
    19.0: 51,
    18.0: 48,
    17.0: 44,
    16.0: 41,
    15.0: 37,
    14.0: 34,
    13.0: 30,
    12.0: 27,
    11.0: 23,
    10.0: 20,
    9.0: 16,
    8.0: 13,
    7.0: 9,
    6.0: 6,
    5.0: 2,
  };
  static final Map<double, int> _datagetNilaiSitUpPriaGol1 = {
    40.0: 100,
    39.0: 96,
    38.0: 92,
    37.0: 88,
    36.0: 84,
    35.0: 80,
    34.0: 76,
    33.0: 72,
    32.0: 68,
    31.0: 64,
    30.0: 60,
    29.0: 56,
    28.0: 52,
    27.0: 48,
    26.0: 44,
    25.0: 41,
    24.0: 38,
    23.0: 35,
    22.0: 32,
    21.0: 30,
    20.0: 28,
    19.0: 26,
    18.0: 24,
    17.0: 22,
    16.0: 20,
    15.0: 18,
    14.0: 16,
    13.0: 14,
    12.0: 12,
    11.0: 10,
    10.0: 8,
    9.0: 6,
    8.0: 4,
    7.0: 2,
    6.0: 1,
  };
  static final Map<double, int> _datagetNilaiSitUpPriaGol2 = {
    34.0: 100,
    33.0: 96,
    32.0: 92,
    31.0: 88,
    30.0: 84,
    29.0: 80,
    28.0: 76,
    27.0: 72,
    26.0: 68,
    25.0: 64,
    24.0: 60,
    23.0: 56,
    22.0: 52,
    21.0: 48,
    20.0: 44,
    19.0: 41,
    18.0: 38,
    17.0: 35,
    16.0: 32,
    15.0: 29,
    14.0: 26,
    13.0: 23,
    12.0: 20,
    11.0: 17,
    10.0: 15,
    9.0: 13,
    8.0: 11,
    7.0: 9,
    6.0: 7,
    5.0: 5,
    4.0: 3,
    3.0: 1,
  };
  static final Map<double, int> _datagetNilaiSitUpPriaGol3 = {
    29.0: 100,
    28.0: 98,
    27.0: 96,
    26.0: 94,
    25.0: 91,
    24.0: 89,
    23.0: 87,
    22.0: 84,
    21.0: 82,
    20.0: 80,
    19.0: 77,
    18.0: 75,
    17.0: 73,
    16.0: 70,
    15.0: 68,
    14.0: 66,
    13.0: 62,
    12.0: 58,
    11.0: 54,
    10.0: 50,
    9.0: 46,
    8.0: 42,
    7.0: 38,
    6.0: 32,
    5.0: 28,
    4.0: 24,
    3.0: 20,
    2.0: 16,
    1.0: 12,
  };
  static final Map<double, int> _datagetNilaiSitUpWanitaGol1 = {
    50.0: 100,
    49.0: 96,
    48.0: 93,
    47.0: 91,
    46.0: 87,
    45.0: 84,
    44.0: 82,
    43.0: 78,
    42.0: 75,
    41.0: 73,
    40.0: 69,
    39.0: 66,
    38.0: 64,
    37.0: 60,
    36.0: 57,
    35.0: 55,
    34.0: 51,
    33.0: 48,
    32.0: 46,
    31.0: 42,
    30.0: 39,
    29.0: 37,
    28.0: 33,
    27.0: 29,
    26.0: 26,
    25.0: 24,
    24.0: 21,
    23.0: 19,
    22.0: 15,
    21.0: 12,
    20.0: 10,
    19.0: 6,
    18.0: 3,
    17.0: 1,
  };
  static final Map<double, int> _datagetNilaiSitUpWanitaGol2 = {
    47.0: 100,
    46.0: 93,
    45.0: 90,
    44.0: 88,
    43.0: 84,
    42.0: 81,
    41.0: 79,
    40.0: 75,
    39.0: 72,
    38.0: 70,
    37.0: 66,
    36.0: 63,
    35.0: 61,
    34.0: 57,
    33.0: 54,
    32.0: 52,
    31.0: 48,
    30.0: 45,
    29.0: 43,
    28.0: 39,
    27.0: 36,
    26.0: 34,
    25.0: 30,
    24.0: 27,
    23.0: 25,
    22.0: 21,
    21.0: 18,
    20.0: 16,
    19.0: 12,
    18.0: 9,
    17.0: 7,
    16.0: 3,
    14.0: 1,
  };
  static final Map<double, int> _datagetNilaiSitUpWanitaGol3 = {
    44.0: 100,
    43.0: 96,
    42.0: 93,
    41.0: 91,
    40.0: 87,
    39.0: 84,
    38.0: 82,
    37.0: 78,
    36.0: 75,
    35.0: 73,
    34.0: 69,
    33.0: 66,
    32.0: 64,
    31.0: 60,
    30.0: 57,
    29.0: 55,
    28.0: 51,
    27.0: 48,
    26.0: 46,
    25.0: 42,
    24.0: 39,
    23.0: 37,
    22.0: 33,
    21.0: 30,
    20.0: 28,
    19.0: 24,
    18.0: 21,
    17.0: 19,
    16.0: 15,
    15.0: 12,
    14.0: 10,
    13.0: 6,
    12.0: 3,
    11.0: 1,
  };
  static final Map<double, int> _datagetNilaiShuttleRunPriaGol1 = {
    16.2: 100,
    16.3: 99,
    16.4: 98,
    16.5: 97,
    16.6: 96,
    16.7: 95,
    16.8: 94,
    16.9: 92,
    17.0: 90,
    17.1: 88,
    17.2: 86,
    17.3: 84,
    17.4: 82,
    17.5: 80,
    17.6: 78,
    17.7: 76,
    17.8: 74,
    17.9: 72,
    18.0: 70,
    18.1: 68,
    18.2: 66,
    18.3: 64,
    18.4: 62,
    18.5: 60,
    18.6: 58,
    18.7: 56,
    18.8: 54,
    18.9: 52,
    19.0: 51,
    19.1: 49,
    19.2: 47,
    19.3: 45,
    19.4: 43,
    19.5: 41,
    19.6: 40,
    19.7: 38,
    19.8: 35,
    19.9: 33,
    20.0: 31,
    20.1: 29,
    20.2: 27,
    20.3: 25,
    20.4: 23,
    20.5: 21,
    20.6: 20,
    20.7: 18,
    20.8: 16,
    20.9: 14,
    21.0: 12,
    21.1: 10,
    21.2: 9,
    21.3: 7,
    23.7: 6,
    23.8: 5,
    23.9: 3,
    24.0: 2,
    24.1: 1,
  };
  static final Map<double, int> _datagetNilaiShuttleRunPriaGol2 = {
    17.0: 100,
    17.1: 99,
    17.2: 98,
    17.3: 96,
    17.4: 95,
    17.5: 94,
    17.6: 92,
    17.7: 91,
    17.8: 90,
    17.9: 88,
    18.0: 87,
    18.1: 86,
    18.2: 84,
    18.3: 83,
    18.4: 82,
    18.5: 80,
    18.6: 79,
    18.7: 78,
    18.8: 76,
    18.9: 75,
    19.0: 74,
    19.1: 72,
    19.2: 71,
    19.3: 70,
    19.4: 68,
    19.5: 67,
    19.6: 66,
    19.7: 64,
    19.8: 63,
    19.9: 62,
    20.0: 60,
    20.1: 59,
    20.2: 58,
    20.3: 56,
    20.4: 55,
    20.5: 54,
    20.6: 52,
    20.7: 51,
    20.8: 50,
    20.9: 48,
    21.0: 47,
    21.1: 45,
    21.2: 44,
    21.3: 42,
    21.4: 41,
    21.5: 39,
    21.6: 38,
    21.7: 36,
    21.8: 35,
    21.9: 33,
    22.0: 32,
    22.1: 30,
    22.2: 29,
    22.3: 27,
    22.4: 26,
    22.5: 24,
    22.6: 23,
    22.7: 21,
    22.8: 20,
    22.9: 18,
    23.0: 17,
    23.1: 15,
    23.2: 14,
    23.3: 12,
    23.4: 11,
    25.5: 9,
    25.6: 8,
  };
  static final Map<double, int> _datagetNilaiShuttleRunPriaGol3 = {
    18.2: 100,
    18.3: 99,
    18.4: 98,
    18.5: 97,
    18.6: 96,
    18.7: 94,
    18.8: 93,
    18.9: 92,
    19.0: 91,
    19.1: 90,
    19.2: 89,
    19.3: 87,
    19.4: 86,
    19.5: 85,
    19.6: 84,
    19.7: 83,
    19.8: 82,
    19.9: 80,
    20.0: 79,
    20.1: 78,
    20.2: 77,
    20.3: 76,
    20.4: 75,
    20.5: 74,
    20.6: 73,
    20.7: 72,
    20.9: 71,
    21.0: 70,
    21.1: 69,
    21.2: 68,
    21.3: 67,
    21.4: 66,
    21.5: 65,
    21.6: 64,
    21.7: 63,
    21.8: 62,
    21.9: 61,
    22.1: 60,
    22.2: 59,
    22.3: 58,
    22.4: 57,
    22.5: 56,
    22.6: 55,
    22.7: 54,
    22.8: 53,
    22.9: 52,
    23.1: 51,
    23.2: 50,
    23.3: 49,
    23.4: 48,
    23.5: 47,
    23.6: 46,
    23.7: 45,
    23.8: 44,
    23.9: 43,
    24.0: 42,
    24.2: 41,
    24.3: 40,
    24.4: 39,
    24.5: 38,
    24.6: 37,
    24.7: 36,
    24.8: 35,
    24.9: 34,
    25.0: 33,
    25.1: 32,
    25.3: 31,
    25.4: 30,
    25.5: 29,
    25.6: 28,
    25.7: 27,
    25.8: 26,
    25.9: 25,
    26.0: 24,
    26.1: 23,
    26.2: 22,
    26.3: 21,
    26.4: 20,
    26.5: 19,
    26.6: 18,
    26.7: 17,
    26.8: 16,
    26.9: 15,
  };
  static final Map<double, int> _datagetNilaiShuttleRunWanitaGol1 = {
    17.6: 100,
    17.7: 99,
    17.8: 98,
    17.9: 97,
    18.0: 96,
    18.1: 95,
    18.2: 94,
    18.3: 93,
    18.4: 92,
    18.5: 91,
    18.6: 90,
    18.7: 89,
    18.8: 88,
    18.9: 87,
    19.0: 86,
    19.1: 85,
    19.2: 84,
    19.3: 83,
    19.4: 82,
    19.5: 81,
    19.6: 80,
    19.7: 79,
    19.8: 78,
    19.9: 77,
    20.0: 76,
    20.1: 75,
    20.2: 74,
    20.3: 73,
    20.4: 72,
    20.5: 71,
    20.6: 70,
    20.7: 69,
    20.8: 68,
    20.9: 67,
    21.0: 66,
    21.1: 65,
    21.2: 64,
    21.3: 63,
    21.4: 62,
    21.5: 61,
    21.6: 60,
    21.7: 59,
    21.8: 58,
    21.9: 57,
    22.0: 56,
    22.1: 55,
    22.2: 54,
    22.3: 53,
    22.4: 52,
    22.5: 51,
    22.6: 50,
    22.7: 49,
    22.8: 48,
    22.9: 47,
    23.0: 46,
    23.1: 45,
    23.2: 44,
    23.3: 43,
    23.4: 42,
    23.5: 41,
    23.6: 40,
    23.7: 39,
    23.8: 38,
    23.9: 37,
    24.0: 36,
    24.1: 35,
    24.2: 34,
    24.3: 33,
    24.4: 32,
    24.5: 31,
    24.6: 30,
    24.7: 29,
    24.8: 28,
    24.9: 27,
    25.0: 26,
    25.1: 25,
    25.2: 24,
    25.3: 23,
    25.4: 22,
    25.5: 21,
    25.6: 20,
    25.7: 19,
    25.8: 18,
    25.9: 17,
    26.0: 16,
    26.1: 15,
    26.2: 14,
    26.3: 13,
    26.4: 12,
    26.5: 11,
    26.6: 10,
    26.7: 9,
    26.8: 8,
    26.9: 7,
    27.0: 6,
    27.1: 5,
    27.2: 4,
    27.3: 3,
    27.4: 2,
    27.5: 1,
  };
  static final Map<double, int> _datagetNilaiShuttleRunWanitaGol2 = {
    18.4: 100,
    18.5: 99,
    18.6: 98,
    18.7: 97,
    18.8: 96,
    18.9: 95,
    19.0: 94,
    19.1: 93,
    19.2: 92,
    19.3: 91,
    19.4: 90,
    19.5: 89,
    19.6: 88,
    19.7: 87,
    19.8: 86,
    19.9: 85,
    20.0: 84,
    20.1: 83,
    20.2: 82,
    20.3: 81,
    20.4: 80,
    20.5: 79,
    20.6: 78,
    20.7: 77,
    20.8: 76,
    20.9: 75,
    21.0: 74,
    21.1: 73,
    21.2: 72,
    21.3: 71,
    21.4: 70,
    21.5: 69,
    21.6: 68,
    21.7: 67,
    21.8: 66,
    21.9: 65,
    22.0: 64,
    22.1: 63,
    22.2: 62,
    22.3: 61,
    22.4: 60,
    22.5: 59,
    22.6: 58,
    22.7: 57,
    22.8: 56,
    22.9: 55,
    23.0: 54,
    23.1: 53,
    23.2: 52,
    23.3: 51,
    23.4: 50,
    23.5: 49,
    23.6: 48,
    23.7: 47,
    23.8: 46,
    23.9: 45,
    24.0: 44,
    24.1: 43,
    24.2: 42,
    24.3: 41,
    24.4: 40,
    24.5: 39,
    24.6: 38,
    24.7: 37,
    24.8: 36,
    24.9: 35,
    25.0: 34,
    25.1: 33,
    25.2: 32,
    25.3: 31,
    25.4: 30,
    25.5: 29,
    25.6: 28,
    25.7: 27,
    25.8: 26,
    28.9: 5,
    26.0: 24,
    26.1: 23,
    26.2: 22,
    26.3: 21,
    26.4: 20,
    26.5: 19,
    26.6: 18,
    26.7: 17,
    26.8: 16,
    26.9: 15,
    27.0: 14,
    27.1: 13,
    27.2: 12,
    27.3: 11,
    27.4: 10,
    27.5: 9,
    27.6: 8,
    27.7: 7,
    27.8: 6,
    28.0: 4,
    28.1: 3,
    28.2: 2,
    28.3: 1,
  };
  static final Map<double, int> _datagetNilaiShuttleRunWanitaGol3 = {
    19.2: 100,
    19.3: 99,
    19.4: 98,
    19.5: 97,
    19.6: 96,
    19.7: 95,
    19.8: 94,
    19.9: 93,
    20.0: 92,
    20.1: 91,
    20.2: 90,
    20.3: 89,
    20.4: 88,
    20.5: 87,
    20.6: 86,
    20.7: 85,
    20.8: 84,
    20.9: 83,
    21.0: 82,
    21.1: 81,
    21.2: 80,
    21.3: 79,
    21.4: 78,
    21.5: 77,
    21.6: 76,
    21.7: 75,
    21.8: 74,
    21.9: 73,
    22.0: 72,
    22.1: 71,
    22.2: 70,
    22.3: 69,
    22.4: 68,
    22.5: 67,
    22.6: 66,
    22.7: 65,
    22.8: 64,
    22.9: 63,
    23.0: 62,
    23.1: 61,
    23.2: 60,
    23.3: 59,
    23.4: 58,
    23.5: 57,
    23.6: 56,
    23.7: 55,
    23.8: 54,
    23.9: 53,
    24.0: 52,
    24.1: 51,
    24.2: 50,
    24.3: 49,
    24.4: 48,
    24.5: 47,
    24.6: 46,
    24.7: 45,
    24.8: 44,
    24.9: 43,
    25.0: 42,
    25.1: 41,
    25.2: 40,
    25.3: 39,
    25.4: 38,
    25.5: 37,
    25.6: 36,
    25.7: 35,
    25.8: 34,
    25.9: 33,
    26.0: 32,
    26.1: 31,
    26.2: 30,
    26.3: 29,
    26.4: 28,
    26.5: 27,
    26.6: 26,
    26.7: 25,
    26.8: 24,
    26.9: 23,
    27.0: 22,
    27.1: 21,
    27.2: 20,
    27.3: 19,
    27.4: 18,
    27.5: 17,
    27.6: 16,
    27.7: 15,
    27.8: 14,
    27.9: 13,
    28.0: 12,
    28.1: 11,
    28.2: 10,
    28.3: 9,
    28.4: 8,
    28.5: 7,
    28.6: 6,
    28.7: 5,
    28.8: 4,
    28.9: 3,
    29.0: 2,
    29.1: 1,
  };
}
