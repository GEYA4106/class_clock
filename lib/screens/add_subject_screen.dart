import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../services/storage_service.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key, this.subjectToEdit});

  final SubjectModel? subjectToEdit;

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  static const _colorValues = [
    0xFF356B61,
    0xFF365F91,
    0xFF744A8A,
    0xFF9A4C3D,
    0xFF8A621F,
    0xFF3F7047,
    0xFF4D5969,
    0xFF8A4668,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _storage = const StorageService();
  late int _selectedColor;
  bool _saving = false;

  bool get _isEditing => widget.subjectToEdit != null;

  @override
  void initState() {
    super.initState();
    final subject = widget.subjectToEdit;
    _selectedColor = subject?.colorValue ?? _colorValues.first;
    if (subject != null) {
      _nameController.text = subject.name;
      _facultyController.text = subject.faculty;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final oldSubject = widget.subjectToEdit;
      late final String id;
      if (oldSubject != null) {
        id = oldSubject.id;
      } else {
        final existingSubjects = await _storage.loadSubjects();
        final existingIds = existingSubjects.map((subject) => subject.id).toSet();
        final baseId = DateTime.now().microsecondsSinceEpoch.toString();
        var generatedId = baseId;
        var suffix = 1;
        while (existingIds.contains(generatedId)) {
          generatedId = '$baseId-$suffix';
          suffix++;
        }
        id = generatedId;
      }
      final subject = SubjectModel(
        id: id,
        name: _nameController.text.trim(),
        faculty: _facultyController.text.trim(),
        colorValue: _selectedColor,
      );

      if (oldSubject == null) {
        await _storage.addSubject(subject);
      } else {
        await _storage.updateSubject(subject);
      }
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save the subject: $error')),
      );
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Subject' : 'Add Subject')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a subject name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 24),
              Text(
                'Subject Color',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final (index, colorValue) in _colorValues.indexed)
                    Semantics(
                      label: 'Select subject color ${index + 1}',
                      button: true,
                      selected: colorValue == _selectedColor,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() {
                            _selectedColor = colorValue;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorValue == _selectedColor
                                  ? colors.onSurface
                                  : colors.outlineVariant,
                              width: colorValue == _selectedColor ? 3 : 1,
                            ),
                          ),
                          child: colorValue == _selectedColor
                              ? Icon(
                                  Icons.check,
                                  color: ThemeData.estimateBrightnessForColor(
                                            Color(colorValue),
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const ValueKey('save-subject'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.save_outlined : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Subject'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
