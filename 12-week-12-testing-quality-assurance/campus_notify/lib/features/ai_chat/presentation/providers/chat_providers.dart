import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ai/ai_service.dart';
import '../../domain/entities/chat_message.dart';

/// Provider instance AiService
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// State untuk antarmuka chat AI
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool hasApiKey;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasApiKey = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? hasApiKey,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasApiKey: hasApiKey ?? this.hasApiKey,
    );
  }
}

/// Notifier pengelola percakapan dan status koneksi API Key
class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    // Inisialisasi awal dengan pesan sambutan ramah
    final initialMessage = ChatMessage(
      id: 'welcome-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Halo! Saya Asisten AI Resmi Campus Notify. Ada yang bisa saya bantu terkait jadwal kuliah, KRS, pengumuman, atau layanan kampus hari ini?',
      isUser: false,
      timestamp: DateTime.now(),
    );

    // Cek status API key di background
    _checkApiKeyStatus();

    return ChatState(
      messages: [initialMessage],
      isLoading: false,
      hasApiKey: false,
    );
  }

  Future<void> _checkApiKeyStatus() async {
    final aiService = ref.read(aiServiceProvider);
    final hasKey = await aiService.hasApiKey();
    state = state.copyWith(hasApiKey: hasKey);
  }

  /// Mengirim pertanyaan ke AI Service dan memperbarui riwayat chat
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      errorMessage: null,
    );

    final aiService = ref.read(aiServiceProvider);

    try {
      final answer = await aiService.ask(trimmed);
      final isFallback = answer.contains('Mode Offline');

      final aiMsg = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        isOfflineFallback: isFallback,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: 'ai-error-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'Terjadi kendala saat menghubungi layanan AI: $e\nSilakan coba lagi atau periksa pengaturan API Key Anda.',
        isUser: false,
        timestamp: DateTime.now(),
        isOfflineFallback: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Menyimpan API Key pengguna ke Secure Storage
  Future<void> saveApiKey(String key) async {
    final aiService = ref.read(aiServiceProvider);
    await aiService.saveApiKey(key);
    state = state.copyWith(hasApiKey: key.trim().isNotEmpty);
  }

  /// Menghapus API Key pengguna
  Future<void> clearApiKey() async {
    final aiService = ref.read(aiServiceProvider);
    await aiService.clearApiKey();
    state = state.copyWith(hasApiKey: false);
  }

  /// Mereset riwayat percakapan chat
  void resetChat() {
    final initialMessage = ChatMessage(
      id: 'welcome-${DateTime.now().millisecondsSinceEpoch}',
      text: 'Percakapan telah direset. Ada hal lain yang ingin Anda tanyakan seputar kampus?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [initialMessage],
      isLoading: false,
      errorMessage: null,
    );
  }
}

/// Provider ChatNotifier untuk UI
final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
