import 'dart:async';

/// Mock AI Service for demo purposes
/// Simulates Gemini 3 AI responses for customer analysis
class MockAiService {
  // Singleton
  static final MockAiService _instance = MockAiService._internal();
  factory MockAiService() => _instance;
  MockAiService._internal();

  /// Simulates AI chat analysis response
  /// In production, this calls Supabase edge function 'ai-chat-analysis'
  Future<Map<String, dynamic>> analyzeCustomerChat({
    required String customerId,
    bool force = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    // Return mock analysis data
    return {
      'session_id': 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
      'model_name': 'gemini-3-flash-demo',
      'created': [
        {
          'id': 'analysis-${DateTime.now().millisecondsSinceEpoch}',
          'model_name': 'gemini-3-flash-demo',
          'created_at': DateTime.now().toIso8601String(),
        }
      ],
      'analyses': [
        {
          'id': 'analysis-sentiment-${DateTime.now().millisecondsSinceEpoch}',
          'analysis_type': 'sentiment',
          'output_data': {
            'overall_sentiment': _getRandomSentiment(),
            'sentiment_score': (_getRandomScore() * 100).toInt() / 100,
            'sentiment_trend': _getRandomTrend(),
            'key_positive_phrases': _getPositivePhrases(),
            'key_negative_phrases': _getNegativePhrases(),
            'confidence': 0.85 + (_getRandomScore() * 0.14),
          },
          'feedback': null,
        },
        {
          'id': 'analysis-intent-${DateTime.now().millisecondsSinceEpoch}',
          'analysis_type': 'intent',
          'output_data': {
            'primary_intent': _getRandomIntent(),
            'secondary_intents': _getSecondaryIntents(),
            'buying_signals': _getBuyingSignals(),
            'urgency_level': _getUrgencyLevel(),
            'next_best_action': _getNextBestAction(),
          },
          'feedback': null,
        },
        {
          'id': 'analysis-summary-${DateTime.now().millisecondsSinceEpoch}',
          'analysis_type': 'summary',
          'output_data': {
            'conversation_summary': _getSummary(),
            'key_topics_discussed': _getKeyTopics(),
            'customer_concerns': _getConcerns(),
            'mentioned_products': _getProducts(),
            'estimated_budget_range': _getBudgetRange(),
          },
          'feedback': null,
        },
        {
          'id': 'analysis-recommendation-${DateTime.now().millisecondsSinceEpoch}',
          'analysis_type': 'recommendation',
          'output_data': {
            'recommended_followup_time': _getFollowupTime(),
            'recommended_channel': _getChannel(),
            'suggested_talking_points': _getTalkingPoints(),
            'recommended_content': _getRecommendedContent(),
            'likelihood_to_close': _getCloseLikelihood(),
          },
          'feedback': null,
        },
      ],
    };
  }

  /// Simulates AI insights for home screen
  Future<List<Map<String, dynamic>>> getHomeInsights({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      {
        'id': 'insight-1',
        'type': 'high_potential_customer',
        'title': 'Khách hàng tiềm năng cao',
        'description': 'Anh Nguyễn Văn A đang tích cực hỏi về căn 3PN',
        'priority': 'high',
        'customer_id': '1',
        'customer_name': 'Nguyễn Văn A',
        'action_required': 'Gọi ngay trong hôm nay',
        'due_date': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'id': 'insight-2',
        'type': 'followup_reminder',
        'title': 'Nhắc lịch chăm sóc',
        'description': '3 khách hàng cần chăm sóc trong tuần này',
        'priority': 'medium',
        'customers': [
          {'id': '2', 'name': 'Trần Thị B', 'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String()},
          {'id': '3', 'name': 'Lê Văn C', 'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String()},
          {'id': '4', 'name': 'Phạm Thị D', 'due_date': DateTime.now().add(const Duration(days: 3)).toIso8601String()},
        ],
      },
      {
        'id': 'insight-3',
        'type': 'ai_tip',
        'title': 'Gợi ý từ AI',
        'description': 'Khách hàng ở giai đoạn "explosion_point" thường phản hồi tốt vào buổi tối',
        'priority': 'low',
      },
    ];
  }

  /// Simulates AI chatbot response for CUCA chat
  Future<String> getChatResponse({
    required String message,
    required List<Map<String, dynamic>> context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final lowerMessage = message.toLowerCase();

    // Simple pattern matching for demo
    if (lowerMessage.contains('khách') && lowerMessage.contains('tiềm năng')) {
      return 'Dựa trên phân tích của tôi, bạn có 5 khách hàng tiềm năng cao cần ưu tiên chăm sóc trong tuần này:\n\n1. Nguyễn Văn A - Đã thể hiện tín hiệu mua mạnh\n2. Bùi Thị H - Cần liên hệ gấp hôm nay\n3. Phạm Thị D - VIP, đã mua và có thể giới thiệu\n\nBạn có muốn tôi phân tích chi tiết khách hàng nào không?';
    }

    if (lowerMessage.contains('lịch') || lowerMessage.contains('hẹn')) {
      return 'Dưới đây là lịch chăm sóc khách hàng sắp tới:\n\n• Hôm nay: 2 khách cần gọi\n• Ngày mai: 1 customer cần gửi tin\n• Thứ Tư: 1 buổi hẹn trực tiếp\n\nBạn có muốn tôi lên lịch chăm sóc chi tiết không?';
    }

    if (lowerMessage.contains('phân tích') || lowerMessage.contains('analyze')) {
      return 'Tôi có thể giúp bạn phân tích:\n\n1. Phân tích cảm xúc khách hàng từ tin nhắn\n2. Phân tích ý định mua hàng\n3. Tổng hợp nội dung cuộc trò chuyện\n4. Đề xuất hành động tiếp theo\n\nBạn cần phân tích loại nào?';
    }

    if (lowerMessage.contains('gợi ý') || lowerMessage.contains('recommend')) {
      return 'Dựa trên dữ liệu khách hàng của bạn, tôi có một số gợi ý:\n\n1. Nhóm khách VIP: Nên chăm sóc định kỳ 2 tuần/lần\n2. Khách ở giai đoạn explosion_point: Nên liên hệ trong 24h\n3. Khách mới: Gửi tài liệu hướng dẫn trong 1-2 ngày\n\nBạn muốn tôi chi tiết hóa gợi ý nào?';
    }

    // Default response
    return [
      'Cảm ơn bạn đã hỏi. Tôi có thể giúp bạn phân tích dữ liệu khách hàng, gợi ý lịch chăm sóc, và đưa ra các phân tích AI về tin nhắn trò chuyện.',
      'Tôi hiểu. Bạn có muốn tôi phân tích khách hàng tiềm năng hay lên lịch chăm sóc không?',
      'Để tôi phân tích... Dựa trên dữ liệu hiện tại, tôi khuyên bạn nên ưu tiên chăm sóc nhóm khách VIP trước.',
      'Tôi có thể giúp gì cho bạn về quản lý khách hàng hôm nay?',
    ][(DateTime.now().millisecondsSinceEpoch) % 4];
  }

  // Helper methods for generating mock data

  String _getRandomSentiment() {
    final sentiments = ['positive', 'neutral', 'negative', 'mixed'];
    return sentiments[DateTime.now().millisecondsSinceEpoch % sentiments.length];
  }

  double _getRandomScore() {
    return (DateTime.now().millisecondsSinceEpoch % 100) / 100;
  }

  String _getRandomTrend() {
    final trends = ['improving', 'stable', 'declining'];
    return trends[DateTime.now().millisecondsSinceEpoch % trends.length];
  }

  List<String> _getPositivePhrases() {
    return [
      'quan tâm', 'thích', 'muốn biết thêm', 'lịch hẹn',
      'nhưng giá', 'chốt căn', 'thuận tiện', 'hài lòng'
    ];
  }

  List<String> _getNegativePhrases() {
    return [
      'đắt quá', 'chưa quyết định', 'cần cân nhắc',
      'xa trung tâm', 'thôi để sau', 'chưa sẵn sàng'
    ];
  }

  String _getRandomIntent() {
    final intents = ['purchase_inquiry', 'information_seeking', 'complaint', 'support_request'];
    return intents[DateTime.now().millisecondsSinceEpoch % intents.length];
  }

  List<String> _getSecondaryIntents() {
    return ['price_comparison', 'location_inquiry'];
  }

  List<String> _getBuyingSignals() {
    return [
      'Hỏi về chính sách trả góp',
      'Yêu cầu xem căn mẫu',
      'Hỏi về tiến độ bàn giao',
      'Đề nghị gặp tư vấn trực tiếp'
    ];
  }

  String _getUrgencyLevel() {
    final levels = ['high', 'medium', 'low'];
    return levels[DateTime.now().millisecondsSinceEpoch % levels.length];
  }

  String _getNextBestAction() {
    final actions = [
      'Gọi điện tư vấn trực tiếp',
      'Gửi tài liệu chi tiết qua email',
      'Hẹn lịch xem căn mẫu',
      'Mời tham gia sự kiện tại dự án'
    ];
    return actions[DateTime.now().millisecondsSinceEpoch % actions.length];
  }

  String _getSummary() {
    final summaries = [
      'Khách hàng đang quan tâm đến căn 3PN tại tầng trung. Đã hỏi về giá và chính sách trả góp. Cần thúc đẩy để chốt lịch xem căn mẫu.',
      'Khách hàng mới tìm hiểu, đã nhận thông tin cơ bản. Đang so sánh với một số dự án khác. Cần nhấn mạnh ưu điểm cạnh tranh.',
      'Khách VIP đã mua căn A1-05. Đang hoàn tất thủ tục. Rất hài lòng với dịch vụ, có thể giới thiệu khách mới.',
    ];
    return summaries[DateTime.now().millisecondsSinceEpoch % summaries.length];
  }

  List<String> _getKeyTopics() {
    return ['giá cả', 'vị trí', 'tiện ích', 'tiến độ', 'chính sách thanh toán'];
  }

  List<String> _getConcerns() {
    return ['giá cả', 'khoảng cách trung tâm', 'chính sách bảo hành'];
  }

  List<String> _getProducts() {
    return ['căn 3PN', 'căn 2PN', 'căn duplex', 'shophouse'];
  }

  String _getBudgetRange() {
    final ranges = ['3-5 tỷ', '5-7 tỷ', '7-10 tỷ', 'trên 10 tỷ'];
    return ranges[DateTime.now().millisecondsSinceEpoch % ranges.length];
  }

  String _getFollowupTime() {
    final times = ['sáng mai', 'chiều nay', 'ngày mai', '2 ngày nữa'];
    return times[DateTime.now().millisecondsSinceEpoch % times.length];
  }

  String _getChannel() {
    final channels = ['phone_call', 'zalo', 'email', 'in_person'];
    return channels[DateTime.now().millisecondsSinceEpoch % channels.length];
  }

  List<String> _getTalkingPoints() {
    return [
      'Giới thiệu ưu điểm vị trí gần metro',
      'Khoe tiện ích nội khu đầy đủ',
      'Mention chính sách ưu đãi tháng này',
      'Mời tham gia event cuối tuần'
    ];
  }

  String _getRecommendedContent() {
    final contents = [
      'Brochure dự án và bảng giá chi tiết',
      'Video tour căn mẫu',
      'Bản đồ quy hoạch vùng',
      'Chính sách khuyến mãi và ưu đãi'
    ];
    return contents[DateTime.now().millisecondsSinceEpoch % contents.length];
  }

  String _getCloseLikelihood() {
    final likelihoods = ['high', 'medium', 'low'];
    return likelihoods[DateTime.now().millisecondsSinceEpoch % likelihoods.length];
  }
}
