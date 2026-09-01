class ChecklistItem {
  final String id;
  final String gigId;
  final String name;
  final String category; // CAMERA, LENSES, AUDIO, LIGHTING, POWER, ACCESSORIES, TOOLS, OTHER
  final String? inventoryItemId;
  final String source; // manual, template, AI
  final bool required;
  bool packed;
  bool isMissingFromInventory;
  final String? specDetail;

  ChecklistItem({
    required this.id,
    required this.gigId,
    required this.name,
    required this.category,
    this.inventoryItemId,
    this.source = 'manual',
    this.required = true,
    this.packed = false,
    this.isMissingFromInventory = false,
    this.specDetail,
  });

  ChecklistItem copyWith({
    String? id,
    String? gigId,
    String? name,
    String? category,
    String? inventoryItemId,
    String? source,
    bool? required,
    bool? packed,
    bool? isMissingFromInventory,
    String? specDetail,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      gigId: gigId ?? this.gigId,
      name: name ?? this.name,
      category: category ?? this.category,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      source: source ?? this.source,
      required: required ?? this.required,
      packed: packed ?? this.packed,
      isMissingFromInventory: isMissingFromInventory ?? this.isMissingFromInventory,
      specDetail: specDetail ?? this.specDetail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'name': name,
      'category': category,
      'inventoryItemId': inventoryItemId,
      'source': source,
      'required': required,
      'packed': packed,
      'isMissingFromInventory': isMissingFromInventory,
      'specDetail': specDetail,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      gigId: json['gigId'],
      name: json['name'],
      category: json['category'],
      inventoryItemId: json['inventoryItemId'],
      source: json['source'] ?? 'manual',
      required: json['required'] ?? true,
      packed: json['packed'] ?? false,
      isMissingFromInventory: json['isMissingFromInventory'] ?? false,
      specDetail: json['specDetail'],
    );
  }
}
