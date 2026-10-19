import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../planner.dart';
import '../models/event.dart';
import 'common.dart';

class EventDetails extends StatelessWidget {
  final Planner planner;
  final String id;
  const EventDetails({super.key, required this.planner, required this.id});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: planner,
    builder: (c, _) {
      final e = planner.find(id);
      return AppFrame(
        title: 'Event details',
        planner: planner,
        child: Content(
          child: e == null
              ? const EmptyState(
                  title: 'Event not found',
                  message: 'This event may have been deleted.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.category.toUpperCase(),
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff555555),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      e.title,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 24),
                    _line(Icons.calendar_today, dateLabel(e.start)),
                    _line(
                      Icons.schedule,
                      '${timeLabel(e.start)} – ${timeLabel(e.end)}',
                    ),
                    _line(Icons.location_on_outlined, e.venue),
                    _line(statusIcon(e.status), e.status),
                    if (e.organizer.isNotEmpty)
                      _line(Icons.groups_outlined, e.organizer),
                    if (e.description.isNotEmpty) ...[
                      sectionTitle(context, 'About this event'),
                      SelectableText(
                        e.description,
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const Text(
                      'This is your personal plan. No registration is sent to an organizer.',
                      style: TextStyle(color: Color(0xff555555)),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.push('/events/$id/edit'),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Event'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/events/$id/delete'),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Event'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    },
  );
  Widget _line(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}

class DeleteEvent extends StatelessWidget {
  final Planner planner;
  final String id;
  const DeleteEvent({super.key, required this.planner, required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black54,
    body: Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          icon: const Icon(Icons.delete_outline),
          title: const Text('Delete this event?'),
          content: const Text(
            'This removes the event from this browser. You cannot undo it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/events/$id');
                }
              },
              child: const Text('Keep Event'),
            ),
            FilledButton(
              onPressed: () {
                if (planner.delete(id)) {
                  context.go('/events');
                } else {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/events/$id');
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SaveConfirmation extends StatelessWidget {
  final Planner planner;
  final String id;
  const SaveConfirmation({super.key, required this.planner, required this.id});
  @override
  Widget build(BuildContext context) => AppFrame(
    title: 'Saved',
    planner: planner,
    child: Content(
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Icon(Icons.check_circle_outline, size: 64),
          const SizedBox(height: 24),
          Text(
            planner.find(id) == null
                ? 'Event no longer available'
                : 'Your plan is saved.',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Stored in this browser on this device.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => context.replace('/events/$id'),
            child: const Text('View Event'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/events'),
            child: const Text('Back to events'),
          ),
        ],
      ),
    ),
  );
}
