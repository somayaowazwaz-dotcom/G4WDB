import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/gemma_engine/gemma_core.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final gemmaCore = ref.read(gemmaCoreProvider);
      final currentLanguage = context.locale.languageCode;

      // Create prompt with language instruction
      final languageInstruction = _getLanguageInstruction(currentLanguage);
      final prompt = '$languageInstruction\n\nUser: $message\n\nAssistant:';

      final result = await gemmaCore.infer(
        prompt: prompt,
        temperature: 0.7,
        maxTokens: 256,
      );

      final response = result['output'] as String? ?? 'Sorry, I couldn\'t generate a response.';

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: ${e.toString()}. Please check if Gemma is properly initialized.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    // Scroll to bottom again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getLanguageInstruction(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'You are a helpful AI assistant. Please respond in Arabic (العربية). Be helpful, accurate, and culturally appropriate.';
      case 'uk':
        return 'You are a helpful AI assistant. Please respond in Ukrainian (Українська). Be helpful, accurate, and culturally appropriate.';
      case 'fr':
        return 'You are a helpful AI assistant. Please respond in French (Français). Be helpful, accurate, and culturally appropriate.';
      case 'de':
        return 'You are a helpful AI assistant. Please respond in German (Deutsch). Be helpful, accurate, and culturally appropriate.';
      case 'ru':
        return 'You are a helpful AI assistant. Please respond in Russian (Русский). Be helpful, accurate, and culturally appropriate.';
      case 'fa':
        return 'You are a helpful AI assistant. Please respond in Persian (فارسی). Be helpful, accurate, and culturally appropriate.';
      case 'ur':
        return 'You are a helpful AI assistant. Please respond in Urdu (اردو). Be helpful, accurate, and culturally appropriate.';
      case 'bn':
        return 'You are a helpful AI assistant. Please respond in Bengali (বাংলা). Be helpful, accurate, and culturally appropriate.';
      case 'hi':
        return 'You are a helpful AI assistant. Please respond in Hindi (हिन्दी). Be helpful, accurate, and culturally appropriate.';
      case 'ks':
        return 'You are a helpful AI assistant. Please respond in Kashmiri (کٲشُر). Be helpful, accurate, and culturally appropriate.';
      case 'en':
      default:
        return 'You are a helpful AI assistant. Please respond in English. Be helpful, accurate, and culturally appropriate.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gemmaCore = ref.watch(gemmaCoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('chat.title'.tr()),
        actions: [
          if (!gemmaCore.isInitialized)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.warning, color: Colors.orange),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: gemmaCore.isInitialized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'chat.internet_offline'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  gemmaCore.isInitialized ? Icons.check_circle : Icons.warning,
                  color: gemmaCore.isInitialized ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  gemmaCore.isInitialized
                      ? 'chat.offline_ready'.tr()
                      : 'chat.offline_not_ready'.tr(),
                  style: TextStyle(
                    color: gemmaCore.isInitialized ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'chat.welcome'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'chat.instructions'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return const _TypingIndicator();
                      }

                      final message = _messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'chat.type_message'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading || !gemmaCore.isInitialized ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'chat.typing'.tr(),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}