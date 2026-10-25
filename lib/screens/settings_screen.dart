import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onDarkModeChanged});

  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                subtitle: const Text('Choose a comfortable display theme'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: onDarkModeChanged,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: 'Notifications',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_outlined),
                title: const Text('Class reminders'),
                subtitle: const Text(
                  'Notification settings will be available later',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: 'About ClassClock',
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text(
                  'ClassClock helps college students organize their academic timetable, reduce schedule confusion and manage their time more effectively.',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.public_outlined, color: colors.primary),
                title: const Text('SDG 4 – Quality Education'),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 56, bottom: 4),
                child: Text('Your schedule. Your time. Your class.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
