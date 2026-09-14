import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

class ClientBookingSheet extends StatefulWidget {
  const ClientBookingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ClientBookingSheet(),
    );
  }

  @override
  State<ClientBookingSheet> createState() => _ClientBookingSheetState();
}

class _ClientBookingSheetState extends State<ClientBookingSheet> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _projectController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(const Duration(days: 2));

  final Set<String> _selectedItemIds = {};
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _projectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _returnDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_returnDate.isBefore(_startDate)) {
            _returnDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final availableGear = provider.availableInventory;
    final studioName = provider.userName.isNotEmpty ? provider.userName : 'CheckerChecks Studio';

    // Categories
    final categories = ['All', ...{...availableGear.map((i) => i.category)}];
    final displayedGear = _selectedCategory == 'All'
        ? availableGear
        : availableGear.where((i) => i.category == _selectedCategory).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: StitchTheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Client Mode Badge
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StitchTheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, size: 14, color: Colors.blue.shade900),
                          const SizedBox(width: 4),
                          Text(
                            'CLIENT PORTAL PREVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Studio Banner
                    Text(
                      'Book Gear with $studioName',
                      style: StitchTheme.headlineMd(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select the equipment you need, choose your dates, and submit your request.',
                      style: StitchTheme.bodySm(context).copyWith(color: StitchTheme.outline),
                    ),
                    const SizedBox(height: 20),

                    // 1. SELECT GEAR SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1. SELECT EQUIPMENT', style: StitchTheme.labelCaps(context)),
                        Text(
                          '${_selectedItemIds.length} of ${availableGear.length} selected',
                          style: StitchTheme.bodySm(context).copyWith(
                            color: _selectedItemIds.isNotEmpty ? StitchTheme.primary : StitchTheme.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              selectedColor: StitchTheme.primary.withValues(alpha: 0.15),
                              checkmarkColor: StitchTheme.primary,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? StitchTheme.primary : StitchTheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Gear List
                    if (displayedGear.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: StitchTheme.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No available equipment in this category right now.',
                            style: StitchTheme.bodySm(context).copyWith(color: StitchTheme.outline),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: StitchTheme.surfaceContainerHigh.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: StitchTheme.outline.withValues(alpha: 0.2)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedGear.length,
                          separatorBuilder: (ctx, idx) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = displayedGear[index];
                            final isChecked = _selectedItemIds.contains(item.id);

                            return CheckboxListTile(
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedItemIds.add(item.id);
                                  } else {
                                    _selectedItemIds.remove(item.id);
                                  }
                                });
                              },
                              activeColor: StitchTheme.primary,
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: StitchTheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                '${item.category}${item.brand != null ? ' • ${item.brand}' : ''}${item.serialNumber != null ? ' • SN: ${item.serialNumber}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: StitchTheme.outline,
                                ),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? StitchTheme.primary.withValues(alpha: 0.1)
                                      : StitchTheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(item.category),
                                  size: 20,
                                  color: isChecked ? StitchTheme.primary : StitchTheme.outline,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // 2. DATES SECTION
                    Text('2. RENTAL DATES', style: StitchTheme.labelCaps(context)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: StitchTheme.outline.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PICKUP DATE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: StitchTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: StitchTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(_startDate),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: StitchTheme.outline.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RETURN DATE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: StitchTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.event_available, size: 14, color: StitchTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(_returnDate),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. CLIENT INFO
                    Text('3. CLIENT INFORMATION', style: StitchTheme.labelCaps(context)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Full Name *',
                        hintText: 'e.g. Elena Fisher',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Email or Phone Number *',
                        hintText: 'e.g. elena@production.com / +1 (555) 019-2834',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.contact_phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _projectController,
                      decoration: InputDecoration(
                        labelText: 'Project / Shoot Name (Optional)',
                        hintText: 'e.g. Commercial Shoot or Wedding Doc',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.movie_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Special Requests / Notes (Optional)',
                        hintText: 'e.g. Extra batteries needed, morning pickup',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitRequest(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StitchTheme.primary,
                          foregroundColor: StitchTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Submit Rental Request',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitRequest(AppProvider provider) {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty) {
      _showToast('Please enter your full name');
      return;
    }
    if (contact.isEmpty) {
      _showToast('Please enter an email or phone number');
      return;
    }
    if (_selectedItemIds.isEmpty) {
      _showToast('Please select at least 1 gear item to rent');
      return;
    }

    final newRequest = provider.receiveRentalRequest(
      customerName: name,
      customerContact: contact,
      startDate: _formatDate(_startDate),
      expectedReturnDate: _formatDate(_returnDate),
      inventoryItemIds: _selectedItemIds.toList(),
      projectShootName: _projectController.text.trim().isNotEmpty
          ? _projectController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      bookingSource: 'link',
    );

    Navigator.of(context).pop();

    // Show Success Dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, size: 36, color: Colors.green.shade800),
        ),
        title: const Text('Rental Request Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you, $name! Your request has landed in the owner\'s "Requests" queue for confirmation.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ${_selectedItemIds.length} items requested', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('• Pickup: ${_formatDate(_startDate)}', style: const TextStyle(fontSize: 12)),
                  Text('• Return: ${_formatDate(_returnDate)}', style: const TextStyle(fontSize: 12)),
                  Text('• Request ID: ${newRequest.id}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cameras':
        return Icons.videocam_outlined;
      case 'lenses':
        return Icons.camera_outlined;
      case 'audio':
        return Icons.mic_outlined;
      case 'lighting':
        return Icons.lightbulb_outlined;
      case 'power':
        return Icons.battery_charging_full;
      case 'accessories':
        return Icons.cable;
      case 'tools':
        return Icons.build;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
