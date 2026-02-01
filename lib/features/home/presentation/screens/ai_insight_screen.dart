import 'package:flutter/material.dart';
import '../../../customers/domain/models/customer_model.dart';

class AiInsightScreen extends StatelessWidget {
  const AiInsightScreen({super.key, required this.customers});

  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final coldCustomers = customers
        .where((c) => c.lastContactDate != null)
        .where((c) => DateTime.now().difference(c.lastContactDate!).inDays >= 7)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('CUCA Insight')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tổng số khách: ${customers.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tính năng phân tích chi tiết đang phát triển.',
          ),
          const SizedBox(height: 16),
          if (coldCustomers.isEmpty)
            const Text('Không có khách "nguội".')
          else ...[
            const Text('Danh sách khách “nguội”:'),
            const SizedBox(height: 8),
            for (final c in coldCustomers)
              ListTile(
                leading: CircleAvatar(child: Text(c.fullName.isNotEmpty ? c.fullName[0] : '?')),
                title: Text(c.fullName),
                subtitle: Text('SĐT: ${c.phoneNumber}'),
              ),
          ],
        ],
      ),
    );
  }
}

