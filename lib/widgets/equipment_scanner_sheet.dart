import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../models/rental.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

enum ScannerMode {
  lookup,
  rentalReturn,
  assignBarcode,
}

class EquipmentScannerSheet extends StatefulWidget {
  final ScannerMode mode;
  final Rental? rental;
  final String? targetItemName;
  final ValueChanged<String>? onBarcodeDetected;

  const EquipmentScannerSheet({
    super.key,
    this.mode = ScannerMode.lookup,
    this.rental,
    this.targetItemName,
    this.onBarcodeDetected,
  });

  static Future<String?> show(
    BuildContext context, {
    ScannerMode mode = ScannerMode.lookup,
    Rental? rental,
    String? targetItemName,
    ValueChanged<String>? onBarcodeDetected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EquipmentScannerSheet(
        mode: mode,
        rental: rental,
        targetItemName: targetItemName,
        onBarcodeDetected: onBarcodeDetected,
      ),
    );
  }

  @override
  State<EquipmentScannerSheet> createState() => _EquipmentScannerSheetState();
}

class _EquipmentScannerSheetState extends State<EquipmentScannerSheet> {
  late MobileScannerController _controller;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  String? _statusMessage;
  bool _statusIsSuccess = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final code = rawValue.trim();

    // Prevent immediate rapid repeated scans of same code within 1.5 seconds
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 1500) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    HapticFeedback.mediumImpact();
    _processScannedCode(code);
  }

  void _processScannedCode(String code) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    if (widget.mode == ScannerMode.rentalReturn && widget.rental != null) {
      final success = provider.verifyRentalItemReturn(widget.rental!.id, code);
      final item = provider.findInventoryItemByCode(code);
      final itemName = item?.name ?? 'Code $code';

      setState(() {
        if (success) {
          _statusMessage = '✓ $itemName verified!';
          _statusIsSuccess = true;
        } else {
          final alreadyVerified = item != null &&
              widget.rental!.inventoryItemIds.contains(item.id) &&
              provider.rentals
                  .firstWhere((r) => r.id == widget.rental!.id)
                  .verifiedReturnItemIds
                  .contains(item.id);

          if (alreadyVerified) {
            _statusMessage = '$itemName is already verified.';
            _statusIsSuccess = true;
          } else {
            _statusMessage = 'Item not part of this rental: $itemName';
            _statusIsSuccess = false;
          }
        }
      });

      widget.onBarcodeDetected?.call(code);
    } else if (widget.mode == ScannerMode.assignBarcode) {
      widget.onBarcodeDetected?.call(code);
      Navigator.of(context).pop(code);
    } else {
      // Lookup mode
      final item = provider.findInventoryItemByCode(code);
      if (item != null) {
        setState(() {
          _statusMessage = 'Found: ${item.name} (${item.rentalStatus})';
          _statusIsSuccess = true;
        });
        widget.onBarcodeDetected?.call(code);
      } else {
        setState(() {
          _statusMessage = 'No gear found for: $code';
          _statusIsSuccess = false;
        });
      }
    }
  }

  void _showManualInputDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Code Manually'),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Barcode, serial number, or item ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
            ),
            onPressed: () {
              final val = textCtrl.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(ctx).pop();
                _processScannedCode(val);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final rental = widget.rental != null
        ? provider.rentals.firstWhere(
            (r) => r.id == widget.rental!.id,
            orElse: () => widget.rental!,
          )
        : null;

    final height = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Camera viewfinder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 54, color: Colors.white70),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera Access Required',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enable camera permissions to scan gear barcodes directly. (${error.errorCode.name})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showManualInputDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Enter Code Manually'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // High-contrast viewfinder scan frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner accent brackets
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: StitchTheme.primary, width: 4),
                          left: BorderSide(color: StitchTheme.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: StitchTheme.primary, width: 4),
                          right: BorderSide(color: StitchTheme.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: StitchTheme.primary, width: 4),
                          left: BorderSide(color: StitchTheme.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: StitchTheme.primary, width: 4),
                          right: BorderSide(color: StitchTheme.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    widget.mode == ScannerMode.rentalReturn
                        ? 'RENTAL RETURN SCAN'
                        : (widget.mode == ScannerMode.assignBarcode
                            ? 'SCAN GEAR BARCODE'
                            : 'EQUIPMENT LOOKUP'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: _isTorchOn ? Colors.amber : Colors.white,
                      ),
                      onPressed: () async {
                        await _controller.toggleTorch();
                        setState(() => _isTorchOn = !_isTorchOn);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                      onPressed: () async {
                        await _controller.switchCamera();
                        setState(() => _isFrontCamera = !_isFrontCamera);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rental Return Checklist Drawer (if in rentalReturn mode)
          if (widget.mode == ScannerMode.rentalReturn && rental != null)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            rental.customerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: rental.isFullyVerified
                                ? StitchTheme.success.withValues(alpha: 0.2)
                                : Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${rental.verifiedCount} / ${rental.totalCount} VERIFIED',
                            style: TextStyle(
                              color: rental.isFullyVerified ? StitchTheme.success : Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Item chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: rental.inventoryItemIds.map((itemId) {
                        final item = provider.inventory.firstWhere(
                          (i) => i.id == itemId,
                          orElse: () => InventoryItem(id: itemId, name: 'Item', category: ''),
                        );
                        final isVerified = rental.isItemVerified(itemId);
                        return InkWell(
                          onTap: () {
                            provider.toggleRentalItemVerified(rental.id, itemId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? StitchTheme.success.withValues(alpha: 0.25)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isVerified ? StitchTheme.success : Colors.white24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified ? Icons.check_circle : Icons.radio_button_unchecked,
                                  size: 14,
                                  color: isVerified ? StitchTheme.success : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: isVerified ? Colors.white : Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Control & Status Floating Bar
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live status feedback message
                if (_statusMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusIsSuccess
                          ? StitchTheme.success.withValues(alpha: 0.9)
                          : StitchTheme.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIsSuccess ? Icons.check_circle : Icons.warning_amber,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _statusMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Controls row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.keyboard, color: Colors.white, size: 18),
                        label: const Text('Enter Code', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _showManualInputDialog,
                      ),
                    ),
                    if (widget.mode == ScannerMode.rentalReturn && rental != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_turned_in, size: 18),
                          label: Text(
                            rental.isFullyVerified ? 'Complete Return' : 'Return (${rental.verifiedCount}/${rental.totalCount})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rental.isFullyVerified
                                ? StitchTheme.success
                                : StitchTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            provider.completeRental(rental.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rental for ${rental.customerName} marked as Returned!'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
