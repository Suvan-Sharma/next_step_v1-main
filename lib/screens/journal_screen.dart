import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/widgets/custom_app_bar.dart';
import 'package:my_app/widgets/custom_bottom_nav.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  int _mood = 3; // 1..5 scale
  bool _loading = true;

  static const String _storageKeyV2 = 'journal_entries_v2';

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadToday() async {
    // For v2 list-based storage, we do not prefill today's text.
    // Keep initial mood at default and text empty.
    setState(() => _loading = false);
  }

  Future<void> _saveToday() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKeyV2);
    final List<dynamic> list = raw != null && raw.isNotEmpty ? jsonDecode(raw) as List<dynamic> : <dynamic>[];

    final now = DateTime.now();
    final entry = {
      'id': now.millisecondsSinceEpoch,
      'date': _todayKey,
      'text': text,
      'mood': _mood,
      'createdAt': now.toIso8601String(),
    };

    list.add(entry);
    await prefs.setString(_storageKeyV2, jsonEncode(list));

    // Reset the message after saving to avoid duplicate quick saves
    _controller.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved locally')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandBlue = const Color(0xFF006EDA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Journal'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Journal',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/moodHistory'),
                                child: const Text(
                                  'View History',
                                  style: TextStyle(
                                    color: Color(0xFF1F73E6),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _controller,
                              minLines: 5,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Write your thoughts here...'
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveToday,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How Are You Feeling Today?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _EmojiButton(emoji: '😠', selected: _mood == 1, onTap: () => setState(() => _mood = 1)),
                              _EmojiButton(emoji: '😔', selected: _mood == 2, onTap: () => setState(() => _mood = 2)),
                              _EmojiButton(emoji: '😇', selected: _mood == 3, onTap: () => setState(() => _mood = 3)),
                              _EmojiButton(emoji: '😊', selected: _mood == 4, onTap: () => setState(() => _mood = 4)),
                              _EmojiButton(emoji: '🥰', selected: _mood == 5, onTap: () => setState(() => _mood = 5)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/moodHistory'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('View Mood Trend History'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiButton({required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF006EDA) : Colors.black12;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F2FF) : Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: child,
    );
  }
}