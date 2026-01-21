import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? dateOfBirth;
  final String customerType; // vip, regular, potential
  final String customerStage; // 7 stages
  final String priority; // high, medium, low
  final List<String> tags;
  final DateTime? nextCareDate;
  final DateTime? lastContactDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.dateOfBirth,
    required this.customerType,
    required this.customerStage,
    required this.priority,
    this.tags = const [],
    this.nextCareDate,
    this.lastContactDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        email,
        address,
        dateOfBirth,
        customerType,
        customerStage,
        priority,
        tags,
        nextCareDate,
        lastContactDate,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      customerType: json['customerType'] as String,
      customerStage: json['customerStage'] as String,
      priority: json['priority'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      nextCareDate: json['nextCareDate'] != null
          ? DateTime.parse(json['nextCareDate'] as String)
          : null,
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'] as String)
          : null,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'customerType': customerType,
      'customerStage': customerStage,
      'priority': priority,
      'tags': tags,
      'nextCareDate': nextCareDate?.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? address,
    DateTime? dateOfBirth,
    String? customerType,
    String? customerStage,
    String? priority,
    List<String>? tags,
    DateTime? nextCareDate,
    DateTime? lastContactDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      customerType: customerType ?? this.customerType,
      customerStage: customerStage ?? this.customerStage,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      nextCareDate: nextCareDate ?? this.nextCareDate,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
