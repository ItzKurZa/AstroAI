class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String sender; // 'user' or 'advisor'
  final String text;
  final DateTime createdAt;

  bool get isUser => sender == 'user';
}

