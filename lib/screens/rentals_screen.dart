import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import '../models/rental.dart';
import '../widgets/equipment_scanner_sheet.dart';
import '../widgets/qr_code_tag_dialog.dart';
import '../widgets/share_booking_link_dialog.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final pending = provider.pendingRentals;
    final active = provider.activeRentals;
    final past = provider.pastRentals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Share Booking Link',
            onPressed: () {
              ShareBookingLinkDialog.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Gear',
            onPressed: () {
              EquipmentScannerSheet.show(context, mode: ScannerMode.lookup);
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'How Rentals Work',
            onPressed: () => _showRentalsHelpDialog(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: StitchTheme.primary,
          unselectedLabelColor: StitchTheme.outline,
          indicatorColor: StitchTheme.primary,
          labelStyle: StitchTheme.headlineMd(context).copyWith(fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('REQUESTS (${pending.length})'),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'ACTIVE (${active.length})'),
            Tab(text: 'PAST (${past.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingRequestsList(rentals: pending),
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

  void _showRentalsHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Rental Workflow'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CheckerChecks empowers your equipment rental operations in 3 simple steps:\n',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '1. Share Booking Link',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Send your custom rental link or show the QR code to clients. Clients choose available equipment and submit their dates and details.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                '2. Approve in "Requests"',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Incoming bookings land in the "Requests" tab. Review the gear requested and tap "Approve & Check Out" to lock the items to Rented Out.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                '3. Scan-to-Return Check-in',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'When the client brings gear back, open the rental and tap "Scan to Return" to verify each piece with your camera.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showNewRentalDialog(BuildContext context, AppProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _CreateRentalScreen()),
    );
  }
}

class _PendingRequestsList extends StatelessWidget {
  final List<Rental> rentals;

  const _PendingRequestsList({required this.rentals});

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: StitchTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inbox_outlined, size: 48, color: StitchTheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'No Pending Requests',
                style: StitchTheme.headlineMd(context).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your booking link with clients so they can browse your gear and submit requests directly.',
                style: StitchTheme.bodyMd(context).copyWith(color: StitchTheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ShareBookingLinkDialog.show(context),
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Share Booking Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchTheme.primary,
                  foregroundColor: StitchTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        return _PendingRequestCard(rental: rental);
      },
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final Rental rental;

  const _PendingRequestCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final requestedGear = provider.inventory
        .where((i) => rental.inventoryItemIds.contains(i.id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rental.customerName,
                  style: StitchTheme.headlineMd(context).copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 12, color: Colors.blue.shade900),
                    const SizedBox(width: 4),
                    Text(
                      rental.isBookedViaLink ? 'LINK REQUEST' : 'PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (rental.projectShootName != null && rental.projectShootName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.movie_outlined, size: 14, color: StitchTheme.outline),
                const SizedBox(width: 6),
                Text(
                  rental.projectShootName!,
                  style: StitchTheme.bodySm(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: StitchTheme.outline),
              const SizedBox(width: 6),
              Text(
                '${rental.startDate} — ${rental.expectedReturnDate}',
                style: StitchTheme.bodyMd(context),
              ),
            ],
          ),

          if (rental.customerContact.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.contact_phone_outlined, size: 14, color: StitchTheme.outline),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rental.customerContact,
                    style: StitchTheme.bodySm(context).copyWith(color: StitchTheme.outline),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Requested Gear summary
          Text(
            'REQUESTED GEAR (${requestedGear.length}):',
            style: StitchTheme.labelCaps(context).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: requestedGear.map((gear) {
              final isRentedToOther = gear.rentalStatus == 'Rented Out';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRentedToOther
                      ? Colors.amber.withValues(alpha: 0.15)
                      : StitchTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isRentedToOther
                        ? Colors.amber.shade700
                        : StitchTheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRentedToOther ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 13,
                      color: isRentedToOther ? Colors.amber.shade900 : StitchTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gear.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isRentedToOther ? Colors.amber.shade900 : StitchTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          if (rental.notes != null && rental.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StitchTheme.surfaceContainerHigh.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Note: ${rental.notes}',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: StitchTheme.outline),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons: Decline / Approve
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmDecline(context, provider, rental),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.approveRental(rental.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Approved ${rental.customerName}! Equipment marked Rented Out.')),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green.shade800,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchTheme.primary,
                    foregroundColor: StitchTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve & Check Out', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDecline(BuildContext context, AppProvider provider, Rental rental) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to decline the rental request for ${rental.customerName}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'e.g. Equipment scheduled for maintenance',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.declineRental(rental.id, reason: reasonController.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rental request declined.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
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
                            : (rental.isDeclined ? Colors.red.shade100 : StitchTheme.surfaceContainerHigh),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive
                            ? 'OUT'
                            : (rental.isDeclined ? 'DECLINED' : 'RETURNED'),
                        style: StitchTheme.labelCaps(context).copyWith(
                          color: isActive
                              ? StitchTheme.warning
                              : (rental.isDeclined ? Colors.red.shade900 : StitchTheme.outline),
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
                if (isActive) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rental.verifiedCount > 0
                            ? '${rental.verifiedCount}/${rental.totalCount} items verified'
                            : 'Return ready',
                        style: StitchTheme.monoSm(context).copyWith(
                          color: rental.isFullyVerified
                              ? StitchTheme.success
                              : StitchTheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner, size: 16),
                        label: Text(
                          rental.isFullyVerified
                              ? 'Return Verified'
                              : (rental.verifiedCount > 0
                                  ? 'Scan (${rental.verifiedCount}/${rental.totalCount})'
                                  : 'Scan to Return'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: rental.isFullyVerified
                              ? StitchTheme.success
                              : StitchTheme.primary,
                          side: BorderSide(
                            color: rental.isFullyVerified
                                ? StitchTheme.success
                                : StitchTheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          EquipmentScannerSheet.show(
                            context,
                            mode: ScannerMode.rentalReturn,
                            rental: rental,
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
                        Builder(
                          builder: (context) {
                            final isVerified = rental.isItemVerified(gear.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? StitchTheme.success.withValues(alpha: 0.12)
                                    : StitchTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isVerified
                                      ? StitchTheme.success
                                      : StitchTheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.check_circle
                                        : Icons.inventory_2_outlined,
                                    size: 18,
                                    color: isVerified
                                        ? StitchTheme.success
                                        : StitchTheme.outline,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(gear.name,
                                            style: StitchTheme.headlineMd(
                                                    context)
                                                .copyWith(fontSize: 14)),
                                        Text(
                                          'Code: ${gear.primaryCode}',
                                          style: StitchTheme.monoSm(context)
                                              .copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.qr_code, size: 20),
                                    tooltip: 'View QR Tag',
                                    onPressed: () =>
                                        QrCodeTagDialog.show(context, gear),
                                  ),
                                  if (rental.status == 'Active')
                                    IconButton(
                                      icon: Icon(
                                        isVerified
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: isVerified
                                            ? StitchTheme.success
                                            : StitchTheme.outline,
                                      ),
                                      tooltip: 'Toggle verification',
                                      onPressed: () {
                                        provider.toggleRentalItemVerified(
                                            rental.id, gear.id);
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 28),
                      if (rental.status == 'Active') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            label: Text(
                              rental.isFullyVerified
                                  ? 'All Items Verified ✓'
                                  : 'Scan Return Items (${rental.verifiedCount}/${rental.totalCount})',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: rental.isFullyVerified
                                  ? StitchTheme.success
                                  : StitchTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              EquipmentScannerSheet.show(
                                context,
                                mode: ScannerMode.rentalReturn,
                                rental: rental,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              provider.completeRental(rental.id);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Mark as Returned (Skip Scan)'),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
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
