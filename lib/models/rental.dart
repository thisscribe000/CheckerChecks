class Rental {
  final String id;
  final String customerName;
  final String customerContact;
  final String startDate; // Simplified as string for UI display (e.g. "Oct 12")
  final String expectedReturnDate;
  final String status; // 'Active', 'Returned'
  final List<String> inventoryItemIds;
  final List<String> verifiedReturnItemIds; // Items verified during check-in/return
  final String? notes;
  final DateTime createdAt;

  Rental({
    required this.id,
    required this.customerName,
    required this.customerContact,
    required this.startDate,
    required this.expectedReturnDate,
    this.status = 'Active',
    required this.inventoryItemIds,
    List<String>? verifiedReturnItemIds,
    this.notes,
    DateTime? createdAt,
  })  : verifiedReturnItemIds = verifiedReturnItemIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isFullyVerified =>
      inventoryItemIds.isNotEmpty &&
      inventoryItemIds.every((id) => verifiedReturnItemIds.contains(id));

  int get verifiedCount => verifiedReturnItemIds.length;
  int get totalCount => inventoryItemIds.length;
  bool isItemVerified(String itemId) => verifiedReturnItemIds.contains(itemId);

  Rental copyWith({
    String? id,
    String? customerName,
    String? customerContact,
    String? startDate,
    String? expectedReturnDate,
    String? status,
    List<String>? inventoryItemIds,
    List<String>? verifiedReturnItemIds,
    String? notes,
    DateTime? createdAt,
  }) {
    return Rental(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      startDate: startDate ?? this.startDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      status: status ?? this.status,
      inventoryItemIds: inventoryItemIds ?? this.inventoryItemIds,
      verifiedReturnItemIds: verifiedReturnItemIds ?? this.verifiedReturnItemIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerContact': customerContact,
      'startDate': startDate,
      'expectedReturnDate': expectedReturnDate,
      'status': status,
      'inventoryItemIds': inventoryItemIds,
      'verifiedReturnItemIds': verifiedReturnItemIds,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      customerName: json['customerName'],
      customerContact: json['customerContact'] ?? '',
      startDate: json['startDate'],
      expectedReturnDate: json['expectedReturnDate'],
      status: json['status'] ?? 'Active',
      inventoryItemIds: List<String>.from(json['inventoryItemIds'] ?? []),
      verifiedReturnItemIds: List<String>.from(json['verifiedReturnItemIds'] ?? []),
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
