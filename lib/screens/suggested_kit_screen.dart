import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gig.dart';
import '../providers/app_provider.dart';
import '../services/recommendation_service.dart';
import '../theme/stitch_theme.dart';
import 'gig_checklist_screen.dart';

class SuggestedKitScreen extends StatefulWidget {
  final Gig gig;
  final GigTemplate? template; // null = use default rule-based suggestions

  const SuggestedKitScreen({super.key, required this.gig, this.template});

  @override
  State<SuggestedKitScreen> createState() => _SuggestedKitScreenState();
}

class _SuggestedKitScreenState extends State<SuggestedKitScreen> {
  late List<RecommendationResult> _results;
  late Set<int> _selectedIndices; // indices into _results

  @override
  void initState() {
    super.initState();
    _buildSuggestions();
  }

  void _buildSuggestions() {
    final inventory =
        Provider.of<AppProvider>(context, listen: false).inventory;
    _results = RecommendationService.instance.getRecommendations(
      gigType: widget.gig.type,
      gigSize: widget.gig.size,
      gigLocation: widget.gig.location,
      inventory: inventory,
      template: widget.template,
    );
    _selectedIndices = Set.from(List.generate(_results.length, (i) => i));
  }

  // Group by category
  Map<String, List<(int, RecommendationResult)>> get _grouped {
    final map = <String, List<(int, RecommendationResult)>>{};
    for (var i = 0; i < _results.length; i++) {
      final r = _results[i];
      map.putIfAbsent(r.category, () => []).add((i, r));
    }
    return map;
  }

  int get _selectedCount => _selectedIndices.length;

  void _addToChecklist() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final selected =
        _selectedIndices.map((i) => _results[i]).toList();
    final items = RecommendationService.instance.toChecklistItems(
      gigId: widget.gig.id,
      results: selected,
    );
    provider.addItemsToGigChecklist(widget.gig.id, items);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GigChecklistScreen(gig: widget.gig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final templateName = widget.template?.name ??
        '${widget.gig.type} · ${widget.gig.size} · ${widget.gig.location}';

    final inInventoryCount = _results.where((r) => r.inInventory).length;
    final missingCount = _results.length - inInventoryCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Kit'),
      ),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: StitchTheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.gig.name,
                  style:
                      StitchTheme.headlineMd(context).copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(templateName, style: StitchTheme.bodyMd(context)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Pill(
                      icon: Icons.check_circle_outline,
                      label: '$inInventoryCount in inventory',
                      color: StitchTheme.success,
                    ),
                    const SizedBox(width: 8),
                    if (missingCount > 0)
                      _Pill(
                        icon: Icons.radio_button_unchecked,
                        label: '$missingCount missing',
                        color: StitchTheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: StitchTheme.outlineVariant),

          // ── Item list ─────────────────────────────────────────────────────
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      'No suggestions available for this gig type.',
                      style: StitchTheme.bodyLg(context),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 6),
                          child: Text(entry.key,
                              style: StitchTheme.labelCaps(context)),
                        ),
                        for (final (index, result) in entry.value)
                          _SuggestionRow(
                            result: result,
                            selected: _selectedIndices.contains(index),
                            onChanged: (val) {
                              setState(() {
                                if (val) {
                                  _selectedIndices.add(index);
                                } else {
                                  _selectedIndices.remove(index);
                                }
                              });
                            },
                          ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
          ),

          // ── Bottom bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: StitchTheme.surfaceContainerLowest,
              border:
                  Border(top: BorderSide(color: StitchTheme.outlineVariant)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedCount > 0 ? _addToChecklist : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchTheme.primary,
                  foregroundColor: StitchTheme.onPrimary,
                  disabledBackgroundColor:
                      StitchTheme.surfaceContainerHigh,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  _selectedCount > 0
                      ? 'Add $_selectedCount items to checklist'
                      : 'Select at least one item',
                  style: StitchTheme.headlineMd(context).copyWith(
                    color: _selectedCount > 0
                        ? StitchTheme.onPrimary
                        : StitchTheme.outline,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion row ────────────────────────────────────────────────────────────

class _SuggestionRow extends StatelessWidget {
  final RecommendationResult result;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _SuggestionRow({
    required this.result,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inInv = result.inInventory;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: StitchTheme.cardDecoration,
      child: CheckboxListTile(
        value: selected,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: StitchTheme.primary,
        checkColor: StitchTheme.onPrimary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          result.name,
          style: StitchTheme.headlineMd(context).copyWith(fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Icon(
              inInv ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              size: 12,
              color: inInv ? StitchTheme.success : StitchTheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }
}

// ── Small pill chip ───────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: StitchTheme.labelCaps(context)
              .copyWith(color: color, fontSize: 10),
        ),
      ],
    );
  }
}
