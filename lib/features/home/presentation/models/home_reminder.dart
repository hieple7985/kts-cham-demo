import 'package:flutter/material.dart';

enum ReminderStage { hot, warm, cold, care }

enum ReminderStatus { pending, done, skipped }

class HomeReminder {
  HomeReminder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.stage,
    required this.reason,
    required this.dueAt,
    this.status = ReminderStatus.pending,
    this.deepLink,
  });

  final String id;
  final String customerId;
  final String customerName;
  final ReminderStage stage;
  final String reason;
  final DateTime dueAt;
  final ReminderStatus status;
  final String? deepLink;

  HomeReminder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    ReminderStage? stage,
    String? reason,
    DateTime? dueAt,
    ReminderStatus? status,
    String? deepLink,
  }) {
    return HomeReminder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      stage: stage ?? this.stage,
      reason: reason ?? this.reason,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      deepLink: deepLink ?? this.deepLink,
    );
  }

  String get stageLabel {
    switch (stage) {
      case ReminderStage.hot:
        return 'Hot';
      case ReminderStage.warm:
        return 'Warm';
      case ReminderStage.cold:
        return 'Cold';
      case ReminderStage.care:
        return 'Care';
    }
  }

  Color get stageColor {
    switch (stage) {
      case ReminderStage.hot:
        return Colors.red;
      case ReminderStage.warm:
        return Colors.orange;
      case ReminderStage.cold:
        return Colors.blueGrey;
      case ReminderStage.care:
        return Colors.green;
    }
  }
}
