import 'package:flutter/material.dart';

class SupabaseInitErrorScreen extends StatelessWidget {
  const SupabaseInitErrorScreen({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khởi tạo thất bại')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Không thể khởi tạo Supabase.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy kiểm tra `SUPABASE_URL` / `SUPABASE_ANON_KEY` và thử lại.',
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
