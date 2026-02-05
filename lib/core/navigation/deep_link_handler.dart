import 'package:flutter/material.dart';

import '../../features/customers/presentation/screens/customer_detail_screen.dart';

class DeepLinkHandler {
  static bool canHandle(String? deepLink) {
    if (deepLink == null) return false;
    final trimmed = deepLink.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.startsWith('/');
  }

  static bool handle(BuildContext context, String deepLink) {
    final uri = Uri.tryParse(deepLink.trim());
    if (uri == null) return false;

    // Supported:
    // - /customers/:id
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'customers') {
      final customerId = uri.pathSegments[1];
      if (customerId.isEmpty) return false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerDetailScreen(customerId: customerId),
        ),
      );
      return true;
    }

    return false;
  }
}

