import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import 'new_gig_screen.dart';
import 'gig_checklist_screen.dart';

class GigsScreen extends StatefulWidget {
  const GigsScreen({super.key});

  @override
  State<GigsScreen> createState() => _GigsScreenState();
}

class _GigsScreenState extends State<GigsScreen> with SingleTickerProviderStateMixin {
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
    final upcomingGigs = provider.gigs.where((g) => g.status != 'COMPLETED').toList();
    final completedGigs = provider.gigs.where((g) => g.status == 'COMPLETED').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gigs'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 26),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewGigScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: StitchTheme.primary,
          labelColor: StitchTheme.primary,
          unselectedLabelColor: StitchTheme.onSurfaceVariant,
          labelStyle: StitchTheme.labelCaps(context).copyWith(fontSize: 12),
          unselectedLabelStyle: StitchTheme.labelCaps(context).copyWith(fontSize: 12),
          tabs: [
            Tab(text: 'UPCOMING (${upcomingGigs.length})'),
            Tab(text: 'COMPLETED (${completedGigs.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGigList(context, upcomingGigs, provider, 'No upcoming gigs scheduled.'),
          _buildGigList(context, completedGigs, provider, 'No completed gigs yet.'),
        ],
      ),
    );
  }

  Widget _buildGigList(BuildContext context, List gigs, AppProvider provider, String emptyMsg) {
    if (gigs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note_outlined, size: 48, color: StitchTheme.outline),
            const SizedBox(height: 12),
            Text(emptyMsg, style: StitchTheme.headlineMd(context)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewGigScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Gig'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchTheme.primary,
                foregroundColor: StitchTheme.onPrimary,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: gigs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gig = gigs[index];
        return GestureDetector(
          onTap: () {
            provider.setActiveGig(gig);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GigChecklistScreen(gig: gig)),
            );
          },
          onLongPress: () => _showGigQuickOptions(context, provider, gig),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: StitchTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        gig.name,
                        style: StitchTheme.headlineMd(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: gig.isReady
                            ? StitchTheme.successContainer
                            : StitchTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        gig.isReady ? 'READY' : gig.status,
                        style: StitchTheme.labelCaps(context).copyWith(
                          color: gig.isReady ? StitchTheme.success : StitchTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${gig.date} · ${gig.location} · ${gig.type}',
                  style: StitchTheme.bodyMd(context),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Packing Progress',
                      style: StitchTheme.monoSm(context),
                    ),
                    Text(
                      '${gig.packedItems} / ${gig.totalItems} packed',
                      style: StitchTheme.monoSm(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: StitchTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: gig.progressPercentage,
                    minHeight: 4,
                    backgroundColor: StitchTheme.surfaceContainerHigh,
                    color: gig.isReady ? StitchTheme.success : StitchTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGigQuickOptions(BuildContext context, AppProvider provider, dynamic gig) {
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
              leading: const Icon(Icons.checklist, color: StitchTheme.primary),
              title: Text('Open Checklist', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                provider.setActiveGig(gig);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GigChecklistScreen(gig: gig)),
                );
              },
            ),
            if (gig.status != 'COMPLETED')
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: StitchTheme.success),
                title: Text('Mark as Completed', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.markGigCompleted(gig.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.refresh, color: StitchTheme.primary),
                title: Text('Reopen Gig (In Prep)', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.reopenGig(gig.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: StitchTheme.primary),
              title: Text('Reset Checklist (Unpack all)', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                provider.resetGigChecklist(gig.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items reset to unpacked.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: StitchTheme.error),
              title: Text('Delete Gig', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15, color: StitchTheme.error)),
              onTap: () {
                Navigator.of(ctx).pop();
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: StitchTheme.surfaceContainerLowest,
                    title: Text('Delete "${gig.name}"?', style: StitchTheme.headlineMd(context)),
                    content: Text('This will delete this gig and its checklist.', style: StitchTheme.bodyLg(context)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: Text('Cancel', style: StitchTheme.bodyLg(context).copyWith(color: StitchTheme.primary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.deleteGig(gig.id);
                          Navigator.of(dialogCtx).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: StitchTheme.error, foregroundColor: Colors.white),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
