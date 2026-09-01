import '../models/checklist_item.dart';
import '../models/inventory_item.dart';

/// A single recommended item with inventory match info.
class RecommendationResult {
  final String name;
  final String category;
  final String? inventoryItemId;
  final bool inInventory;
  final String source; // 'template' or 'rule'

  const RecommendationResult({
    required this.name,
    required this.category,
    this.inventoryItemId,
    required this.inInventory,
    this.source = 'template',
  });
}

/// A gig kit template with categorised checklist items.
class GigTemplate {
  final String id;
  final String name;
  final String gigType; // Photography, Video, Audio, Livestream, Event
  final String description;
  final Map<String, List<String>> items; // category -> item names

  const GigTemplate({
    required this.id,
    required this.name,
    required this.gigType,
    required this.description,
    required this.items,
  });
}

/// Abstract interface for recommendation providers.
/// Swap the implementation to plug in an AI backend later.
abstract class RecommendationProvider {
  /// Returns AI/template-generated recommendations for the given gig parameters.
  List<RecommendationResult> recommend({
    required String gigType,
    required String gigSize,
    required String gigLocation,
    required List<InventoryItem> inventory,
    GigTemplate? template,
  });
}

/// All built-in templates.
const List<GigTemplate> kGigTemplates = [
  // ── PHOTOGRAPHY ──────────────────────────────────────────────────────────
  GigTemplate(
    id: 'tpl-photo-wedding',
    name: 'Wedding Photography',
    gigType: 'Photography',
    description: 'Full-day wedding coverage — ceremony, portraits & reception.',
    items: {
      'CAMERA': ['Camera body', 'Standard zoom lens', 'Portrait lens', 'Spare battery', 'Memory cards'],
      'SUPPORT': ['Tripod'],
      'LIGHTING': ['Flash', 'Light stand'],
      'POWER': ['Battery charger', 'Extension cable'],
      'ACCESSORIES': ['Camera bag', 'Cleaning cloth'],
    },
  ),
  GigTemplate(
    id: 'tpl-photo-portrait',
    name: 'Portrait Shoot',
    gigType: 'Photography',
    description: 'Studio or location portrait session.',
    items: {
      'CAMERA': ['Camera body', 'Portrait lens', 'Spare battery', 'Memory cards'],
      'LIGHTING': ['LED light', 'Reflector'],
      'SUPPORT': ['Tripod'],
      'ACCESSORIES': ['Camera bag'],
    },
  ),
  GigTemplate(
    id: 'tpl-photo-event',
    name: 'Event Photography',
    gigType: 'Photography',
    description: 'Birthday, corporate or social event coverage.',
    items: {
      'CAMERA': ['Camera body', 'Standard zoom lens', 'Spare battery', 'Memory cards'],
      'LIGHTING': ['Flash'],
      'ACCESSORIES': ['Camera bag', 'Extra memory card'],
    },
  ),
  GigTemplate(
    id: 'tpl-photo-corporate',
    name: 'Corporate Photography',
    gigType: 'Photography',
    description: 'Headshots, team photos and product photography.',
    items: {
      'CAMERA': ['Camera body', 'Portrait lens', 'Standard zoom lens', 'Spare battery', 'Memory cards'],
      'LIGHTING': ['LED light', 'Light stand', 'Reflector'],
      'SUPPORT': ['Tripod'],
      'ACCESSORIES': ['Camera bag', 'Backdrop'],
    },
  ),

  // ── VIDEO ─────────────────────────────────────────────────────────────────
  GigTemplate(
    id: 'tpl-video-wedding',
    name: 'Wedding Video',
    gigType: 'Video',
    description: 'Full wedding day video production.',
    items: {
      'CAMERA': ['Camera body', 'Standard zoom lens', 'Portrait lens', 'Spare battery', 'Memory cards'],
      'AUDIO': ['Wireless microphone', 'Lapel microphone'],
      'SUPPORT': ['Tripod', 'Gimbal stabiliser'],
      'POWER': ['Battery charger', 'V-mount battery', 'Extension cable'],
      'ACCESSORIES': ['ND filter set', 'Camera bag'],
    },
  ),
  GigTemplate(
    id: 'tpl-video-interview',
    name: 'Interview',
    gigType: 'Video',
    description: 'Single or multi-camera interview setup.',
    items: {
      'CAMERA': ['Camera body', 'Standard zoom lens', 'Spare battery', 'Memory cards'],
      'AUDIO': ['Wireless microphone', 'Boom pole'],
      'LIGHTING': ['LED light', 'Light stand', 'Reflector'],
      'SUPPORT': ['Tripod'],
      'ACCESSORIES': ['Headphones'],
    },
  ),
  GigTemplate(
    id: 'tpl-video-content',
    name: 'Content Shoot',
    gigType: 'Video',
    description: 'Social media and online content production.',
    items: {
      'CAMERA': ['Camera body', 'Wide lens', 'Spare battery', 'Memory cards'],
      'AUDIO': ['Wireless microphone'],
      'LIGHTING': ['LED light'],
      'SUPPORT': ['Tripod'],
    },
  ),
  GigTemplate(
    id: 'tpl-video-event',
    name: 'Event Video',
    gigType: 'Video',
    description: 'Multi-camera event video production.',
    items: {
      'CAMERA': ['Camera body (x2)', 'Standard zoom lens', 'Spare battery (x2)', 'Memory cards (x4)'],
      'AUDIO': ['Wireless microphone', 'Audio recorder'],
      'SUPPORT': ['Tripod (x2)', 'Slider'],
      'POWER': ['Battery charger', 'Extension cable', 'Power strip'],
      'ACCESSORIES': ['Headphones', 'Hard drive'],
    },
  ),

  // ── AUDIO ─────────────────────────────────────────────────────────────────
  GigTemplate(
    id: 'tpl-audio-podcast',
    name: 'Podcast Recording',
    gigType: 'Audio',
    description: 'Studio or remote podcast session.',
    items: {
      'AUDIO': ['Microphone', 'Audio interface', 'Headphones', 'Pop filter'],
      'POWER': ['Extension cable', 'Power strip'],
      'ACCESSORIES': ['Mic stand', 'Cables'],
    },
  ),
  GigTemplate(
    id: 'tpl-audio-event',
    name: 'Small Event Audio',
    gigType: 'Audio',
    description: 'Live sound reinforcement for small events.',
    items: {
      'AUDIO': ['Wireless microphone', 'Mixer / PA', 'Speakers', 'Audio cables', 'Headphones'],
      'POWER': ['Extension cable', 'Power strip'],
      'ACCESSORIES': ['Mic stands', 'Cable ties', 'Gaffer tape'],
    },
  ),
  GigTemplate(
    id: 'tpl-audio-church',
    name: 'Church Service',
    gigType: 'Audio',
    description: 'Church service audio with multiple inputs.',
    items: {
      'AUDIO': ['Wireless microphone (x2)', 'Lapel microphone', 'Mixer', 'In-ear monitor', 'Headphones'],
      'POWER': ['Power strip', 'Extension cable'],
      'ACCESSORIES': ['Cables', 'Gaffer tape', 'Batteries'],
    },
  ),

  // ── LIVESTREAM ────────────────────────────────────────────────────────────
  GigTemplate(
    id: 'tpl-live-church',
    name: 'Church Livestream',
    gigType: 'Livestream',
    description: 'Sunday service or special event livestream.',
    items: {
      'CAMERA': ['Camera body', 'HDMI camera', 'Spare battery'],
      'SWITCHER': ['Video switcher / capture card'],
      'AUDIO': ['Wireless microphone', 'Audio interface'],
      'POWER': ['Extension cable', 'Power strip'],
      'ACCESSORIES': ['Laptop', 'HDMI cables', 'Ethernet cable'],
    },
  ),
  GigTemplate(
    id: 'tpl-live-event',
    name: 'Small Event Livestream',
    gigType: 'Livestream',
    description: 'Concert, conference or social event livestream.',
    items: {
      'CAMERA': ['Camera body', 'Standard zoom lens', 'Spare battery', 'Memory cards'],
      'SWITCHER': ['Video switcher'],
      'AUDIO': ['Wireless microphone', 'Audio mixer feed'],
      'POWER': ['Extension cable', 'Power strip', 'UPS battery'],
      'ACCESSORIES': ['Laptop', 'HDMI cables', 'Ethernet cable', 'Streaming encoder'],
    },
  ),
];

/// Rule-based size/location modifiers applied on top of template items.
class _SizeRules {
  static List<String> extras(String gigType, String size, String location) {
    final items = <String>[];
    if (size == 'Large') {
      if (gigType == 'Photography' || gigType == 'Video') {
        items.addAll(['Extra memory card', 'Spare battery', 'Second camera body']);
      }
      if (gigType == 'Audio') {
        items.add('Backup microphone');
      }
    }
    if (location == 'Outdoor' || location == 'Both') {
      if (gigType == 'Photography' || gigType == 'Video') {
        items.addAll(['ND filter', 'Rain cover', 'Reflector']);
      }
      items.add('Extension cable');
    }
    return items;
  }
}

/// Local/mock implementation. Swap for AI call in a later phase.
class LocalRecommendationProvider implements RecommendationProvider {
  @override
  List<RecommendationResult> recommend({
    required String gigType,
    required String gigSize,
    required String gigLocation,
    required List<InventoryItem> inventory,
    GigTemplate? template,
  }) {
    final results = <RecommendationResult>[];

    final GigTemplate? tpl = template ?? _defaultTemplateFor(gigType);
    if (tpl == null) return results;

    // Merge template items + size/location extras
    final Map<String, List<String>> allItems = {};
    tpl.items.forEach((cat, items) {
      allItems[cat] = List<String>.from(items);
    });

    final extras = _SizeRules.extras(gigType, gigSize, gigLocation);
    if (extras.isNotEmpty) {
      allItems['ACCESSORIES'] = [...(allItems['ACCESSORIES'] ?? []), ...extras];
    }

    allItems.forEach((cat, items) {
      for (final itemName in items) {
        final match = _matchInventory(itemName, cat, inventory);
        results.add(RecommendationResult(
          name: itemName,
          category: cat,
          inventoryItemId: match?.id,
          inInventory: match != null,
          source: 'template',
        ));
      }
    });

    return results;
  }

  GigTemplate? _defaultTemplateFor(String gigType) {
    try {
      return kGigTemplates.firstWhere((t) => t.gigType == gigType);
    } catch (_) {
      return null;
    }
  }

  /// Conservative fuzzy match — prefers reliability over aggressiveness.
  InventoryItem? _matchInventory(String itemName, String category, List<InventoryItem> inventory) {
    final nameLower = itemName.toLowerCase();
    final catLower = category.toLowerCase();

    for (final inv in inventory) {
      final invNameLower = inv.name.toLowerCase();
      final invCatLower = inv.category.toLowerCase();

      // Exact substring in either direction
      if (invNameLower.contains(nameLower) || nameLower.contains(invNameLower)) {
        return inv;
      }

      // Key word matching — only words > 3 chars
      final nameWords = nameLower.split(RegExp(r'[\s\-\/]+')).where((w) => w.length > 3);
      for (final word in nameWords) {
        if (invNameLower.contains(word)) return inv;
      }

      // Category-level match as a weak fallback
      if (invCatLower.contains(catLower) || catLower.contains(invCatLower)) {
        // Only return if name has some relationship to category
        if (nameLower.contains(invCatLower.split('s').first)) return inv;
      }
    }
    return null;
  }
}

/// Singleton facade — the rest of the app calls this.
/// To integrate a real AI: replace [LocalRecommendationProvider] with your
/// AI implementation that also extends [RecommendationProvider].
class RecommendationService {
  RecommendationService._();
  static final RecommendationService instance = RecommendationService._();

  final RecommendationProvider _provider = LocalRecommendationProvider();

  List<RecommendationResult> getRecommendations({
    required String gigType,
    required String gigSize,
    required String gigLocation,
    required List<InventoryItem> inventory,
    GigTemplate? template,
  }) {
    return _provider.recommend(
      gigType: gigType,
      gigSize: gigSize,
      gigLocation: gigLocation,
      inventory: inventory,
      template: template,
    );
  }

  /// Helper to convert results into ChecklistItems ready to persist.
  List<ChecklistItem> toChecklistItems({
    required String gigId,
    required List<RecommendationResult> results,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return results.asMap().entries.map((e) {
      final i = e.key;
      final r = e.value;
      return ChecklistItem(
        id: 'c-$ts-$i',
        gigId: gigId,
        name: r.name,
        category: r.category,
        source: r.source,
        inventoryItemId: r.inventoryItemId,
        isMissingFromInventory: !r.inInventory,
        packed: false,
      );
    }).toList();
  }
}
