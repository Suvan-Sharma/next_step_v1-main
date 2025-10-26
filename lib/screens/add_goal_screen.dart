import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../widgets/custom_app_bar.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _selectedFrequency = 'Daily';
  bool _reminder = false;

  // Dropdown options
  static const List<String> _categories = <String>[
    'Personal',
    'Career',
    'Health',
    'Education',
    'Finance',
    'Other',
  ];

  static const List<String> _priorities = <String>[
    'Low',
    'Normal',
    'High',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final Goal goal = Goal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      priority: _priorityController.text.trim().isEmpty
          ? 'Normal'
          : _priorityController.text.trim(),
      frequency: _selectedFrequency,
      time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      reminder: _reminder,
    );

    Navigator.of(context).pop(goal);
  }

  // UI helpers
  Widget _cardField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    final DateTime dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final String formatted = _formatDateTime(dt);
    setState(() => _timeController.text = formatted);
  }

  String _formatDateTime(DateTime dt) {
    const List<String> months = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour12:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Goal'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFE8F0FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _cardField(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        hintText: 'Enter goal title',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (String? v) =>
                          (v == null || v.trim().isEmpty) ? 'Title required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _cardField(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter description',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _cardField(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'Select your Category',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFD8E3D)),
                      ),
                      value: _categoryController.text.isEmpty ? null : _categoryController.text,
                      items: _categories
                          .map((String c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (String? v) => setState(() => _categoryController.text = v ?? ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _cardField(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        hintText: 'Select your Priority',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFD8E3D)),
                      ),
                      value: _priorityController.text.isEmpty ? null : _priorityController.text,
                      items: _priorities
                          .map((String p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (String? v) => setState(() => _priorityController.text = v ?? ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _cardField(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: _pickDateTime,
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
                        hintText: 'Select deadline or schedule',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFFFD8E3D)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _cardField(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Goal Frequency',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFD8E3D)),
                      ),
                      value: _selectedFrequency,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem<String>(value: 'Weekly', child: Text('Weekly')),
                        DropdownMenuItem<String>(value: 'Monthly', child: Text('Monthly')),
                      ],
                      onChanged: (String? v) {
                        if (v == null) return;
                        setState(() => _selectedFrequency = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Reminder Toggle',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Switch(
                            value: _reminder,
                            onChanged: (bool v) => setState(() => _reminder = v),
                            activeColor: const Color(0xFFFF8C3A),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A66FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue with Save',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


