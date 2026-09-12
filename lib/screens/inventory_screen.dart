import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import 'add_inventory_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';

  final List<String> _categoryFilters = [
    'All',
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
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categoryCounts = provider.getCategoryCounts();
    final inventory = provider.inventory;

    final filteredItems = inventory.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.brand != null && item.brand!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (item.serialNumber != null && item.serialNumber!.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = _selectedCategoryFilter == 'All' ||
          item.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary),
                  decoration: InputDecoration(
                    hintText: 'Search gear...',
                    hintStyle: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.outline),
                    prefixIcon: const Icon(Icons.search, size: 20, color: StitchTheme.onSurfaceVariant),
                    filled: true,
                    fillColor: StitchTheme.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: StitchTheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: StitchTheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Summary Pills Horizontal Scroll
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryFilters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categoryFilters[index];
                      final isSelected = _selectedCategoryFilter == cat;
                      final count = cat == 'All'
                          ? inventory.fold(0, (sum, i) => sum + i.quantity)
                          : (categoryCounts[cat] ?? 0);

                      return FilterChip(
                        selected: isSelected,
                        label: Text('$cat · $count'),
                        labelStyle: StitchTheme.labelCaps(context).copyWith(
                          color: isSelected ? StitchTheme.onPrimary : StitchTheme.primary,
                        ),
                        backgroundColor: StitchTheme.surfaceContainerLowest,
                        selectedColor: StitchTheme.primary,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? StitchTheme.primary : StitchTheme.outlineVariant,
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryFilter = cat;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: StitchTheme.outlineVariant),

          // Inventory List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: StitchTheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No inventory items found',
                          style: StitchTheme.headlineMd(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + Add Item to add gear to your library',
                          style: StitchTheme.bodyLg(context),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () => _showItemActionsSheet(context, provider, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: StitchTheme.cardDecoration,
                          child: Row(
                            children: [
                              // Category Icon Box
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: StitchTheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: StitchTheme.outlineVariant),
                                ),
                                child: Icon(
                                  _getCategoryIcon(item.category),
                                  color: StitchTheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Item Name & Category / Brand
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: StitchTheme.headlineMd(context).copyWith(fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.category} ${item.brand != null ? '• ${item.brand}' : ''} ${item.serialNumber != null ? '• ${item.serialNumber}' : ''}',
                                      style: StitchTheme.monoSm(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity & Rental Badge
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (item.rentalStatus == 'Rented Out') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: StitchTheme.warningContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'RENTED OUT',
                                        style: StitchTheme.labelCaps(context).copyWith(
                                          color: StitchTheme.warning,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: StitchTheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Qty: ${item.quantity}',
                                      style: StitchTheme.labelCaps(context).copyWith(color: StitchTheme.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
          );
        },
        backgroundColor: StitchTheme.primary,
        foregroundColor: StitchTheme.onPrimary,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: Text(
          'ADD ITEM',
          style: StitchTheme.labelCaps(context).copyWith(color: StitchTheme.onPrimary),
        ),
      ),
    );
  }

  void _showItemActionsSheet(BuildContext context, AppProvider provider, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: StitchTheme.headlineLg(context).copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} ${item.brand != null ? '· ${item.brand}' : ''}',
                          style: StitchTheme.bodyMd(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: StitchTheme.cardDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: item.quantity > 1
                              ? () {
                                  provider.updateInventoryItem(
                                    id: item.id,
                                    name: item.name,
                                    category: item.category,
                                    quantity: item.quantity - 1,
                                    brand: item.brand,
                                    notes: item.notes,
                                    serialNumber: item.serialNumber,
                                  );
                                  setModalState(() {});
                                }
                              : null,
                        ),
                        Text('${item.quantity}', style: StitchTheme.headlineMd(context).copyWith(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            provider.updateInventoryItem(
                              id: item.id,
                              name: item.name,
                              category: item.category,
                              quantity: item.quantity + 1,
                              brand: item.brand,
                              notes: item.notes,
                              serialNumber: item.serialNumber,
                            );
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.serialNumber != null || item.notes != null) ...[
                const SizedBox(height: 12),
                if (item.serialNumber != null)
                  Text('Serial / Specs: ${item.serialNumber}', style: StitchTheme.monoSm(context)),
                if (item.notes != null) ...[
                  const SizedBox(height: 4),
                  Text('Notes: ${item.notes}', style: StitchTheme.bodyMd(context)),
                ],
              ],
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showEditItemDialog(context, provider, item);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StitchTheme.primary,
                        side: const BorderSide(color: StitchTheme.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _confirmDeleteItem(context, provider, item);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18, color: StitchTheme.error),
                      label: const Text('Delete', style: TextStyle(color: StitchTheme.error)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StitchTheme.error,
                        side: const BorderSide(color: StitchTheme.errorContainer),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, AppProvider provider, dynamic item) {
    final nameCtrl = TextEditingController(text: item.name);
    final brandCtrl = TextEditingController(text: item.brand ?? '');
    final serialCtrl = TextEditingController(text: item.serialNumber ?? '');
    final notesCtrl = TextEditingController(text: item.notes ?? '');
    String category = item.category;
    int quantity = item.quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Item', style: StitchTheme.headlineLg(context).copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                Text('NAME', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: _inputDec('Item name'),
                ),
                const SizedBox(height: 14),
                Text('CATEGORY', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _categoryFilters.contains(category) && category != 'All' ? category : 'Other',
                  decoration: _inputDec('Category'),
                  items: _categoryFilters
                      .where((c) => c != 'All')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => category = v);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BRAND', style: StitchTheme.labelCaps(context)),
                          const SizedBox(height: 6),
                          TextField(controller: brandCtrl, decoration: _inputDec('e.g. Sony')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SERIAL / SPECS', style: StitchTheme.labelCaps(context)),
                          const SizedBox(height: 6),
                          TextField(controller: serialCtrl, decoration: _inputDec('SN / Spec')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('NOTES', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 6),
                TextField(controller: notesCtrl, maxLines: 2, decoration: _inputDec('Notes')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      provider.updateInventoryItem(
                        id: item.id,
                        name: name,
                        category: category,
                        quantity: quantity,
                        brand: brandCtrl.text.trim().isNotEmpty ? brandCtrl.text.trim() : null,
                        serialNumber: serialCtrl.text.trim().isNotEmpty ? serialCtrl.text.trim() : null,
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                      );
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchTheme.primary,
                      foregroundColor: StitchTheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, AppProvider provider, dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StitchTheme.surfaceContainerLowest,
        title: Text('Delete "${item.name}"?', style: StitchTheme.headlineMd(context)),
        content: Text(
          'This will remove this item from your inventory and mark it as missing on any upcoming gig checklists.',
          style: StitchTheme.bodyLg(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteInventoryItem(item.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${item.name}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: StitchTheme.outline),
        filled: true,
        fillColor: StitchTheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
      );

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cameras':
        return Icons.photo_camera_outlined;
      case 'lenses':
        return Icons.camera_outlined;
      case 'audio':
        return Icons.mic_none_outlined;
      case 'lighting':
        return Icons.lightbulb_outline;
      case 'power':
        return Icons.battery_charging_full_outlined;
      case 'accessories':
        return Icons.sd_storage_outlined;
      case 'tools':
        return Icons.construction_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
