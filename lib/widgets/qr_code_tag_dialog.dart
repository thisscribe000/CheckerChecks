import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/inventory_item.dart';
import '../theme/stitch_theme.dart';

class QrCodeTagDialog extends StatelessWidget {
  final InventoryItem item;

  const QrCodeTagDialog({super.key, required this.item});

  static void show(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (_) => QrCodeTagDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = item.primaryCode;

    return AlertDialog(
      backgroundColor: StitchTheme.surfaceContainerLowest,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Equipment QR Tag', style: StitchTheme.headlineLg(context).copyWith(fontSize: 18)),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Physical Sticker Preview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App branding header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CHECKERCHECKS GEAR TAG',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black12, height: 16),

                  // High-contrast QR Code
                  Center(
                    child: QrImageView(
                      data: code,
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gear Details on label
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (item.brand != null && item.brand!.isNotEmpty)
                    Text(
                      item.brand!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'TAG: $code',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Attach this tag to your camera body, lens, or flight case. Point the inline scanner at this QR code to instantly verify equipment returns.',
              textAlign: TextAlign.center,
              style: StitchTheme.bodyMd(context).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy Tag Code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: StitchTheme.primary,
            foregroundColor: StitchTheme.onPrimary,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tag code "$code" copied to clipboard!')),
            );
          },
        ),
      ],
    );
  }
}
