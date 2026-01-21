import 'package:flutter/material.dart';

enum CustomerStage {
  receiveInfo,
  haveNeeds,
  research,
  explosionPoint,
  sales,
  afterSales,
  repeat,
  lost,
}

enum InteractionType {
  call,
  message,
  zalo,
  facebook,
  meeting,
  note,
}

enum TransactionStatus { pending, won, lost }

class StageChange {
  final String id;
  final CustomerStage from;
  final CustomerStage to;
  final String? reason;
  final DateTime timestamp;

  StageChange({
    required this.id,
    required this.from,
    required this.to,
    required this.timestamp,
    this.reason,
  });
}

class TransactionEntry {
  final String id;
  final String title;
  final int amountVnd;
  final TransactionStatus status;
  final DateTime date;
  final String? note;

  TransactionEntry({
    required this.id,
    required this.title,
    required this.amountVnd,
    required this.status,
    required this.date,
    this.note,
  });
}

enum AiMessageRole { user, assistant }

class AiChatMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;

  AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class Interaction {
  final String id;
  final InteractionType type;
  final String content;
  final DateTime timestamp;

  Interaction({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
  });

  // Helper icon
  IconData get icon {
    switch (type) {
      case InteractionType.call: return Icons.call;
      case InteractionType.message: return Icons.message;
      case InteractionType.zalo: return Icons.chat_bubble; // Zalo icon placeholder
      case InteractionType.facebook: return Icons.facebook;
      case InteractionType.meeting: return Icons.people;
      case InteractionType.note: return Icons.note;
    }
  }

  // Helper color
  Color get color {
    switch (type) {
      case InteractionType.call: return Colors.green;
      case InteractionType.message: return Colors.blue;
      case InteractionType.zalo: return Colors.blueAccent;
      case InteractionType.facebook: return Colors.indigo;
      case InteractionType.meeting: return Colors.orange;
      case InteractionType.note: return Colors.amber;
    }
  }
}

class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final List<String> additionalPhones; // SĐT phụ
  final String? email;
  final String? avatarUrl;
  final CustomerStage stage;
  final List<String> tags;
  final String? source;
  final String? notes; // Ghi chú chung
  final String? zaloLink; // Link Zalo
  final String? facebookLink; // Link FB
  final DateTime? lastContactDate;
  final DateTime? nextCareDate;
  final double? totalSpent; // backend: total_spent
  final DateTime? lastPurchaseDate; // backend: last_purchase_date (date)
  final bool isDemo;
  final List<Interaction> interactions; // Lịch sử tương tác
  final List<StageChange> stageHistory;
  final List<TransactionEntry> transactions;
  final List<AiChatMessage> aiChat;

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.additionalPhones = const [],
    this.email,
    this.avatarUrl,
    this.stage = CustomerStage.receiveInfo,
    this.tags = const [],
    this.source,
    this.notes,
    this.zaloLink,
    this.facebookLink,
    this.lastContactDate,
    this.nextCareDate,
    this.totalSpent,
    this.lastPurchaseDate,
    this.isDemo = false,
    this.interactions = const [],
    this.stageHistory = const [],
    this.transactions = const [],
    this.aiChat = const [],
  });

  Color get stageColor {
    switch (stage) {
      case CustomerStage.receiveInfo: return Colors.blue;
      case CustomerStage.haveNeeds: return Colors.cyan;
      case CustomerStage.research: return Colors.orange;
      case CustomerStage.explosionPoint: return Colors.deepOrange;
      case CustomerStage.sales: return Colors.green;
      case CustomerStage.afterSales: return Colors.purple;
      case CustomerStage.repeat: return Colors.teal;
      case CustomerStage.lost: return Colors.grey;
    }
  }

  String get stageName {
    switch (stage) {
      case CustomerStage.receiveInfo: return 'Nhận tin';
      case CustomerStage.haveNeeds: return 'Có nhu cầu';
      case CustomerStage.research: return 'Tìm hiểu';
      case CustomerStage.explosionPoint: return 'Bùng nổ';
      case CustomerStage.sales: return 'Chốt đơn';
      case CustomerStage.afterSales: return 'CSKH';
      case CustomerStage.repeat: return 'Mua lại';
      case CustomerStage.lost: return 'Đã mất';
    }
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    List<String>? additionalPhones,
    String? email,
    String? avatarUrl,
    CustomerStage? stage,
    List<String>? tags,
    String? source,
    String? notes,
    String? zaloLink,
    String? facebookLink,
    DateTime? lastContactDate,
    DateTime? nextCareDate,
    double? totalSpent,
    DateTime? lastPurchaseDate,
    bool? isDemo,
    List<Interaction>? interactions,
    List<StageChange>? stageHistory,
    List<TransactionEntry>? transactions,
    List<AiChatMessage>? aiChat,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalPhones: additionalPhones ?? this.additionalPhones,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stage: stage ?? this.stage,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      zaloLink: zaloLink ?? this.zaloLink,
      facebookLink: facebookLink ?? this.facebookLink,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      nextCareDate: nextCareDate ?? this.nextCareDate,
      totalSpent: totalSpent ?? this.totalSpent,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      isDemo: isDemo ?? this.isDemo,
      interactions: interactions ?? this.interactions,
      stageHistory: stageHistory ?? this.stageHistory,
      transactions: transactions ?? this.transactions,
      aiChat: aiChat ?? this.aiChat,
    );
  }
}
