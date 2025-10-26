import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_app/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodTrendHistoryScreen extends StatefulWidget {
  const MoodTrendHistoryScreen({super.key});

  @override
  State<MoodTrendHistoryScreen> createState() => _MoodTrendHistoryScreenState();
}

class _MoodTrendHistoryScreenState extends State<MoodTrendHistoryScreen> {
  // v2: list-based storage allowing multiple entries per day
  static const String _storageKeyV2 = 'journal_entries_v2';
  bool _loading = true;
  late List<_MoodEntry> _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKeyV2);
    final List<_MoodEntry> items = [];
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final Map<String, dynamic>? data = item as Map<String, dynamic>?;
        if (data == null) continue;
        final String date = (data['date'] as String?) ?? '';
        final int? mood = data['mood'] as int?;
        final String text = (data['text'] as String?)?.trim() ?? '';
        final int? id = data['id'] as int?;
        final String? createdAt = data['createdAt'] as String?;
        if (date.isEmpty || mood == null) continue;
        items.add(
          _MoodEntry(
            id: id ?? DateTime.tryParse(createdAt ?? '')?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
            dateKey: date,
            mood: mood.clamp(1, 5),
            text: text,
          ),
        );
      }
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    setState(() {
      _entries = items;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries
        .map((e) => {
              'id': e.id,
              'date': e.dateKey,
              'text': e.text,
              'mood': e.mood,
              'createdAt': e.date.toIso8601String(),
            })
        .toList();
    await prefs.setString(_storageKeyV2, jsonEncode(jsonList));
  }

  Future<void> _deleteEntry(_MoodEntry entry) async {
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
    });
    await _persist();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all entries?'),
        content: const Text('This will permanently delete all journal entries.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear All')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _entries = []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeyV2, jsonEncode(<dynamic>[]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandBlue = const Color(0xFF006EDA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Mood Trend History'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Removed 14-day chart per request
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Entries',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (_entries.isNotEmpty)
                              TextButton(
                                onPressed: _clearAll,
                                child: const Text('Clear All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ..._entries.reversed.map(
                          (e) => Dismissible(
                            key: ValueKey(e.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteEntry(e),
                            child: _MoodTile(entry: e, onDelete: () => _deleteEntry(e)),
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

class _TrendChart extends StatelessWidget {
  final List<_MoodEntry> entries;
  final Color barColor;

  const _TrendChart({required this.entries, required this.barColor});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('No mood data yet. Save some moods to see the trend.');
    }

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((e) {
          final double h = (e.mood / 5.0) * 140.0 + 10.0; // min height so 1 is visible
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: h,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e.shortDate,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  final _MoodEntry entry;
  final VoidCallback? onDelete;

  const _MoodTile({required this.entry, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (entry.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('(${entry.mood}/5)', style: const TextStyle(color: Colors.black54)),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodEntry {
  final int id;
  final String dateKey; // yyyy-mm-dd
  final int mood; // 1..5
  final String text;

  _MoodEntry({required this.id, required this.dateKey, required this.mood, required this.text});

  DateTime get date {
    final parts = dateKey.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  String get shortDate => '${date.month}/${date.day}';

  String get formattedDate {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get emoji {
    switch (mood) {
      case 1:
        return '😠';
      case 2:
        return '😔';
      case 3:
        return '😇';
      case 4:
        return '😊';
      case 5:
        return '🥰';
      default:
        return '🙂';
    }
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

extension _TakeLast<T> on List<T> {
  List<T> takeLast(int count) {
    if (isEmpty) return <T>[];
    final start = length - count;
    return sublist(start < 0 ? 0 : start);
  }
}


