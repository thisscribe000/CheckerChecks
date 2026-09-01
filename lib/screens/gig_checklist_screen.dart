import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gig.dart';
import '../models/checklist_item.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import 'packing_mode_screen.dart';

class GigChecklistScreen extends StatelessWidget {
  final Gig gig;

  const GigChecklistScreen({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentGig = provider.gigs.firstWhere(
      (g) => g.id == gig.id,
      orElse: () => gig,
    );

    // Group by category
    final grouped = <String, List<ChecklistItem>>{};
    for (final item in currentGig.items) {
      grouped.putIfAbsent(item.category.toUpperCase(), () => []).add(item);
    }

    final missing = currentGig.items
        .where((i) => i.isMissingFromInventory && !i.packed)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentGig.name),
        actions: [
          // Mark complete action
          if (!currentGig.isReady)
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Options',
              onPressed: () => _showOptions(context, provider, currentGig),
            ),
          if (currentGig.isReady)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Mark as Completed',
              onPressed: () => _confirmComplete(context, provider, currentGig),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Gig header + progress ──────────────────────────────────────
          _GigHeader(gig: currentGig, missing: missing),

          // ── Checklist body ─────────────────────────────────────────────
          Expanded(
            child: grouped.isEmpty
                ? _EmptyChecklist(gig: currentGig)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(entry.key,
                              style: StitchTheme.labelCaps(context)),
                        ),
                        for (final item in entry.value)
                          _ChecklistRow(
                            item: item,
                            gigId: currentGig.id,
                            provider: provider,
                          ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
          ),
        ],
      ),

      // ── Floating bottom bar ────────────────────────────────────────────
      bottomNavigationBar: _BottomBar(gig: currentGig, provider: provider),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add_checklist_item',
        onPressed: () => _showAddItemDialog(context, provider, currentGig.id),
        backgroundColor: StitchTheme.primary,
        foregroundColor: StitchTheme.onPrimary,
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Add item dialog ──────────────────────────────────────────────────────

  void _showAddItemDialog(
      BuildContext context, AppProvider provider, String gigId) {
    final nameCtrl = TextEditingController();
    String category = 'CAMERA';
    const cats = [
      'CAMERA', 'LENSES', 'AUDIO', 'LIGHTING',
      'POWER', 'ACCESSORIES', 'SUPPORT', 'OTHER',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add item', style: StitchTheme.headlineMd(context)),
                const SizedBox(height: 16),
                // Name
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: StitchTheme.bodyLg(context)
                      .copyWith(color: StitchTheme.primary),
                  decoration: _inputDec('Item name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                // Category chips
                Text('CATEGORY', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cats.map((c) {
                    final selected = category == c;
                    return GestureDetector(
                      onTap: () => setModalState(() => category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? StitchTheme.primary
                              : StitchTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: selected
                                ? StitchTheme.primary
                                : StitchTheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          c,
                          style: StitchTheme.labelCaps(context).copyWith(
                            color: selected
                                ? StitchTheme.onPrimary
                                : StitchTheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      provider.addManualChecklistItem(
                        gigId: gigId,
                        name: name,
                        category: category,
                      );
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchTheme.primary,
                      foregroundColor: StitchTheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('Add to checklist',
                        style: StitchTheme.headlineMd(context)
                            .copyWith(color: StitchTheme.onPrimary, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        });
      },
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

  // ── Options sheet ────────────────────────────────────────────────────────

  void _showOptions(
      BuildContext context, AppProvider provider, Gig currentGig) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: StitchTheme.primary),
              title: Text('Edit gig details',
                  style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showEditGigDialog(context, provider, currentGig);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: StitchTheme.primary),
              title: Text('Reset checklist (Unpack all)',
                  style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                provider.resetGigChecklist(currentGig.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items reset to unpacked.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (currentGig.status != 'COMPLETED')
              ListTile(
                leading: const Icon(Icons.check_circle_outline,
                    color: StitchTheme.success),
                title: Text('Mark gig as completed',
                    style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmComplete(context, provider, currentGig);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.refresh, color: StitchTheme.primary),
                title: Text('Reopen gig (Move to In Prep)',
                    style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.reopenGig(currentGig.id);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: StitchTheme.error),
              title: Text('Delete gig',
                  style: StitchTheme.headlineMd(context)
                      .copyWith(fontSize: 15, color: StitchTheme.error)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDeleteGig(context, provider, currentGig);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditGigDialog(
      BuildContext context, AppProvider provider, Gig gig) {
    final nameCtrl = TextEditingController(text: gig.name);
    final dateCtrl = TextEditingController(text: gig.date);
    String type = gig.type;
    String size = gig.size;
    String location = gig.location;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Gig', style: StitchTheme.headlineLg(context).copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                Text('GIG NAME', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: _inputDec('Gig name'),
                ),
                const SizedBox(height: 14),
                Text('DATE / TIME', style: StitchTheme.labelCaps(context)),
                const SizedBox(height: 6),
                TextField(
                  controller: dateCtrl,
                  decoration: _inputDec('e.g. Tomorrow · 2:00 PM'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      provider.updateGig(
                        id: gig.id,
                        name: name,
                        type: type,
                        size: size,
                        location: location,
                        date: dateCtrl.text.trim().isNotEmpty
                            ? dateCtrl.text.trim()
                            : gig.date,
                      );
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchTheme.primary,
                      foregroundColor: StitchTheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
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

  void _confirmDeleteGig(
      BuildContext context, AppProvider provider, Gig currentGig) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StitchTheme.surfaceContainerLowest,
        title: Text('Delete "${currentGig.name}"?',
            style: StitchTheme.headlineMd(context)),
        content: Text(
          'This will permanently delete this gig and its checklist.',
          style: StitchTheme.bodyLg(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: StitchTheme.bodyLg(context)
                    .copyWith(color: StitchTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteGig(currentGig.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${currentGig.name}'),
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

  void _confirmComplete(
      BuildContext context, AppProvider provider, Gig currentGig) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StitchTheme.surfaceContainerLowest,
        title: Text('Mark as completed?',
            style: StitchTheme.headlineMd(context)),
        content: Text(
          'This will move "${currentGig.name}" to your Completed gigs.',
          style: StitchTheme.bodyLg(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: StitchTheme.bodyLg(context)
                    .copyWith(color: StitchTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.markGigCompleted(currentGig.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
              elevation: 0,
            ),
            child: const Text('Mark completed'),
          ),
        ],
      ),
    );
  }
}

// ── Gig header component ──────────────────────────────────────────────────────

class _GigHeader extends StatelessWidget {
  final Gig gig;
  final int missing;

  const _GigHeader({required this.gig, required this.missing});

  @override
  Widget build(BuildContext context) {
    final ready = gig.isReady;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: StitchTheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date · type · location row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${gig.date}  ·  ${gig.location}',
                  style: StitchTheme.bodyMd(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ready
                      ? StitchTheme.successContainer
                      : StitchTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  ready ? 'READY' : gig.status,
                  style: StitchTheme.labelCaps(context).copyWith(
                    color: ready ? StitchTheme.success : StitchTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${gig.packedItems} / ${gig.totalItems} packed',
                style: StitchTheme.headlineMd(context).copyWith(fontSize: 17),
              ),
              if (missing > 0)
                Row(
                  children: [
                    const Icon(Icons.radio_button_unchecked,
                        size: 13, color: StitchTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '$missing missing',
                      style: StitchTheme.labelCaps(context)
                          .copyWith(fontSize: 10),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: gig.progressPercentage,
              minHeight: 5,
              backgroundColor: StitchTheme.surfaceContainerHigh,
              color: ready ? StitchTheme.success : StitchTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyChecklist extends StatelessWidget {
  final Gig gig;
  const _EmptyChecklist({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_outlined,
                size: 44, color: StitchTheme.outline),
            const SizedBox(height: 14),
            Text('No items yet', style: StitchTheme.headlineMd(context)),
            const SizedBox(height: 6),
            Text(
              'Tap + to add items manually, or go back and choose a template.',
              textAlign: TextAlign.center,
              style: StitchTheme.bodyLg(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single checklist row ──────────────────────────────────────────────────────

class _ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final String gigId;
  final AppProvider provider;

  const _ChecklistRow({
    required this.item,
    required this.gigId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final inInv = !item.isMissingFromInventory;
    final packed = item.packed;
    
    bool isRentedOut = false;
    if (inInv && item.inventoryItemId != null) {
      final invItems = provider.inventory.where((i) => i.id == item.inventoryItemId);
      if (invItems.isNotEmpty && invItems.first.rentalStatus == 'Rented Out') {
        isRentedOut = true;
      }
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: StitchTheme.errorContainer,
        child: const Icon(Icons.delete_outline,
            color: StitchTheme.error, size: 20),
      ),
      onDismissed: (_) =>
          provider.deleteChecklistItem(gigId, item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: StitchTheme.cardDecoration,
        child: CheckboxListTile(
          value: packed,
          onChanged: (_) =>
              provider.toggleChecklistItemPacked(gigId, item.id),
          activeColor: StitchTheme.primary,
          checkColor: StitchTheme.onPrimary,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          title: Text(
            item.name,
            style: StitchTheme.headlineMd(context).copyWith(
              fontSize: 14,
              decoration: packed ? TextDecoration.lineThrough : null,
              color: packed ? StitchTheme.outline : StitchTheme.primary,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                inInv
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 11,
                color: inInv
                    ? StitchTheme.success
                    : StitchTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                inInv ? 'In inventory' : 'Missing',
                style: StitchTheme.labelCaps(context).copyWith(
                  fontSize: 9,
                  color: inInv
                      ? StitchTheme.success
                      : StitchTheme.onSurfaceVariant,
                ),
              ),
              if (isRentedOut) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: StitchTheme.warningContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'RENTED OUT',
                    style: StitchTheme.labelCaps(context).copyWith(
                      fontSize: 8,
                      color: StitchTheme.warning,
                    ),
                  ),
                ),
              ],
              if (!inInv) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    provider.quickAddInventoryItemFromChecklist(
                      gigId: gigId,
                      checklistItemId: item.id,
                      name: item.name,
                      category: item.category,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${item.name}" to your Inventory!'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: StitchTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: StitchTheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 10, color: StitchTheme.primary),
                        const SizedBox(width: 2),
                        Text(
                          'Add to Inventory',
                          style: StitchTheme.labelCaps(context).copyWith(
                            fontSize: 8,
                            color: StitchTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (item.source == 'manual') ...[
                const SizedBox(width: 8),
                Text(
                  'MANUAL',
                  style: StitchTheme.labelCaps(context)
                      .copyWith(fontSize: 8, color: StitchTheme.outline),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final Gig gig;
  final AppProvider provider;

  const _BottomBar({required this.gig, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currentGig = provider.gigs.firstWhere(
      (g) => g.id == gig.id,
      orElse: () => gig,
    );
    final ready = currentGig.isReady;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: const BoxDecoration(
        color: StitchTheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: StitchTheme.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PackingModeScreen(gig: currentGig),
            ),
          ),
          icon: Icon(
            ready
                ? Icons.check_circle_outline
                : Icons.inventory_2_outlined,
            size: 20,
          ),
          label: Text(
            ready ? 'READY TO GO' : 'START PACKING MODE',
            style: StitchTheme.headlineMd(context)
                .copyWith(color: StitchTheme.onPrimary, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                ready ? StitchTheme.success : StitchTheme.primary,
            foregroundColor: StitchTheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}
