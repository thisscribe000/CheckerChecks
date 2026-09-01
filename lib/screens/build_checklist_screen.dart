import 'package:flutter/material.dart';
import '../models/gig.dart';
import '../services/recommendation_service.dart';
import '../theme/stitch_theme.dart';
import 'suggested_kit_screen.dart';
import 'gig_checklist_screen.dart';
import 'template_picker_screen.dart';

class BuildChecklistScreen extends StatelessWidget {
  final Gig gig;

  const BuildChecklistScreen({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    // Default template for this gig type, if one exists
    GigTemplate? defaultTemplate;
    try {
      defaultTemplate = kGigTemplates.firstWhere((t) => t.gigType == gig.type);
    } catch (_) {
      defaultTemplate = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Checklist'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gig.name, style: StitchTheme.headlineLg(context)),
            const SizedBox(height: 4),
            Text(
              '${gig.type}  ·  ${gig.size}  ·  ${gig.location}',
              style: StitchTheme.bodyLg(context),
            ),
            const SizedBox(height: 8),
            Text(gig.date, style: StitchTheme.monoSm(context)),
            const SizedBox(height: 32),
            Text('HOW WOULD YOU LIKE TO BUILD YOUR CHECKLIST?',
                style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 16),

            // ── Option 1: Smart suggestions ───────────────────────────────
            _OptionCard(
              icon: Icons.auto_awesome_outlined,
              filled: true,
              title: 'Get suggestions',
              badge: 'RECOMMENDED',
              body: defaultTemplate != null
                  ? 'Based on ${defaultTemplate.name} template + your inventory.'
                  : 'Rule-based suggestions matched against your inventory.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SuggestedKitScreen(gig: gig),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Option 2: Browse templates ────────────────────────────────
            _OptionCard(
              icon: Icons.dashboard_customize_outlined,
              title: 'Use a template',
              body: 'Choose from ${kGigTemplates.length} ready-made kit templates.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TemplatePickerScreen(gig: gig),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Option 3: Start from scratch ──────────────────────────────
            _OptionCard(
              icon: Icons.edit_note_outlined,
              title: 'Start from scratch',
              body: 'Open an empty checklist and add items manually.',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GigChecklistScreen(gig: gig),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable option card widget ─────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? badge;
  final bool filled;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.badge,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: filled
            ? BoxDecoration(
                color: StitchTheme.primary,
                borderRadius: BorderRadius.circular(4),
              )
            : StitchTheme.cardDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withAlpha(30)
                    : StitchTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 22,
                color: filled ? Colors.white : StitchTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: StitchTheme.headlineMd(context).copyWith(
                          fontSize: 15,
                          color: filled ? Colors.white : StitchTheme.primary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            badge!,
                            style: StitchTheme.labelCaps(context).copyWith(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: StitchTheme.bodyMd(context).copyWith(
                      color: filled
                          ? Colors.white.withAlpha(180)
                          : StitchTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: filled ? Colors.white54 : StitchTheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
