import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';

/// Pickers are URL routes so browser Back closes them before leaving the form.
class PickerPage<T> extends Page<T> {
  final Widget child;
  const PickerPage({super.key, required this.child});
  @override
  Route<T> createRoute(BuildContext context) =>
      DialogRoute<T>(context: context, settings: this, builder: (_) => child);
}

List<RouteBase> eventPickerRoutes() => [
  GoRoute(
    path: 'date',
    pageBuilder: (c, s) => PickerPage<DateTime>(
      key: s.pageKey,
      child: DatePickerDialog(
        initialDate:
            parseDate(s.uri.queryParameters['value'] ?? '') ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2200, 12, 31),
      ),
    ),
  ),
  for (final name in ['start-time', 'end-time'])
    GoRoute(
      path: name,
      pageBuilder: (c, s) {
        final minutes =
            (int.tryParse(s.uri.queryParameters['value'] ?? '') ?? 540).clamp(
              0,
              1439,
            );
        return PickerPage<TimeOfDay>(
          key: s.pageKey,
          child: MediaQuery(
            data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: false),
            child: TimePickerDialog(
              initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
            ),
          ),
        );
      },
    ),
];
