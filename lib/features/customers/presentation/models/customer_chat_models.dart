class ChatSessionSummary {
  const ChatSessionSummary({
    required this.id,
    required this.source,
    required this.messageCount,
    this.startTime,
    this.endTime,
    this.importedAt,
    this.analysisStatus,
  });

  final String id;
  final String source;
  final int messageCount;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? importedAt;
  final String? analysisStatus;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.id,
    required this.sender,
    required this.messageText,
    required this.timestamp,
    required this.messageType,
  });

  final String id;
  final String sender; // customer | sales
  final String messageText;
  final DateTime timestamp;
  final String messageType; // text | image | file | sticker
}

