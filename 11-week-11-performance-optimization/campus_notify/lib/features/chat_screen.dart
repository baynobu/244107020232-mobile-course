import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_chat/presentation/providers/chat_providers.dart';
import 'ai_chat/presentation/widgets/chat_loading_bubble.dart';
import 'ai_chat/presentation/widgets/chat_message_bubble.dart';

/// Halaman Chat Interaktif dengan Asisten AI Kampus (Gemini LLM)
///
/// Dioptimasi menggunakan:
/// - Ekstraksi widget pesan terisolasi ([ChatMessageBubble], [ChatLoadingBubble])
/// - Isolasi repaint per item bubble chat ([RepaintBoundary])
/// - Manajemen controller yang aman dari memory leak ([dispose])
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _quickPrompts = [
    'Kapan jadwal pengisian KRS semester baru?',
    'Bagaimana prosedur pengajuan izin sakit?',
    'Apa saja syarat pendaftaran beasiswa kampus?',
    'Kontak pusat layanan bantuan mahasiswa?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final query = _textController.text;
    if (query.trim().isEmpty) return;

    _textController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(query);
    _scrollToBottom();
  }

  Future<void> _showApiKeyDialog() async {
    final aiService = ref.read(aiServiceProvider);
    final currentKey = await aiService.getApiKey() ?? '';
    final controller = TextEditingController(text: currentKey);
    bool obscure = true;

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (innerCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Pengaturan API Key',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: minAxisSize,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kunci Google Gemini API disimpan secara aman di perangkat menggunakan flutter_secure_storage.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'AIzaSy...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dapatkan kunci gratis di: aistudio.google.com',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            if (currentKey.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await ref.read(chatNotifierProvider.notifier).clearApiKey();
                  if (dialogCtx.mounted) {
                    Navigator.of(dialogCtx).pop();
                  }
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('API Key telah dihapus.')),
                    );
                  }
                },
                child: const Text(
                  'Hapus Key',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newKey = controller.text.trim();
                await ref
                    .read(chatNotifierProvider.notifier)
                    .saveApiKey(newKey);
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                }
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('API Key berhasil disimpan dengan aman!'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  static const minAxisSize = MainAxisSize.min;

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    // Auto scroll saat ada pesan baru
    ref.listen<ChatState>(chatNotifierProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0) ||
          next.isLoading != (previous?.isLoading ?? false)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asisten AI Kampus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: chatState.hasApiKey
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  chatState.hasApiKey
                      ? 'Gemini AI Aktif'
                      : 'Mode Offline / Lokal',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Pengaturan API Key',
            icon: const Icon(Icons.vpn_key_outlined),
            onPressed: _showApiKeyDialog,
          ),
          IconButton(
            tooltip: 'Reset Obrolan',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).resetChat();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner privasi & status API
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: chatState.hasApiKey
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFFFFBEB),
              child: Row(
                children: [
                  Icon(
                    chatState.hasApiKey
                        ? Icons.lock_outline
                        : Icons.info_outline,
                    size: 16,
                    color: chatState.hasApiKey
                        ? const Color(0xFF1E3A8A)
                        : Colors.amber.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.hasApiKey
                          ? 'Privasi terjaga: Kunci disimpan di Secure Storage & data disanitasi.'
                          : 'API key belum diatur. Klik ikon kunci di kanan atas untuk menghubungkan Gemini.',
                      style: TextStyle(
                        fontSize: 12,
                        color: chatState.hasApiKey
                            ? const Color(0xFF1E3A8A)
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                  if (!chatState.hasApiKey)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _showApiKeyDialog,
                      child: const Text(
                        'Atur',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Daftar Pesan (Menggunakan ChatMessageBubble dengan RepaintBoundary)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    chatState.messages.length + (chatState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Indikator loading AI
                  if (index == chatState.messages.length &&
                      chatState.isLoading) {
                    return const ChatLoadingBubble();
                  }

                  final message = chatState.messages[index];
                  return ChatMessageBubble(
                    key: ValueKey(message.id),
                    message: message,
                  );
                },
              ),
            ),

            // Quick Prompt Chips
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.blue.shade200),
                    onPressed: chatState.isLoading
                        ? null
                        : () {
                            _textController.text = prompt;
                            _handleSend();
                          },
                  );
                },
              ),
            ),

            // Form Input Pesan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Tanyakan info kampus...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF1E3A8A),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: chatState.isLoading ? null : _handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
