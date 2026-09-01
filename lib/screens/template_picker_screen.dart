import 'package:flutter/material.dart';
import '../models/gig.dart';
import '../services/recommendation_service.dart';
import '../theme/stitch_theme.dart';
import 'suggested_kit_screen.dart';

class TemplatePickerScreen extends StatelessWidget {
  final Gig gig;

  const TemplatePickerScreen({super.key, required this.gig});

  // Group templates by gigType
  Map<String, List<GigTemplate>> get _grouped {
    final map = <String, List<GigTemplate>>{};
    for (final t in kGigTemplates) {
      map.putIfAbsent(t.gigType, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    // Put the matching type first
    final orderedTypes = grouped.keys.toList()
      ..sort((a, b) => a == gig.type ? -1 : b == gig.type ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Templates for ${gig.name}',
            style: StitchTheme.bodyLg(context),
          ),
          const SizedBox(height: 20),
          for (final type in orderedTypes) ...[
            _SectionHeader(title: type.toUpperCase()),
            const SizedBox(height: 8),
            for (final tpl in grouped[type]!)
              _TemplateCard(
                template: tpl,
                isMatch: tpl.gigType == gig.type,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SuggestedKitScreen(
                      gig: gig,
                      template: tpl,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: StitchTheme.labelCaps(context));
  }
}

class _TemplateCard extends StatelessWidget {
  final GigTemplate template;
  final bool isMatch;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isMatch,
    required this.onTap,
  });

  int get _itemCount =>
      template.items.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isMatch
            ? StitchTheme.cardDecorationActive
            : StitchTheme.cardDecoration,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        template.name,
                        style: StitchTheme.headlineMd(context)
                            .copyWith(fontSize: 15),
                      ),
                      if (isMatch) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: StitchTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'MATCH',
                            style: StitchTheme.labelCaps(context).copyWith(
                              color: StitchTheme.onPrimary,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: StitchTheme.bodyMd(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${template.items.keys.length} categories  ·  $_itemCount items',
                    style: StitchTheme.monoSm(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: StitchTheme.outline),
          ],
        ),
      ),
    );
  }
}
