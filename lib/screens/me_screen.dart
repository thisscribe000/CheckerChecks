import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: StitchTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: StitchTheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                      border: Border.all(color: StitchTheme.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        'PR',
                        style: StitchTheme.headlineLg(context).copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Mercer',
                          style: StitchTheme.headlineLg(context).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.userRole} Professional',
                          style: StitchTheme.bodyMd(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'alex.mercer@creative.studio',
                          style: StitchTheme.monoSm(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: App Info
            Text('APPLICATION', style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 8),
            Container(
              decoration: StitchTheme.cardDecoration,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: StitchTheme.primary),
                    title: Text('Design Theme', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: Text('Stitch Minimalist Dark/Light', style: StitchTheme.bodyMd(context)),
                    trailing: Text('ACTIVE', style: StitchTheme.labelCaps(context).copyWith(color: StitchTheme.success)),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.storage_outlined, color: StitchTheme.primary),
                    title: Text('Inventory Items', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: Text('${provider.inventory.length} items persisted locally', style: StitchTheme.bodyMd(context)),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_outlined, color: StitchTheme.primary),
                    title: Text('AI Assistant Engine', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: Text('Smart Kit Recommendation active', style: StitchTheme.bodyMd(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Reset / Dev Tools
            Text('PREFERENCES', style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 8),
            Container(
              decoration: StitchTheme.cardDecoration,
              child: ListTile(
                leading: const Icon(Icons.refresh_outlined, color: StitchTheme.error),
                title: Text('Reset App Onboarding', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15, color: StitchTheme.error)),
                onTap: () {
                  provider.completeOnboarding(provider.userRole);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Onboarding state updated')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
