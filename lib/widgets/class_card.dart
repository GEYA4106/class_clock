import 'package:flutter/material.dart';

import '../models/class_model.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.classModel,
    this.onEdit,
    this.onDelete,
  });

  final ClassModel classModel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _formatTime(BuildContext context, int minutes) {
    return TimeOfDay(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    ).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = _formatTime(context, classModel.startTime);
    final end = _formatTime(context, classModel.endTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 76,
              decoration: BoxDecoration(
                color: classModel.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classModel.subject,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DetailLine(
                    icon: Icons.schedule_outlined,
                    text: '$start – $end',
                  ),
                  const SizedBox(height: 5),
                  _DetailLine(
                    icon: Icons.location_on_outlined,
                    text: classModel.room,
                  ),
                  const SizedBox(height: 5),
                  _DetailLine(
                    icon: Icons.person_outline,
                    text: classModel.faculty,
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(width: 4),
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Edit class',
                      visualDensity: VisualDensity.compact,
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Delete class',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
