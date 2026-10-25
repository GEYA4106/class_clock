import 'package:flutter/material.dart';

import '../models/faculty_model.dart';
import '../models/student_model.dart';

enum LoginRole { student, faculty }

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onStudentLogin,
    required this.onFacultyLogin,
  });

  final ValueChanged<StudentModel> onStudentLogin;
  final ValueChanged<FacultyModel> onFacultyLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentController = TextEditingController();
  final _emailController = TextEditingController();
  LoginRole _selectedRole = LoginRole.student;

  @override
  void dispose() {
    _studentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == LoginRole.student) {
      final student = StudentModel(rollNumber: _studentController.text.trim());
      widget.onStudentLogin(student);
    } else {
      final faculty = FacultyModel(email: _emailController.text.trim());
      widget.onFacultyLogin(faculty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.schedule,
                              size: 36,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ClassClock',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your schedule. Your time. Your class.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),
                        SegmentedButton<LoginRole>(
                          segments: const [
                            ButtonSegment(
                              value: LoginRole.student,
                              label: Text('Student'),
                              icon: Icon(Icons.school_outlined),
                            ),
                            ButtonSegment(
                              value: LoginRole.faculty,
                              label: Text('Faculty'),
                              icon: Icon(Icons.person_outline),
                            ),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _selectedRole = selection.first;
                            });
                            _formKey.currentState?.reset();
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_selectedRole == LoginRole.student)
                          TextFormField(
                            controller: _studentController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Roll Number',
                              hintText: 'e.g. 23CSE001',
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your roll number'
                                : null,
                          )
                        else
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'College Email',
                              hintText: 'name@college.edu',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Enter your email';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(email)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _login,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Local prototype sign-in · no password required',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
