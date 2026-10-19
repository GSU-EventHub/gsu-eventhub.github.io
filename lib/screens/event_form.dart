import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../planner.dart';

import 'common.dart';

class EventForm extends StatefulWidget {
  final Planner planner;
  final String? id;
  final DateTime? initialDate;
  const EventForm({
    super.key,
    required this.planner,
    this.id,
    this.initialDate,
  });
  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final form = GlobalKey<FormState>();
  late final Event? original = widget.id == null
      ? null
      : widget.planner.find(widget.id!);
  late final initial =
      original?.start ??
      widget.initialDate ??
      DateTime.now().copyWith(hour: 9, minute: 0);
  late final title = TextEditingController(text: original?.title ?? '');
  late final venue = TextEditingController(text: original?.venue ?? '');
  late final date = TextEditingController(text: dateInput(initial));
  late final start = TextEditingController(text: timeLabel(initial));
  late final end = TextEditingController(
    text: timeLabel(
      original?.end ??
          DateTime(
            initial.year,
            initial.month,
            initial.day,
            (min(initial.hour * 60 + initial.minute + 60, 1439)) ~/ 60,
            (min(initial.hour * 60 + initial.minute + 60, 1439)) % 60,
          ),
    ),
  );
  late final organizer = TextEditingController(text: original?.organizer ?? '');
  late final description = TextEditingController(
    text: original?.description ?? '',
  );
  late String category = original?.category ?? categories.first;
  late String status = original?.status ?? statuses.first;
  @override
  void dispose() {
    for (final c in [title, venue, date, start, end, organizer, description]) {
      c.dispose();
    }
    super.dispose();
  }

  String? requiredText(String? v) =>
      (v ?? '').trim().isEmpty ? 'This field is required.' : null;
  @override
  Widget build(BuildContext context) => AppFrame(
    title: widget.id == null ? 'Add event' : 'Edit event',
    planner: widget.planner,
    child: Content(
      maxWidth: 740,
      child: widget.id != null && original == null
          ? const EmptyState(
              title: 'Event not found',
              message: 'It may have been deleted in this planner.',
            )
          : Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('All fields are required unless marked optional.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: title,
                    validator: requiredText,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: date,
                    validator: (v) => parseDate(v?.trim() ?? '') == null
                        ? 'Enter a valid date: YYYY-MM-DD (1900–2200).'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      helperText: 'YYYY-MM-DD',
                      suffixIcon: IconButton(
                        tooltip: 'Choose date',
                        icon: const Icon(Icons.calendar_today_outlined),
                        onPressed: chooseDate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (c, size) {
                      final fields = [
                        TextFormField(
                          controller: start,
                          validator: (v) => parseTime(v ?? '') == null
                              ? 'Use a time such as 9:00 AM.'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Start time',
                            helperText: 'AM/PM',
                            suffixIcon: IconButton(
                              tooltip: 'Choose start time',
                              icon: const Icon(Icons.schedule),
                              onPressed: () => chooseTime(start, 'start-time'),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: end,
                          validator: (v) {
                            final a = parseTime(start.text);
                            final b = parseTime(v ?? '');
                            if (b == null) {
                              return 'Use a time such as 10:00 AM.';
                            }
                            return a != null && b <= a
                                ? 'End must be after start.'
                                : null;
                          },
                          decoration: InputDecoration(
                            labelText: 'End time',
                            helperText: 'Same day, AM/PM',
                            suffixIcon: IconButton(
                              tooltip: 'Choose end time',
                              icon: const Icon(Icons.schedule),
                              onPressed: () => chooseTime(end, 'end-time'),
                            ),
                          ),
                        ),
                      ];
                      return size.maxWidth < 420
                          ? Column(
                              children: [
                                fields[0],
                                const SizedBox(height: 20),
                                fields[1],
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: fields[0]),
                                const SizedBox(width: 16),
                                Expanded(child: fields[1]),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: venue,
                    validator: requiredText,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Venue',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  sectionTitle(context, 'Category'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map(
                          (v) => ChoiceChip(
                            label: Text(v),
                            selected: category == v,
                            onSelected: (_) => setState(() => category = v),
                          ),
                        )
                        .toList(),
                  ),
                  sectionTitle(context, 'Personal status'),
                  const Text('This doesn’t register you with an organizer.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: statuses
                        .map(
                          (v) => ChoiceChip(
                            avatar: Icon(statusIcon(v), size: 18),
                            label: Text(v),
                            selected: status == v,
                            onSelected: (_) => setState(() => status = v),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: organizer,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Organizer (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: description,
                    maxLines: 5,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      helperText: 'Plain text only',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: save,
                        icon: const Icon(Icons.check),
                        label: const Text('Save event'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/events');
                          }
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    ),
  );
  String get pickerBase =>
      widget.id == null ? '/events/new' : '/events/${widget.id}/edit';
  Future<void> chooseDate() async {
    FocusScope.of(context).unfocus();
    final value = parseDate(date.text.trim()) ?? DateTime.now();
    final selected = await context.push<DateTime>(
      '$pickerBase/date?value=${dateInput(value)}',
    );
    if (mounted && selected != null) {
      setState(() => date.text = dateInput(selected));
    }
  }

  Future<void> chooseTime(
    TextEditingController controller,
    String picker,
  ) async {
    FocusScope.of(context).unfocus();
    final value = parseTime(controller.text) ?? 540;
    final selected = await context.push<TimeOfDay>(
      '$pickerBase/$picker?value=$value',
    );
    if (mounted && selected != null) {
      setState(
        () => controller.text = timeLabel(
          DateTime(2000, 1, 1, selected.hour, selected.minute),
        ),
      );
    }
  }

  void save() {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final d = parseDate(date.text.trim())!;
    final a = parseTime(start.text)!;
    final b = parseTime(end.text)!;
    final e = Event(
      id:
          original?.id ??
          '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 30)}',
      title: title.text.trim(),
      venue: venue.text.trim(),
      category: category,
      status: status,
      start: DateTime(d.year, d.month, d.day, a ~/ 60, a % 60),
      end: DateTime(d.year, d.month, d.day, b ~/ 60, b % 60),
      organizer: organizer.text.trim(),
      description: description.text.trim(),
    );
    if (widget.planner.save(e)) {
      context.replace('/saved/${e.id}');
    }
  }
}
