import 'checklist_item.dart';

class Gig {
  final String id;
  final String name;
  final String type; // Photography, Video, Audio, Livestream, Event, Other
  final String date;
  final String location; // Indoor, Outdoor, Both, or custom location string
  final String size; // Small, Medium, Large
  String status; // IN PREP, READY, COMPLETED
  final List<ChecklistItem> items;
  final DateTime createdAt;

  Gig({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.location,
    required this.size,
    this.status = 'IN PREP',
    List<ChecklistItem>? items,
    DateTime? createdAt,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now();

  Gig copyWith({
    String? id,
    String? name,
    String? type,
    String? date,
    String? location,
    String? size,
    String? status,
    List<ChecklistItem>? items,
    DateTime? createdAt,
  }) {
    return Gig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      location: location ?? this.location,
      size: size ?? this.size,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get totalItems => items.length;
  int get packedItems => items.where((item) => item.packed).length;
  int get missingItemsCount => items.where((item) => item.isMissingFromInventory && !item.packed).length;
  double get progressPercentage => totalItems > 0 ? (packedItems / totalItems) : 0.0;
  bool get isReady => totalItems > 0 && packedItems == totalItems;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date,
      'location': location,
      'size': size,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Gig.fromJson(Map<String, dynamic> json) {
    return Gig(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      date: json['date'],
      location: json['location'],
      size: json['size'],
      status: json['status'] ?? 'IN PREP',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ChecklistItem.fromJson(item))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
