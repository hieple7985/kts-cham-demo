import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'node_api_client.dart';

final nodeApiClientProvider = Provider<NodeApiClient>((ref) {
  return NodeApiClient(baseUrl: AppConfig.nodeApiBaseUrl);
});

