# 📚 ClassClock – Smart College Timetable Scheduler

<p align="center">
  <b>Organize Your Classes. Manage Your Time. Achieve More.</b>
</p>

<p align="center">
  A smart, simple, and student-friendly Flutter application designed to manage college timetables, academic tasks, and study schedules efficiently.
</p>

---

## 🌟 About the Project

**ClassClock** is a Flutter-based College Timetable Scheduler developed to help students organize their academic activities in one place.

Students often struggle to manage class schedules, remember assignment deadlines, track upcoming tasks, and utilize their free periods effectively.

ClassClock provides a centralized platform where students can manage their weekly timetable, organize academic tasks, identify free periods, and improve their daily productivity.

The application focuses on a clean user interface, easy navigation, reliable functionality, and accessible student-centered design.

## 🎯 Objectives

- Simplify college timetable management.
- Help students organize daily academic activities.
- Reduce missed classes and assignment deadlines.
- Identify available free periods for self-study.
- Improve time management and productivity.
- Provide an accessible and easy-to-use scheduling experience.

## ✨ Features

### 1. Student Dashboard
- Personalized student dashboard.
- Display current date and day.
- View today's scheduled classes.
- Next-class information.
- Upcoming assignments and deadlines.
- Weekly timetable overview.

### 2. Smart Timetable Management
- Add new classes.
- Edit existing class details.
- Delete unwanted classes.
- Organize classes from Monday to Saturday.
- Store subject name, faculty name, classroom, and timings.
- Detect overlapping class schedules.
- View timetable according to selected weekdays.

### 3. Academic Task Management
- Create academic tasks and assignments.
- Add subject and deadline information.
- Set task priorities.
- Mark tasks as completed.
- Edit and delete tasks.
- Filter pending, completed, and overdue tasks.

### 4. Study Planner
- Identify free periods between scheduled classes.
- Organize study activities.
- Plan academic tasks efficiently.

### 5. Local Data Storage
- Save timetable and task information locally.
- Retain saved information when reopening the application.
- Reduce dependency on internet connectivity.
- Keep student scheduling data on the device.

### 6. User-Friendly Interface
- Modern Material Design 3 interface.
- Clean dashboard and navigation.
- Responsive layouts.
- Consistent colors and typography.
- User-friendly forms and validation messages.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Material 3 | User interface design |
| SharedPreferences | Local data persistence |
| JSON | Data serialization |
| Intl | Date and time formatting |
| VS Code | Development environment |
| Git & GitHub | Version control and project hosting |
| GitHub Copilot | AI-assisted development |

## 📂 Project Structure

```text
class_clock/
│
├── android/
├── web/
├── test/
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── models/
│   │   ├── class_session.dart
│   │   └── task.dart
│   │
│   ├── services/
│   │   └── storage_service.dart
│   │
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── timetable_screen.dart
│   │   ├── tasks_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── widgets/
│   │   ├── class_card.dart
│   │   ├── task_card.dart
│   │   └── navigation_bar.dart
│   │
│   └── theme/
│       └── app_theme.dart
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

*Note: The structure above is the suggested organization. Update the file tree to match your actual implementation.*

## ⚙️ Installation and Setup

### Prerequisites

Install the following tools:

- Flutter SDK
- Dart SDK (included with Flutter)
- Visual Studio Code
- Git
- Google Chrome (for web execution)

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/class_clock.git
```

### Step 2: Navigate to the Project

```bash
cd class_clock
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Check Flutter Configuration

```bash
flutter doctor
```

### Step 5: Run the Application

To run the application in Chrome:

```bash
flutter run -d chrome
```

To run on a connected Android device:

```bash
flutter devices
flutter run
```

## 🧪 Testing

Run static code analysis:

```bash
flutter analyze
```

Run application tests:

```bash
flutter test
```

Format Dart source files:

```bash
dart format lib test
```

## 🏗️ Build Application

### Build for Web

```bash
flutter build web
```

Output directory:

```text
build/web/
```

### Build Android APK

```bash
flutter build apk --release
```

Output location:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🌍 Sustainable Development Goals (SDGs)

ClassClock contributes to the following United Nations Sustainable Development Goals.

### SDG 4 – Quality Education

ClassClock supports students in organizing academic schedules, planning study sessions, tracking assignments, and managing learning activities effectively.

**Impact:**
- Encourages organized learning habits.
- Supports independent study planning.
- Helps students manage academic responsibilities.
- Promotes better time management.

### SDG 10 – Reduced Inequalities

ClassClock aims to provide a simple and accessible scheduling tool for students with different planning needs.

**Impact:**
- Easy-to-understand interface.
- Responsive design for different screen sizes.
- Accessibility-conscious interface design.
- Local storage for basic offline-friendly usage.

## 🚀 Future Enhancements

- Automatic timetable generation.
- Push notifications for upcoming classes.
- Cloud synchronization across devices.
- Student attendance tracking.
- Faculty and classroom management.
- Calendar integration.
- AI-powered personalized study recommendations.
- Multi-language support.
- Shared timetables for student groups.

## 🔐 Privacy and Data Security

- The current application is designed around local data storage.
- No cloud account is required for the basic scheduling workflow.
- Students should avoid storing confidential personal
