import 'package:flutter/material.dart';
import 'package:sespimma_mobile/core/utils/icon_mapper.dart';

class EvidenceBottomSheet {
  static void show(
    BuildContext context, {
    required String title,
    required String description,
    required String evaluatorName,
    required String timeText,
    required String points,
    required String type,
  }) {
    final bool isReward = type == 'reward';

    final String cleanTitle = title
        .replaceAll(RegExp(r'^Reward:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^Punishment:\s*', caseSensitive: false), '')
        .trim();

    String detailTitle = isReward ? "Bukti Penghargaan" : "Bukti Pelanggaran";
    String imageUrl = "assets/images/images.jpeg";
    bool isLocalAsset = true;

    if (isReward) {
      if (cleanTitle.toLowerCase().contains("imam")) {
        imageUrl = "assets/images/kheldoun-imad-IqsenI0kT1I-unsplash.jpg";
      } else {
        imageUrl =
            "https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&q=80&w=800";
        isLocalAsset = false;
      }
    }

    final Color mainColor = isReward
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mainColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isReward ? AppIcons.thumbUp : AppIcons.thumbDown,
                    color: mainColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detailTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cleanTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF001C40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildPopupInfoRow("Waktu", timeText),
            const SizedBox(height: 12),
            _buildPopupInfoRow("Oleh", evaluatorName),
            if (points.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPopupInfoRow(
                "Dampak Skor",
                points,
                valueColor: mainColor,
                isBold: true,
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              "Keterangan Justifikasi",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF001C40),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bukti Gambar",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF001C40),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: isLocalAsset
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppIcons.image,
                                    color: Colors.blueGrey.shade300,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Gagal memuat gambar bukti",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, chunk) {
                          if (chunk == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, err, stack) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AppIcons.image,
                                    color: Colors.blueGrey.shade300,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Gagal memuat gambar bukti",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001C40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "TUTUP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPopupInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade400,
            ),
          ),
        ),
        const Text(" :   ", style: TextStyle(color: Colors.blueGrey)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? const Color(0xFF001C40),
            ),
          ),
        ),
      ],
    );
  }
}
