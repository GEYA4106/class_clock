import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/class_sections.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../services/storage_service.dart';
import '../widgets/class_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({
    super.key,
    required this.student,
    required this.onLogout,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final StudentModel student;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _storage = const StorageService();
  List<ClassModel> _classes = [];
  String? _loadError;
  bool _loading = true;
  String _selectedSection = ClassSections.values.first;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await _storage.loadClasses();
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _loading = false;
        _loadError = null;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load your timetable: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final classes =
        _classes
            .where((classModel) => classModel.classSection == _selectedSection)
            .toList()
          ..sort((a, b) {
            final dayOrder = a.day.compareTo(b.day);
            return dayOrder == 0
                ? a.startTime.compareTo(b.startTime)
                : dayOrder;
          });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassClock'),
        actions: [
          IconButton(
            tooltip: widget.isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            onPressed: () => widget.onDarkModeChanged(!widget.isDarkMode),
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome, ${widget.student.rollNumber}',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileLine(
                      icon: Icons.badge_outlined,
                      label: 'Roll Number',
                      value: widget.student.rollNumber,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('student-section-picker'),
                      initialValue: _selectedSection,
                      decoration: const InputDecoration(
                        labelText: 'Class / Section',
                        prefixIcon: Icon(Icons.groups_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: ClassSections.values
                          .map(
                            (section) => DropdownMenuItem(
                              value: section,
                              child: Text(section),
                            ),
                          )
                          .toList(),
                      onChanged: (section) {
                        if (section == null) return;
                        setState(() {
                          _selectedSection = section;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My Timetable',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Read-only timetable for $_selectedSection.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_loadError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_loadError!),
                      TextButton(
                        onPressed: _loadClasses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (classes.isEmpty)
              const _TimetableMessage(
                title: 'No timetable available',
                message:
                    'Faculty has not added a timetable for this class yet.',
              )
            else
              ..._weekdays.map((day) {
                final dayClasses = classes
                    .where((classModel) => classModel.day == day)
                    .toList();
                if (dayClasses.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(DateTime(2024, 1, day)),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...dayClasses.map(
                        (classModel) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClassCard(classModel: classModel),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static const _weekdays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimetableMessage extends StatelessWidget {
  const _TimetableMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(message),
          ],
        ),
      ),
    );
  }
}
