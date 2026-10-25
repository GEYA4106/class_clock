import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/class_model.dart';
import '../services/storage_service.dart';
import '../widgets/class_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onAddClass,
    required this.refreshVersion,
    this.classSection,
  });

  final VoidCallback onAddClass;
  final int refreshVersion;
  final String? classSection;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = const StorageService();
  List<ClassModel> _classes = [];
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
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
        _loadError = 'Could not load your classes: $error';
        _loading = false;
      });
    }
  }

  int _minutesSinceMidnight(DateTime time) => time.hour * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayClasses = _classes
        .where(
          (classModel) =>
              classModel.day == today.weekday &&
              (widget.classSection == null ||
                  classModel.classSection == widget.classSection),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    ClassModel? nextClass;
    for (final classModel in todayClasses) {
      if (classModel.startTime >= _minutesSinceMidnight(today)) {
        nextClass = classModel;
        break;
      }
    }
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.schedule, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Text(
                'ClassClock',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Good morning!',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, MMMM d').format(today),
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          StatCard(
            label: "Today's classes",
            value: _loading ? '—' : '${todayClasses.length}',
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 20),
          const _SectionHeading(title: 'Next Class'),
          const SizedBox(height: 12),
          if (_loading)
            const _LoadingCard()
          else if (_loadError != null)
            _ErrorCard(message: _loadError!, onRetry: _loadClasses)
          else if (todayClasses.isEmpty)
            const _MessageCard(
              title: 'No classes today',
              message: 'Your day is clear. Add a class whenever you are ready.',
            )
          else if (nextClass != null)
            _NextClassCard(session: nextClass)
          else
            const _MessageCard(
              title: 'No upcoming classes',
              message: 'You have completed all your classes for today.',
            ),
          const SizedBox(height: 24),
          const _SectionHeading(title: "Today's Schedule"),
          const SizedBox(height: 12),
          if (_loading)
            const _LoadingCard()
          else if (_loadError != null)
            _ErrorCard(message: _loadError!, onRetry: _loadClasses)
          else if (todayClasses.isEmpty)
            const _MessageCard(
              title: 'No classes today',
              message: 'Your schedule is open. Add a class to plan your day.',
            )
          else
            ...todayClasses.map(
              (classModel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClassCard(classModel: classModel),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onAddClass,
              icon: const Icon(Icons.add),
              label: const Text('Add a class'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _NextClassCard extends StatelessWidget {
  const _NextClassCard({required this.session});

  final ClassModel session;

  String _formatTime(BuildContext context, int minutes) {
    return TimeOfDay(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    ).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final start = _formatTime(context, session.startTime);
    final end = _formatTime(context, session.endTime);

    return Card(
      color: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upcoming_outlined, color: colors.onPrimary),
                const SizedBox(width: 8),
                Text(
                  '$start – $end',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.subject,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${session.room}  ·  ${session.faculty}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.title, required this.message});

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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
