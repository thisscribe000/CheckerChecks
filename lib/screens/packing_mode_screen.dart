import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gig.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

class PackingModeScreen extends StatelessWidget {
  final Gig gig;

  const PackingModeScreen({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentGig = provider.gigs.firstWhere(
      (g) => g.id == gig.id,
      orElse: () => gig,
    );
    final ready = currentGig.isReady;

    return Scaffold(
      backgroundColor:
          ready ? StitchTheme.successContainer : StitchTheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor:
            ready ? StitchTheme.successContainer : StitchTheme.surfaceContainerLowest,
        title: Text(
          ready ? 'READY TO GO' : 'PACKING MODE',
          style: TextStyle(color: ready ? StitchTheme.success : StitchTheme.primary),
        ),
        iconTheme: IconThemeData(
          color: ready ? StitchTheme.success : StitchTheme.primary,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ready
            ? _ReadyView(gig: currentGig)
            : _PackingView(gig: currentGig, provider: provider),
      ),
    );
  }
}

// ── Ready to go view ──────────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  final Gig gig;
  const _ReadyView({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: StitchTheme.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            'READY TO GO',
            style: StitchTheme.display(context).copyWith(
              color: StitchTheme.success,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${gig.totalItems} / ${gig.totalItems} packed',
            style: StitchTheme.headlineMd(context).copyWith(
              color: StitchTheme.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Everything is packed for ${gig.name}.',
            textAlign: TextAlign.center,
            style: StitchTheme.bodyLg(context)
                .copyWith(color: StitchTheme.onSurface),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchTheme.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                'Back to checklist',
                style: StitchTheme.headlineMd(context)
                    .copyWith(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Packing view ──────────────────────────────────────────────────────────────

class _PackingView extends StatelessWidget {
  final Gig gig;
  final AppProvider provider;

  const _PackingView({required this.gig, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: StitchTheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gig.name,
                  style:
                      StitchTheme.headlineMd(context).copyWith(fontSize: 17)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${gig.packedItems} / ${gig.totalItems} packed',
                    style: StitchTheme.headlineLg(context)
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${(gig.progressPercentage * 100).round()}%',
                    style: StitchTheme.monoSm(context)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: gig.progressPercentage,
                  minHeight: 6,
                  backgroundColor: StitchTheme.surfaceContainerHigh,
                  color: StitchTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: StitchTheme.outlineVariant),

        // Item list — large touch targets
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gig.items.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderChecklistItems(gig.id, oldIndex, newIndex);
            },
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final item = gig.items[index];
              return Padding(
                key: ValueKey(item.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => provider.toggleChecklistItemPacked(
                      gig.id, item.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: item.packed
                        ? BoxDecoration(
                            color: StitchTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: StitchTheme.primary, width: 1.5),
                          )
                        : StitchTheme.cardDecoration,
                    child: Row(
                      children: [
                        // Big checkbox visual
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: item.packed
                                ? StitchTheme.primary
                                : StitchTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: item.packed
                                  ? StitchTheme.primary
                                  : StitchTheme.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: item.packed
                              ? const Icon(Icons.check,
                                  size: 18, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.name,
                            style: StitchTheme.headlineMd(context).copyWith(
                              fontSize: 16,
                              decoration: item.packed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.packed
                                  ? StitchTheme.outline
                                  : StitchTheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          item.category,
                          style: StitchTheme.labelCaps(context)
                              .copyWith(fontSize: 9),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.drag_handle, color: StitchTheme.outlineVariant, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
