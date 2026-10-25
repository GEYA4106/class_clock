import 'package:flutter/material.dart';

import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../services/conflict_service.dart';
import '../services/storage_service.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key, this.classToEdit, this.classSection});

  final ClassModel? classToEdit;
  final String? classSection;

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _defaultColorValue = 0xFF4C7C72;
  static const _manualSubjectId = '__manual_subject__';
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _facultyController = TextEditingController();
  final _roomController = TextEditingController();
  final _storage = const StorageService();

  int? _selectedDay;
  List<SubjectModel> _subjects = [];
  String? _selectedSubjectId;
  String? _subjectsLoadError;
  bool _subjectsLoading = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;

  bool get _isEditing => widget.classToEdit != null;

  @override
  void initState() {
    super.initState();
    final classToEdit = widget.classToEdit;
    if (classToEdit != null) {
      _subjectController.text = classToEdit.subject;
      _facultyController.text = classToEdit.faculty;
      _roomController.text = classToEdit.room;
      _selectedDay = classToEdit.day;
      _startTime = _timeOfDayFromMinutes(classToEdit.startTime);
      _endTime = _timeOfDayFromMinutes(classToEdit.endTime);
    }
    _loadSubjects();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _facultyController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  TimeOfDay _timeOfDayFromMinutes(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  int _minutesFromTimeOfDay(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _loadSubjects() async {
    try {
      final subjects = await _storage.loadSubjects();
      if (!mounted) return;
      final matchingSubject = subjects.where(
        (subject) => subject.name == widget.classToEdit?.subject,
      );
      setState(() {
        _subjects = subjects;
        _subjectsLoading = false;
        if (widget.classToEdit != null) {
          _selectedSubjectId = matchingSubject.isEmpty
              ? _manualSubjectId
              : matchingSubject.first.id;
        }
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _subjectsLoadError = 'Could not load saved subjects: $error';
        _subjectsLoading = false;
        if (widget.classToEdit != null) {
          _selectedSubjectId = _manualSubjectId;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Future<void> _selectTime({required bool isStart}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime:
          (isStart ? _startTime : _endTime) ??
          TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (selectedTime == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }
    });
    _formKey.currentState?.validate();
  }

  Future<void> _save() async {
    if (_subjectsLoading || !_formKey.currentState!.validate() || _saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final existingClasses = await _storage.loadClasses();
      if (!mounted) return;
      final editedClass = widget.classToEdit;
      final selectedSubject = _subjects
          .where((subject) => subject.id == _selectedSubjectId)
          .firstOrNull;
      final classModel = ClassModel(
        id: editedClass?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        classSection:
            editedClass?.classSection ?? widget.classSection ?? 'General',
        subject: selectedSubject?.name ?? _subjectController.text.trim(),
        faculty: _facultyController.text.trim(),
        room: _roomController.text.trim(),
        day: _selectedDay!,
        startTime: _minutesFromTimeOfDay(_startTime!),
        endTime: _minutesFromTimeOfDay(_endTime!),
        colorValue:
            selectedSubject?.colorValue ??
            editedClass?.colorValue ??
            _defaultColorValue,
      );

      if (ConflictService.hasConflict(
        classModel,
        existingClasses,
        ignoreClassId: editedClass?.id,
      )) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Class conflict detected'),
            content: const Text(
              'Another class already exists during this time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
        return;
      }

      if (editedClass == null) {
        await _storage.addClass(classModel);
      } else {
        await _storage.updateClass(classModel);
      }
      if (mounted) Navigator.pop(context, classModel);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the class: $error')),
        );
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Class' : 'Add Class')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_subjectsLoading)
                const LinearProgressIndicator()
              else if (_subjects.isEmpty)
                _manualSubjectField()
              else ...[
                DropdownButtonFormField<String>(
                  key: ValueKey('class-subject-dropdown-$_selectedSubjectId'),
                  initialValue: _selectedSubjectId,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.book_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ..._subjects.map(
                      (subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: _manualSubjectId,
                      child: Text('Other (enter manually)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                      final subject = _subjects
                          .where((item) => item.id == value)
                          .firstOrNull;
                      if (subject != null) {
                        _subjectController.text = subject.name;
                        _facultyController.text = subject.faculty;
                      }
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select a subject' : null,
                ),
                if (_selectedSubjectId == _manualSubjectId) ...[
                  const SizedBox(height: 16),
                  _manualSubjectField(),
                ],
              ],
              if (_subjectsLoadError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _subjectsLoadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (widget.classSection != null || widget.classToEdit != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: ValueKey(
                    widget.classToEdit?.classSection ?? widget.classSection,
                  ),
                  initialValue:
                      widget.classToEdit?.classSection ??
                      widget.classSection ??
                      'General',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Class / Section',
                    prefixIcon: Icon(Icons.groups_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('class-faculty-field'),
                controller: _facultyController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Faculty',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter faculty name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Room',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a room'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  _dayNames.length,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_dayNames[index]),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                validator: (value) => value == null ? 'Select a day' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey(_startTime),
                readOnly: true,
                initialValue: _formatTime(_startTime),
                onTap: () => _selectTime(isStart: true),
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  prefixIcon: Icon(Icons.schedule_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (_) =>
                    _startTime == null ? 'Select a start time' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey(_endTime),
                readOnly: true,
                initialValue: _formatTime(_endTime),
                onTap: () => _selectTime(isStart: false),
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                validator: (_) {
                  if (_endTime == null) return 'Select an end time';
                  if (_startTime != null &&
                      _minutesFromTimeOfDay(_endTime!) <=
                          _minutesFromTimeOfDay(_startTime!)) {
                    return 'End time must be after start time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving || _subjectsLoading ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.save_outlined : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _manualSubjectField() {
    return TextFormField(
      controller: _subjectController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Subject',
        prefixIcon: Icon(Icons.book_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Enter a subject' : null,
    );
  }
}
