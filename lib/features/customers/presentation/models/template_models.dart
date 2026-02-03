class MessageTemplate {
  const MessageTemplate({
    required this.id,
    required this.templateName,
    required this.category,
    required this.content,
    this.subject,
    this.tone,
    this.language,
    this.variables = const [],
    this.usageCount = 0,
  });

  final String id;
  final String templateName;
  final String category;
  final String content;
  final String? subject;
  final String? tone;
  final String? language;
  final List<String> variables;
  final int usageCount;
}

