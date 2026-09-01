import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

import 'inventory_screen.dart';
import 'gigs_screen.dart';
import 'new_gig_screen.dart';
import 'gig_checklist_screen.dart';
import 'rentals_screen.dart';

import 'me_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreenContent(onSwitchToTab: selectTab),
      const GigsScreen(),
      const InventoryScreen(),
      const RentalsScreen(),
      const MeScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'GIGS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'INVENTORY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake),
            label: 'RENTALS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'ME',
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final ValueChanged<int>? onSwitchToTab;

  const HomeScreenContent({super.key, this.onSwitchToTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final nextGig = provider.nextGig;
    final recentGigs = provider.gigs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECKERCHECKS'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Text(
              _getGreeting(),
              style: StitchTheme.display(context).copyWith(fontSize: 32),
            ),
            Text(
              'Here is your prep status.',
              style: StitchTheme.bodyLg(context),
            ),
            const SizedBox(height: 24),

            // Next Gig Section
            if (nextGig != null) ...[
              Text(
                'Next Gig',
                style: StitchTheme.labelCaps(context),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  provider.setActiveGig(nextGig);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GigChecklistScreen(gig: nextGig),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: StitchTheme.cardDecorationActive,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nextGig.name,
                            style: StitchTheme.headlineLg(context).copyWith(fontSize: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: nextGig.isReady
                                  ? StitchTheme.successContainer
                                  : StitchTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              nextGig.status,
                              style: StitchTheme.labelCaps(context).copyWith(
                                color: nextGig.isReady
                                    ? StitchTheme.success
                                    : StitchTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: StitchTheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            '${nextGig.date} · ${nextGig.location}',
                            style: StitchTheme.bodyMd(context).copyWith(color: StitchTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Progress Bar & Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: StitchTheme.monoSm(context),
                          ),
                          Text(
                            '${nextGig.packedItems} / ${nextGig.totalItems} packed',
                            style: StitchTheme.monoSm(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: StitchTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: nextGig.progressPercentage,
                          minHeight: 6,
                          backgroundColor: StitchTheme.surfaceContainerHigh,
                          color: nextGig.isReady ? StitchTheme.success : StitchTheme.primary,
                        ),
                      ),

                      if (nextGig.missingItemsCount > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: StitchTheme.error),
                            const SizedBox(width: 4),
                            Text(
                              '${nextGig.missingItemsCount} missing item${nextGig.missingItemsCount > 1 ? 's' : ''} from inventory',
                              style: StitchTheme.monoSm(context).copyWith(
                                color: StitchTheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quick Actions Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewGigScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('New Gig'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchTheme.primary,
                        foregroundColor: StitchTheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (onSwitchToTab != null) {
                          onSwitchToTab!(2);
                        }
                      },
                      icon: const Icon(Icons.inventory_2_outlined, size: 20),
                      label: const Text('Inventory'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StitchTheme.primary,
                        side: const BorderSide(color: StitchTheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Gigs List
            Text(
              'Recent Gigs',
              style: StitchTheme.labelCaps(context),
            ),
            const SizedBox(height: 12),

            if (recentGigs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No gigs created yet.',
                    style: StitchTheme.bodyLg(context),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentGigs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final gig = recentGigs[index];
                  return Container(
                    decoration: StitchTheme.cardDecoration,
                    child: ListTile(
                      title: Text(gig.name, style: StitchTheme.headlineMd(context).copyWith(fontSize: 16)),
                      subtitle: Text('${gig.date} · ${gig.location}', style: StitchTheme.bodyMd(context)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${gig.packedItems}/${gig.totalItems}',
                            style: StitchTheme.monoSm(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20, color: StitchTheme.outline),
                        ],
                      ),
                      onTap: () {
                        provider.setActiveGig(gig);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GigChecklistScreen(gig: gig)),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
