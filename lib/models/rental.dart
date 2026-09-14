class Rental {
  final String id;
  final String customerName;
  final String customerContact;
  final String startDate; // Simplified as string for UI display (e.g. "Oct 12")
  final String expectedReturnDate;
  final String status; // 'Pending', 'Active', 'Returned', 'Declined'
  final List<String> inventoryItemIds;
  final List<String> verifiedReturnItemIds; // Items verified during check-in/return
  final String? notes;
  final String? projectShootName;
  final String bookingSource; // 'link' or 'manual'
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
    this.projectShootName,
    this.bookingSource = 'manual',
    DateTime? createdAt,
  })  : verifiedReturnItemIds = verifiedReturnItemIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isPending => status == 'Pending';
  bool get isActive => status == 'Active';
  bool get isReturned => status == 'Returned';
  bool get isDeclined => status == 'Declined';
  bool get isBookedViaLink => bookingSource == 'link';

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
    String? projectShootName,
    String? bookingSource,
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
      projectShootName: projectShootName ?? this.projectShootName,
      bookingSource: bookingSource ?? this.bookingSource,
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
      'projectShootName': projectShootName,
      'bookingSource': bookingSource,
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
      projectShootName: json['projectShootName'],
      bookingSource: json['bookingSource'] ?? 'manual',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
