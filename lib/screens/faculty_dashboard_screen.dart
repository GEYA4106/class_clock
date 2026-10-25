import 'package:flutter/material.dart';

import '../constants/class_sections.dart';
import '../models/faculty_model.dart';
import '../models/class_model.dart';
import 'add_class_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'subjects_screen.dart';
import 'timetable_screen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({
    super.key,
    required this.faculty,
    required this.onLogout,
    required this.onDarkModeChanged,
  });

  final FacultyModel faculty;
  final VoidCallback onLogout;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  int _selectedIndex = 0;
  int _classesRevision = 0;
  String _selectedSection = ClassSections.values.first;

  Future<void> _openAddClass() async {
    final saved = await Navigator.of(context).push<ClassModel>(
      MaterialPageRoute(
        builder: (_) => AddClassScreen(classSection: _selectedSection),
      ),
    );
    if (saved != null && mounted) _notifyClassesChanged();
  }

  void _notifyClassesChanged() {
    setState(() {
      _classesRevision++;
    });
  }

  Widget _buildHome() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Faculty',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(widget.faculty.email),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const ValueKey('faculty-home-section-picker'),
                      initialValue: _selectedSection,
                      decoration: const InputDecoration(
                        labelText: 'Class / Section',
                        prefixIcon: Icon(Icons.groups_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
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
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddClass,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Class'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Timetable entries are saved locally for the selected section.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Manage Timetable'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: DashboardScreen(
            onAddClass: _openAddClass,
            refreshVersion: _classesRevision,
            classSection: _selectedSection,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: DropdownButtonFormField<String>(
              key: const ValueKey('faculty-timetable-section-picker'),
              initialValue: _selectedSection,
              decoration: const InputDecoration(
                labelText: 'Manage class / section',
                prefixIcon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ClassSections.values
                  .map(
                    (section) =>
                        DropdownMenuItem(value: section, child: Text(section)),
                  )
                  .toList(),
              onChanged: (section) {
                if (section == null) return;
                setState(() {
                  _selectedSection = section;
                });
              },
            ),
          ),
          Expanded(
            child: TimetableScreen(
              key: const ValueKey('faculty-timetable'),
              refreshVersion: _classesRevision,
              onClassesChanged: _notifyClassesChanged,
              classSection: _selectedSection,
            ),
          ),
        ],
      ),
      const SubjectsScreen(),
      SettingsScreen(onDarkModeChanged: widget.onDarkModeChanged),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_selectedIndex) {
          0 => 'Faculty Dashboard',
          1 => 'Manage Timetable',
          2 => 'Subjects',
          _ => 'Settings',
        }),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddClass,
              icon: const Icon(Icons.add),
              label: const Text('Add Class'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
