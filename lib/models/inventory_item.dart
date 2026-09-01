class InventoryItem {
  final String id;
  final String name;
  final String category; // Cameras, Lenses, Audio, Lighting, Power, Accessories, Tools, Other
  final int quantity;
  final String? brand;
  final String? notes;
  final String? serialNumber;
  final String rentalStatus; // Available, Rented Out, Unavailable, Maintenance
  final String? activeRentalId;
  final DateTime createdAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.brand,
    this.notes,
    this.serialNumber,
    this.rentalStatus = 'Available',
    this.activeRentalId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? brand,
    String? notes,
    String? serialNumber,
    String? rentalStatus,
    String? activeRentalId,
    bool clearActiveRentalId = false,
    DateTime? createdAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      serialNumber: serialNumber ?? this.serialNumber,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      activeRentalId: clearActiveRentalId ? null : (activeRentalId ?? this.activeRentalId),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'brand': brand,
      'notes': notes,
      'serialNumber': serialNumber,
      'rentalStatus': rentalStatus,
      'activeRentalId': activeRentalId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'] ?? 1,
      brand: json['brand'],
      notes: json['notes'],
      serialNumber: json['serialNumber'],
      rentalStatus: json['rentalStatus'] ?? json['status'] ?? 'Available', // fallback to old status field
      activeRentalId: json['activeRentalId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
