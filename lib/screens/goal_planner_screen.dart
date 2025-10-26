import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/goal.dart';
import 'add_goal_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';

class GoalPlannerScreen extends StatefulWidget {
  const GoalPlannerScreen({super.key});

  @override
  State<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends State<GoalPlannerScreen>
    with SingleTickerProviderStateMixin {
  final List<Goal> _goals = <Goal>[];

  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      setState(() {});
    });
    _loadGoals();
  }

  Future<void> _addGoal() async {
    final Goal? newGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute<Goal>(builder: (_) => const AddGoalScreen()),
    );

    if (newGoal != null) {
      setState(() => _goals.add(newGoal));
      await _saveGoals();
      final int index = _frequencyToIndex(newGoal.frequency);
      if (index != _tabController.index) {
        _tabController.animateTo(index);
      }
    }
  }

  Future<void> _loadGoals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('goals');
    if (jsonString == null || jsonString.isEmpty) return;
    final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
    final List<Goal> loaded = list
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> m) => Goal.fromJson(m))
        .toList();
    if (!mounted) return;
    setState(() {
      _goals
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveGoals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
      _goals.map((Goal g) => g.toJson()).toList(),
    );
    await prefs.setString('goals', jsonString);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _frequencyToIndex(String frequency) {
    switch (frequency) {
      case 'Daily':
        return 0;
      case 'Weekly':
        return 1;
      case 'Monthly':
        return 2;
      default:
        return 0;
    }
  }

  List<Goal> _filteredGoalsForTab(int tabIndex) {
    final String f =
        <int, String>{0: 'Daily', 1: 'Weekly', 2: 'Monthly'}[tabIndex]!;
    return _goals.where((Goal g) {
      if (f == 'Daily') {
        return g.frequency == 'Daily' || g.frequency == 'Today'; // backward-compatible
      }
      return g.frequency == f;
    }).toList();
  }

  double _progressForTab(int tabIndex) {
    final List<Goal> goals = _filteredGoalsForTab(tabIndex);
    if (goals.isEmpty) return 0.0;
    final int done = goals.where((Goal g) => g.isCompleted).length;
    return done / goals.length;
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF006EDA);
    const Color orange = Color(0xFFFF7A00);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Goal Planner'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with solid white background (no gradient)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}),
                    labelColor: Colors.white,
                    unselectedLabelColor: brandBlue,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: brandBlue,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'Monthly'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // White background section for daily progress and goals
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ProgressHeader(
                      title: const ['Daily', 'Weekly', 'Monthly']
                          [_tabController.index],
                      progressProvider: () =>
                          _progressForTab(_tabController.index),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _GoalList(
                          goalsProvider: () => _filteredGoalsForTab(0),
                          onProgressChanged: () => setState(() {}),
                        ),
                        _GoalList(
                          goalsProvider: () => _filteredGoalsForTab(1),
                          onProgressChanged: () => setState(() {}),
                        ),
                        _GoalList(
                          goalsProvider: () => _filteredGoalsForTab(2),
                          onProgressChanged: () => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: orange, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: orange),
                onPressed: _addGoal,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add Goal',
              style: TextStyle(
                color: brandBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Goal List ---
class _GoalList extends StatelessWidget {
  const _GoalList({
    required this.goalsProvider,
    required this.onProgressChanged,
  });

  final List<Goal> Function() goalsProvider;
  final VoidCallback onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final List<Goal> items = goalsProvider();
    const Color blue = Color(0xFF006EDA);
    const Color orange = Color(0xFFFF7A00);

    if (items.isEmpty) {
      return const Center(child: Text('No goals yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final Goal g = items[index];
        final bool completed = g.isCompleted;

        return Container(
          decoration: BoxDecoration(
            color: completed ? blue : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: _CheckMark(
              checked: completed,
              accentColor: completed ? blue : orange,
              onChanged: (bool v) {
                g.isCompleted = v;
                (context as Element).markNeedsBuild();
                onProgressChanged();
                // persist toggle
                final state = context.findAncestorStateOfType<_GoalPlannerScreenState>();
                state?._saveGoals();
              },
            ),
            title: Text(
              g.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: completed ? Colors.white : Colors.black,
              ),
            ),
            trailing: Text(
              g.time ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: completed ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Progress Header ---
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.progressProvider, required this.title});

  final double Function() progressProvider;
  final String title;

  @override
  Widget build(BuildContext context) {
    const Color orange = Color(0xFFFF7A00);
    final double p = progressProvider().clamp(0.0, 1.0);
    final int percent = (p * 100).round();

    return Row(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: p),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value == 0 ? 0.001 : value,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFFEE8D8),
                  valueColor: const AlwaysStoppedAnimation<Color>(orange),
                ),
              ),
              Center(
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title Progress',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
              'Track your progress at a glance',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Check Mark ---
class _CheckMark extends StatelessWidget {
  const _CheckMark({
    required this.checked,
    required this.onChanged,
    this.accentColor = const Color(0xFFFF7A00),
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: checked ? Colors.white : Colors.transparent,
          border: checked ? null : Border.all(color: accentColor, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: checked
            ? Icon(Icons.check, size: 18, color: accentColor)
            : null,
      ),
    );
  }
}
