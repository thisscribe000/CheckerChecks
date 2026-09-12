import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import '../widgets/equipment_scanner_sheet.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _serialController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Cameras';
  int _quantity = 1;

  final List<String> _categories = [
    'Cameras',
    'Lenses',
    'Audio',
    'Lighting',
    'Power',
    'Accessories',
    'Tools',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _serialController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.addInventoryItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: _quantity,
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        serialNumber: _serialController.text.trim().isNotEmpty ? _serialController.text.trim() : null,
        barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added to Inventory'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inventory Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name
              Text('ITEM NAME', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary),
                decoration: InputDecoration(
                  hintText: 'e.g. Sony A7 IV or 50mm Lens',
                  hintStyle: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.outline),
                  filled: true,
                  fillColor: StitchTheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.primary, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category
              Text('CATEGORY', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: StitchTheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.primary, width: 1.5),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Quantity Stepper
              Text('QUANTITY', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: StitchTheme.cardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_quantity',
                      style: StitchTheme.headlineMd(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _quantity > 1
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Optional Brand & Serial
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BRAND (OPTIONAL)', style: StitchTheme.labelCaps(context)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _brandController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sony, Canon',
                            filled: true,
                            fillColor: StitchTheme.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SERIAL / SPECS', style: StitchTheme.labelCaps(context)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _serialController,
                          decoration: InputDecoration(
                            hintText: 'e.g. SN: 94021A',
                            filled: true,
                            fillColor: StitchTheme.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barcode / QR Code Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('BARCODE / QR TAG (OPTIONAL)', style: StitchTheme.labelCaps(context)),
                  TextButton.icon(
                    onPressed: () async {
                      final scanned = await EquipmentScannerSheet.show(
                        context,
                        mode: ScannerMode.assignBarcode,
                      );
                      if (scanned != null) {
                        setState(() {
                          _barcodeController.text = scanned;
                        });
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: const Text('Scan with Camera'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _barcodeController,
                style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary),
                decoration: InputDecoration(
                  hintText: 'e.g. 012345678905 or custom QR code',
                  hintStyle: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.outline),
                  filled: true,
                  fillColor: StitchTheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: 'Scan with Camera',
                    onPressed: () async {
                      final scanned = await EquipmentScannerSheet.show(
                        context,
                        mode: ScannerMode.assignBarcode,
                      );
                      if (scanned != null) {
                        setState(() {
                          _barcodeController.text = scanned;
                        });
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes
              Text('NOTES (OPTIONAL)', style: StitchTheme.labelCaps(context)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Needs lens caps replaced or stored in Case B',
                  filled: true,
                  fillColor: StitchTheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchTheme.primary,
                    foregroundColor: StitchTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Save Item',
                    style: StitchTheme.headlineMd(context).copyWith(
                      color: StitchTheme.onPrimary,
                      fontSize: 16,
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
}
