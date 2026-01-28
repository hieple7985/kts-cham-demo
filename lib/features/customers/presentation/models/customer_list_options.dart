import 'package:flutter/material.dart';
import '../../domain/models/customer_model.dart';

enum CustomerListStageFilter { all, hot, warm, cold, won, lost }

enum CustomerSortOption { newest, oldest, nameAz, stale }

extension CustomerListStageFilterLabel on CustomerListStageFilter {
  String get label {
    switch (this) {
      case CustomerListStageFilter.all:
        return 'Tất cả';
      case CustomerListStageFilter.hot:
        return 'Hot';
      case CustomerListStageFilter.warm:
        return 'Warm';
      case CustomerListStageFilter.cold:
        return 'Cold';
      case CustomerListStageFilter.won:
        return 'Won';
      case CustomerListStageFilter.lost:
        return 'Lost';
    }
  }
}

extension CustomerSortOptionLabel on CustomerSortOption {
  String get label {
    switch (this) {
      case CustomerSortOption.newest:
        return 'Mới nhất';
      case CustomerSortOption.oldest:
        return 'Cũ nhất';
      case CustomerSortOption.nameAz:
        return 'Tên A–Z';
      case CustomerSortOption.stale:
        return 'Lâu chưa liên hệ';
    }
  }
}

extension CustomerListStageGroup on Customer {
  CustomerListStageFilter get listStageGroup {
    if (stage == CustomerStage.lost) return CustomerListStageFilter.lost;
    if (stage == CustomerStage.sales ||
        stage == CustomerStage.afterSales ||
        stage == CustomerStage.repeat) {
      return CustomerListStageFilter.won;
    }

    final last = lastContactDate;
    if (last != null) {
      final days = DateTime.now().difference(last).inDays;
      if (days >= 7) return CustomerListStageFilter.cold;
    }

    if (stage == CustomerStage.explosionPoint) return CustomerListStageFilter.hot;
    return CustomerListStageFilter.warm;
  }

  Color get listStageColor {
    switch (listStageGroup) {
      case CustomerListStageFilter.hot:
        return Colors.red;
      case CustomerListStageFilter.warm:
        return Colors.orange;
      case CustomerListStageFilter.cold:
        return Colors.blueGrey;
      case CustomerListStageFilter.won:
        return Colors.green;
      case CustomerListStageFilter.lost:
        return Colors.grey;
      case CustomerListStageFilter.all:
        return stageColor;
    }
  }

  String? get lastNoteSnippet {
    if (interactions.isNotEmpty) return interactions.first.content;
    return notes;
  }
}

