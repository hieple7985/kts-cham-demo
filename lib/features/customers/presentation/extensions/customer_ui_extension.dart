import 'package:flutter/material.dart';
import '../../domain/models/customer_model.dart';

extension CustomerStageExtension on CustomerStage {
  Color get stageColor {
    switch (this) {
      case CustomerStage.receiveInfo:
        return Colors.blue;
      case CustomerStage.haveNeeds:
        return Colors.cyan;
      case CustomerStage.research:
        return Colors.orange;
      case CustomerStage.explosionPoint:
        return Colors.deepOrange;
      case CustomerStage.sales:
        return Colors.green;
      case CustomerStage.afterSales:
        return Colors.purple;
      case CustomerStage.repeat:
        return Colors.teal;
      case CustomerStage.lost:
        return Colors.grey;
    }
  }

  String get stageName {
    switch (this) {
      case CustomerStage.receiveInfo:
        return 'Nhận tin';
      case CustomerStage.haveNeeds:
        return 'Có nhu cầu';
      case CustomerStage.research:
        return 'Tìm hiểu';
      case CustomerStage.explosionPoint:
        return 'Bùng nổ';
      case CustomerStage.sales:
        return 'Chốt đơn';
      case CustomerStage.afterSales:
        return 'CSKH';
      case CustomerStage.repeat:
        return 'Mua lại';
      case CustomerStage.lost:
        return 'Đã mất';
    }
  }
}

extension InteractionTypeExtension on InteractionType {
  IconData get icon {
    switch (this) {
      case InteractionType.call:
        return Icons.call;
      case InteractionType.message:
        return Icons.message;
      case InteractionType.zalo:
        return Icons.chat_bubble;
      case InteractionType.facebook:
        return Icons.facebook;
      case InteractionType.meeting:
        return Icons.people;
      case InteractionType.note:
        return Icons.note;
    }
  }

  Color get color {
    switch (this) {
      case InteractionType.call:
        return Colors.green;
      case InteractionType.message:
        return Colors.blue;
      case InteractionType.zalo:
        return Colors.blueAccent;
      case InteractionType.facebook:
        return Colors.indigo;
      case InteractionType.meeting:
        return Colors.orange;
      case InteractionType.note:
        return Colors.amber;
    }
  }

  String get label {
    switch (this) {
      case InteractionType.call:
        return 'Gọi điện';
      case InteractionType.message:
        return 'Tin nhắn';
      case InteractionType.zalo:
        return 'Zalo';
      case InteractionType.facebook:
        return 'Facebook';
      case InteractionType.meeting:
        return 'Gặp mặt';
      case InteractionType.note:
        return 'Ghi chú';
    }
  }
}
