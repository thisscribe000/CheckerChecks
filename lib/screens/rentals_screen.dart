import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import '../models/rental.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final active =
        provider.rentals.where((r) => r.status == 'Active').toList();
    final past =
        provider.rentals.where((r) => r.status == 'Returned').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: StitchTheme.primary,
          unselectedLabelColor: StitchTheme.outline,
          indicatorColor: StitchTheme.primary,
          labelStyle: StitchTheme.headlineMd(context).copyWith(fontSize: 14),
          tabs: [
            Tab(text: 'ACTIVE (${active.length})'),
            Tab(text: 'PAST (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RentalList(rentals: active, isActive: true),
          _RentalList(rentals: past, isActive: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_rental',
        onPressed: () => _showNewRentalDialog(context, provider),
        backgroundColor: StitchTheme.primary,
        foregroundColor: StitchTheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text('New Rental', style: StitchTheme.headlineMd(context).copyWith(color: StitchTheme.onPrimary, fontSize: 14)),
      ),
    );
  }

  void _showNewRentalDialog(BuildContext context, AppProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _CreateRentalScreen()),
    );
  }
}

class _RentalList extends StatelessWidget {
  final List<Rental> rentals;
  final bool isActive;

  const _RentalList({required this.rentals, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.handshake_outlined : Icons.history,
                size: 48, color: StitchTheme.outline),
            const SizedBox(height: 16),
            Text(isActive ? 'No active rentals' : 'No past rentals',
                style: StitchTheme.headlineMd(context)),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Rent out your gear to keep track of it.'
                  : 'Completed rentals will appear here.',
              style: StitchTheme.bodyLg(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        final provider = Provider.of<AppProvider>(context, listen: false);
        return GestureDetector(
          onTap: () => _showRentalDetails(context, rental, provider),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: StitchTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rental.customerName,
                        style: StitchTheme.headlineMd(context)
                            .copyWith(fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? StitchTheme.warningContainer
                            : StitchTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'OUT' : 'RETURNED',
                        style: StitchTheme.labelCaps(context).copyWith(
                          color: isActive
                              ? StitchTheme.warning
                              : StitchTheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 14, color: StitchTheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      '${rental.startDate} — ${rental.expectedReturnDate}',
                      style: StitchTheme.bodyMd(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 14, color: StitchTheme.outline),
                    const SizedBox(width: 6),
                    Text(
                      '${rental.inventoryItemIds.length} items rented',
                      style: StitchTheme.bodyMd(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRentalDetails(
      BuildContext context, Rental rental, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        final rentedGear = provider.inventory
            .where((i) => rental.inventoryItemIds.contains(i.id))
            .toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rental Details',
                          style: StitchTheme.headlineLg(context)
                              .copyWith(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _DetailRow(
                          label: 'CUSTOMER', value: rental.customerName),
                      if (rental.customerContact.isNotEmpty)
                        _DetailRow(
                            label: 'CONTACT', value: rental.customerContact),
                      _DetailRow(
                          label: 'DATES',
                          value:
                              '${rental.startDate} to ${rental.expectedReturnDate}'),
                      if (rental.notes != null && rental.notes!.isNotEmpty)
                        _DetailRow(label: 'NOTES', value: rental.notes!),
                      const SizedBox(height: 24),
                      Text('RENTED GEAR',
                          style: StitchTheme.labelCaps(context)),
                      const SizedBox(height: 12),
                      for (final gear in rentedGear)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: StitchTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: StitchTheme.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 16, color: StitchTheme.outline),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(gear.name,
                                    style: StitchTheme.headlineMd(context)
                                        .copyWith(fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      if (rental.status == 'Active')
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              provider.completeRental(rental.id);
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StitchTheme.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Text('Mark as Returned',
                                style: StitchTheme.headlineMd(context)
                                    .copyWith(
                                        color: Colors.white, fontSize: 15)),
                          ),
                        ),
                      if (rental.status == 'Active') const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: ctx,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor:
                                    StitchTheme.surfaceContainerLowest,
                                title: Text('Delete rental?',
                                    style: StitchTheme.headlineMd(context)),
                                content: Text(
                                    'This will delete the record. Active gear will be marked as Available.',
                                    style: StitchTheme.bodyLg(context)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dCtx).pop(),
                                    child: Text('Cancel',
                                        style: StitchTheme.bodyLg(context)
                                            .copyWith(
                                                color: StitchTheme.primary)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.deleteRental(rental.id);
                                      Navigator.of(dCtx).pop();
                                      Navigator.of(ctx).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: StitchTheme.error,
                                        foregroundColor: Colors.white,
                                        elevation: 0),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StitchTheme.error,
                            side: const BorderSide(color: StitchTheme.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text('Delete Rental',
                              style: StitchTheme.headlineMd(context).copyWith(
                                  color: StitchTheme.error, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StitchTheme.labelCaps(context)),
          const SizedBox(height: 4),
          Text(value, style: StitchTheme.bodyLg(context)),
        ],
      ),
    );
  }
}

// ── Create Rental Screen ──────────────────────────────────────────────────

class _CreateRentalScreen extends StatefulWidget {
  const _CreateRentalScreen();

  @override
  State<_CreateRentalScreen> createState() => _CreateRentalScreenState();
}

class _CreateRentalScreenState extends State<_CreateRentalScreen> {
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  final List<String> _selectedItemIds = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final availableItems = provider.inventory
        .where((i) => i.rentalStatus == 'Available')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Rental'),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameCtrl.text.isEmpty || _selectedItemIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name and select gear.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              provider.createRental(
                customerName: _nameCtrl.text.trim(),
                customerContact: _contactCtrl.text.trim(),
                startDate: _startCtrl.text.trim().isNotEmpty
                    ? _startCtrl.text.trim()
                    : 'Today',
                expectedReturnDate: _returnCtrl.text.trim().isNotEmpty
                    ? _returnCtrl.text.trim()
                    : 'TBD',
                inventoryItemIds: _selectedItemIds,
                notes: _notesCtrl.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: Text(
              'Save',
              style: StitchTheme.headlineMd(context).copyWith(
                  color: StitchTheme.primary, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('CUSTOMER INFO', style: StitchTheme.labelCaps(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDec('Customer Name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactCtrl,
            decoration: _inputDec('Phone / Email (optional)'),
          ),
          const SizedBox(height: 24),
          Text('RENTAL DATES', style: StitchTheme.labelCaps(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startCtrl,
                  decoration: _inputDec('Start (e.g. Oct 12)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _returnCtrl,
                  decoration: _inputDec('Return (e.g. Oct 15)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SELECT GEAR TO RENT',
                  style: StitchTheme.labelCaps(context)),
              Text('${_selectedItemIds.length} selected',
                  style: StitchTheme.bodyMd(context)
                      .copyWith(color: StitchTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          if (availableItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StitchTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                  'No available gear to rent. All your gear might be rented out already!'),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: StitchTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: StitchTheme.outlineVariant),
              ),
              child: Column(
                children: availableItems.map((item) {
                  final isSelected = _selectedItemIds.contains(item.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedItemIds.add(item.id);
                        } else {
                          _selectedItemIds.remove(item.id);
                        }
                      });
                    },
                    title: Text(item.name,
                        style: StitchTheme.headlineMd(context)
                            .copyWith(fontSize: 14)),
                    subtitle: Text(item.category,
                        style: StitchTheme.labelCaps(context)
                            .copyWith(fontSize: 9)),
                    activeColor: StitchTheme.primary,
                    checkColor: StitchTheme.onPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  );
                }).toList(),
              ),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide:
              const BorderSide(color: StitchTheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StitchTheme.outlineVariant),
        ),
      );
}
