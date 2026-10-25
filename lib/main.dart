import 'package:flutter/material.dart';

import 'models/faculty_model.dart';
import 'models/student_model.dart';
import 'screens/faculty_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClassClockApp());
}

class ClassClockApp extends StatefulWidget {
  const ClassClockApp({super.key});

  @override
  State<ClassClockApp> createState() => _ClassClockAppState();
}

class _ClassClockAppState extends State<ClassClockApp> {
  ThemeMode _themeMode = ThemeMode.light;
  LoginRole? _loginRole;
  StudentModel? _student;
  FacultyModel? _faculty;

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _loginStudent(StudentModel student) {
    setState(() {
      _student = student;
      _faculty = null;
      _loginRole = LoginRole.student;
    });
  }

  void _loginFaculty(FacultyModel faculty) {
    setState(() {
      _faculty = faculty;
      _student = null;
      _loginRole = LoginRole.faculty;
    });
  }

  void _logout() {
    setState(() {
      _loginRole = null;
      _student = null;
      _faculty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget home = switch (_loginRole) {
      LoginRole.student => StudentDashboardScreen(
        student: _student!,
        onLogout: _logout,
        isDarkMode: _themeMode == ThemeMode.dark,
        onDarkModeChanged: _setDarkMode,
      ),
      LoginRole.faculty => FacultyDashboardScreen(
        faculty: _faculty!,
        onLogout: _logout,
        onDarkModeChanged: _setDarkMode,
      ),
      null => LoginScreen(
        onStudentLogin: _loginStudent,
        onFacultyLogin: _loginFaculty,
      ),
    };

    return MaterialApp(
      title: 'ClassClock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: home,
    );
  }
}
