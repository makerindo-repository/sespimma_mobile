import 'package:sespimma_mobile/features/auth/data/datasources/serdik_real_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/patun_real_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/korsis_real_data.dart';
import 'package:sespimma_mobile/features/auth/data/datasources/gadik_real_data.dart';
import 'package:sespimma_mobile/core/constants/reward_punishment_data.dart';

class InboxItem {
  final String id;
  final String serdikName;
  final String pangkat;
  final String nosis;
  final String pokjar;
  final bool isReward;
  final String senderName;
  final DateTime timestamp;
  final double points;
  final String description;
  final String rewardPunishmentName;
  String status;
  final String? photoPath;
  final String? rewardPunishmentId;

  InboxItem({
    required this.id,
    required this.serdikName,
    required this.pangkat,
    required this.nosis,
    required this.pokjar,
    required this.isReward,
    required this.senderName,
    required this.timestamp,
    required this.points,
    required this.description,
    required this.rewardPunishmentName,
    this.status = 'pending',
    this.photoPath,
    this.rewardPunishmentId,
  });
}

class KorsisInboxMockData {
  KorsisInboxMockData._();

  static List<InboxItem>? _items;

  static List<InboxItem> get items {
    _items ??= _generateInitialData();
    return _items!;
  }

  static List<InboxItem> generateMockData() => items;

  static void addRecord(InboxItem item) {
    items.insert(0, item);
  }

  static void reset() {
    _items = null;
  }

  static List<InboxItem> _generateInitialData() {
    final now = DateTime.now();
    final List<InboxItem> result = [];

    final serdiks = SerdikRealData.records.toList();
    final patuns = PatunRealData.records;
    final korsis = KorsisRealData.records;
    final gadiks = GadikRealData.records;
    final rules = RewardPunishmentData.rules;

    final senders = [
      ...patuns.map((p) => p['nama'] as String),
      ...korsis.map((k) => k['nama'] as String),
      ...gadiks.map((g) => g['nama'] as String),
    ];

    final rewardRules = rules.where((r) => r.type == 'REWARD').toList();
    final punishmentRules = rules.where((r) => r.type == 'PUNISHMENT').toList();

    for (int i = 0; i < serdiks.length; i++) {
      final serdik = serdiks[i];
      final isReward = i % 2 == 0;
      final rule = isReward
          ? rewardRules[i % rewardRules.length]
          : punishmentRules[i % punishmentRules.length];

      final timestamp = now.subtract(Duration(hours: i * 3, minutes: i * 22));
      final senderName = senders[i % senders.length];

        result.add(
          InboxItem(
            id: 'mock_inbox_$i',
            serdikName: serdik['nama_lengkap'] ?? '-',
            pangkat: serdik['pangkat'] ?? '-',
            nosis: serdik['no_serdik'] ?? '-',
            pokjar: serdik['kelompok_kelas'] ?? '-',
            isReward: isReward,
            senderName: senderName,
            timestamp: timestamp,
            points: rule.point,
            description:
                'Telah dilakukan observasi dan pencatatan oleh '
                'pengasuh terkait kedisiplinan dan kinerja serdik.',
            rewardPunishmentName: rule.description,
            status: i < 5 ? 'Setuju' : 'pending', // First 5 items are approved for demo
            rewardPunishmentId: rule.id,
          ),
        );
    }

    return result;
  }
}
