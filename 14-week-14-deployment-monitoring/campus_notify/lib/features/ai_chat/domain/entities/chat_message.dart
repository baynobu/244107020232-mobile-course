/// Entitas pesan dalam percakapan chat AI
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isOfflineFallback;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isOfflineFallback = false,
  });
}
