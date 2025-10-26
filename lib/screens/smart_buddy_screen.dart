import 'package:flutter/material.dart';
import 'package:my_app/widgets/custom_app_bar.dart';
import 'package:my_app/widgets/custom_bottom_nav.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartBuddyScreen extends StatefulWidget {
  const SmartBuddyScreen({super.key});

  @override
  State<SmartBuddyScreen> createState() => _SmartBuddyScreenState();
}

class _SmartBuddyScreenState extends State<SmartBuddyScreen> {
  final List<_Message> _messages = <_Message>[
    _Message.bot('Hi! I\'m Smart Buddy. Tap a question below to get started.'),
  ];

  // FAQ list removed (replaced by free-text LLM chat input)

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _loading = false;

  // _ask removed; previously used for quick suggested questions

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeChat().catchError((error) {
      setState(() {
        _messages.add(_Message.bot('Failed to initialize chat: $error'));
      });
    });
  }

  Future<void> _initializeChat() async {
    final apiKey = 'AIzaSyC147SrNpvk5ycwDRUmid9B8c66bbjV5w4';
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    _chat = _model.startChat(history: [
      Content.text(
        'You are a helpful professional assistant called Smart Buddy. Use concise language and keep responses short not more than 2 paragraphs. Be engaging and ask questions to the user. Make it teen friendly.'
      )
    ]);
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message.user(text));
      _loading = true;
      _inputController.clear();
    });
    _scrollToEnd();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text ?? 'No response';
      setState(() {
        _messages.add(_Message.bot(responseText));
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message.bot('Error: $e'));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToEnd();
    }
  }

  // API key prompt removed; embedded key is used instead.

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF0B76E0);
    const Color botBubble = Color(0xFFE9F3FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Smart Buddy'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                final m = _messages[index];
                final bool isUser = m.isUser;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0B76E0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? primary : botBubble,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 10),
                              bottomRight: Radius.circular(isUser ? 10 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : const Color(0xFF0A1543),
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatNow(),
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.black54),
                        ),
                      
                    ],
                  ),
                );
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _loading
                    ? const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Color(0xFF0B76E0)),
                      ),
                // API key prompt removed; app uses embedded key in main.dart
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  const _Message._(this.text, this.isUser);
  factory _Message.user(String t) => _Message._(t, true);
  factory _Message.bot(String t) => _Message._(t, false);
}

String _formatNow() {
  final now = DateTime.now();
  final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final m = now.minute.toString().padLeft(2, '0');
  final ampm = now.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ampm';
}

