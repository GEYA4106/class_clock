import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/class_model.dart';
import '../screens/add_class_screen.dart';
import '../services/storage_service.dart';
import '../widgets/class_card.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({
    super.key,
    required this.refreshVersion,
    required this.onClassesChanged,
    this.classSection,
  });

  final int refreshVersion;
  final VoidCallback onClassesChanged;
  final String? classSection;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final _storage = const StorageService();
  late int _selectedWeekday = DateTime.now().weekday;
  List<ClassModel> _classes = [];
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void didUpdateWidget(covariant TimetableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadClasses();
    }
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final classes = await _storage.loadClasses();
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _loading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load your timetable: $error';
        _loading = false;
      });
    }
  }

  Future<void> _openClassForm([ClassModel? classToEdit]) async {
    final savedClass = await Navigator.of(context).push<ClassModel>(
      MaterialPageRoute(
        builder: (_) => AddClassScreen(
          classToEdit: classToEdit,
          classSection: classToEdit?.classSection ?? widget.classSection,
        ),
      ),
    );
    if (savedClass != null && mounted) {
      setState(() {
        _selectedWeekday = savedClass.day;
      });
      widget.onClassesChanged();
    }
  }

  Future<void> _deleteClass(ClassModel classModel) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this class?'),
        content: Text('Remove ${classModel.subject} from your timetable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await _storage.deleteClass(classModel.id);
      if (mounted) widget.onClassesChanged();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete the class: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions =
        _classes
            .where(
              (classModel) =>
                  classModel.day == _selectedWeekday &&
                  (widget.classSection == null ||
                      classModel.classSection == widget.classSection),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final now = DateTime.now();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Timetable',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Add class',
                onPressed: () => _openClassForm(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your week, at a glance.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DateTime.daysPerWeek,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final weekday = index + 1;
                final date = now.subtract(
                  Duration(days: now.weekday - weekday),
                );
                final selected = weekday == _selectedWeekday;

                return ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat.E().format(date)),
                      Text('${date.day}'),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedWeekday = weekday;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat(
              'EEEE',
            ).format(now.add(Duration(days: _selectedWeekday - now.weekday))),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const _TimetableMessage(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadError != null)
            _TimetableMessage(
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
            )
          else if (sessions.isEmpty)
            const _TimetableMessage(
              child: Text('No classes scheduled for this day.'),
            )
          else
            ...sessions.map(
              (classModel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClassCard(
                  classModel: classModel,
                  onEdit: () => _openClassForm(classModel),
                  onDelete: () => _deleteClass(classModel),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimetableMessage extends StatelessWidget {
  const _TimetableMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
