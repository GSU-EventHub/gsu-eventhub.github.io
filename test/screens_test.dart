import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsu_eventhub/main.dart';
import 'package:gsu_eventhub/planner.dart';
import 'package:gsu_eventhub/models/event.dart';
import 'package:gsu_eventhub/storage/memory_store.dart';
import 'package:gsu_eventhub/screens/calendar.dart';
import 'package:gsu_eventhub/screens/event_form.dart';
import 'package:go_router/go_router.dart';
import 'planner_test.dart' show fixture;

void main() {
  testWidgets(
    'welcome to empty dashboard, form validation, save, edit and delete',
    (t) async {
      final p = Planner(BrowserStore());
      await t.pumpWidget(EventHub(planner: p));
      await t.pumpAndSettle();
      await t.tap(find.text('Open my planner'));
      await t.pumpAndSettle();
      expect(find.text('Your next event starts here'), findsOneWidget);
      await t.tap(find.text('Add Event'));
      await t.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save Event'));
      await t.pumpAndSettle();
      expect(p.events, isEmpty);
      expect(find.text('This field is required.'), findsNWidgets(2));
      await t.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Campus workshop',
      );
      await t.enterText(find.widgetWithText(TextFormField, 'Venue'), 'Lab 2');
      await t.enterText(
        find.widgetWithText(TextFormField, 'Date'),
        '2030-05-10',
      );
      await t.enterText(
        find.widgetWithText(TextFormField, 'Start time'),
        '2:00 PM',
      );
      await t.enterText(
        find.widgetWithText(TextFormField, 'End time'),
        '1:00 PM',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save Event'));
      await t.pumpAndSettle();
      expect(find.text('End must be after start.'), findsOneWidget);
      expect(p.events, isEmpty);
      await t.enterText(
        find.widgetWithText(TextFormField, 'End time'),
        '3:30 PM',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save Event'));
      await t.pumpAndSettle();
      expect(find.text('Your plan is saved.'), findsOneWidget);
      expect(p.events.single.title, 'Campus workshop');
      await t.tap(find.text('View Event'));
      await t.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Edit Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Edit Event'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Revised workshop',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('View Event'));
      await t.pumpAndSettle();
      expect(find.text('Revised workshop'), findsOneWidget);
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Delete Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Delete Event'));
      await t.pumpAndSettle();
      expect(find.text('Delete this event?'), findsOneWidget);
      await t.tap(find.text('Keep Event'));
      await t.pumpAndSettle();
      expect(p.events, hasLength(1));
      await t.tap(find.text('Delete Event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Delete'));
      await t.pumpAndSettle();
      expect(p.events, isEmpty);
      expect(find.text('No events yet'), findsOneWidget);
    },
  );
  testWidgets('responsive main screens and calendar modes avoid overflow', (
    t,
  ) async {
    final p = Planner(BrowserStore())..save(fixture());
    for (final size in [
      const Size(320, 640),
      const Size(844, 390),
      const Size(1440, 900),
    ]) {
      await t.binding.setSurfaceSize(size);
      for (final route in [
        '/dashboard',
        '/events',
        '/calendar',
        '/calendar?expanded=1',
        '/events/new',
        '/events/one',
      ]) {
        await t.pumpWidget(
          EventHub(key: UniqueKey(), planner: p, initialLocation: route),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: '$route at $size');
      }
    }
    await t.binding.setSurfaceSize(null);
  });
  testWidgets(
    'calendar slot prefills form; returning keeps selection and scroll',
    (t) async {
      final p = Planner(BrowserStore())
        ..calendarView = 'Week'
        ..selectedDate = DateTime(2030, 5, 10);
      await t.binding.setSurfaceSize(const Size(390, 844));
      await t.pumpWidget(EventHub(planner: p, initialLocation: '/calendar'));
      await t.pumpAndSettle();
      final date = p.selectedDate;
      final calendar = find.byType(CalendarScreen);
      expect(calendar, findsOneWidget);
      await t.tap(find.text('Add Event'));
      await t.pumpAndSettle();
      expect(find.byType(EventForm), findsOneWidget);
      expect(find.text('2030-05-10'), findsOneWidget);
      GoRouter.of(t.element(find.byType(EventForm))).pop();
      await t.pumpAndSettle();
      expect(p.selectedDate, date);
      expect(p.calendarView, 'Week');
      expect(t.takeException(), isNull);
      await t.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'timetable positions match time and duration; a slot prefills its time',
    (t) async {
      final p = Planner(BrowserStore())
        ..calendarView = 'Day'
        ..selectedDate = DateTime(2030, 5, 10);
      p.save(fixture());
      p.save(
        Event(
          id: 'overlap',
          title: 'Overlap',
          venue: 'Room',
          category: 'Other',
          status: 'Going',
          start: DateTime(2030, 5, 10, 9, 30),
          end: DateTime(2030, 5, 10, 11),
        ),
      );
      await t.binding.setSurfaceSize(const Size(800, 900));
      await t.pumpWidget(EventHub(planner: p, initialLocation: '/calendar'));
      await t.pumpAndSettle();
      final blocks = t
          .widgetList<Positioned>(
            find.byWidgetPredicate(
              (w) => w is Positioned && w.child is Semantics,
            ),
          )
          .toList();
      expect(blocks.map((b) => b.top), containsAll([540.0, 570.0]));
      expect(blocks.map((b) => b.height), containsAll([60.0, 90.0]));
      final first = blocks.firstWhere((b) => b.top == 540);
      final overlapping = blocks.firstWhere((b) => b.top == 570);
      expect(overlapping.left, greaterThan(first.left!));
      final slot = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Add event on May 10, 2030 at 12:00 PM',
      );
      await t.tap(slot);
      await t.pumpAndSettle();
      expect(find.text('2030-05-10'), findsOneWidget);
      expect(find.text('12:00 PM'), findsOneWidget);
      expect(find.text('1:00 PM'), findsOneWidget);
      await t.binding.setSurfaceSize(null);
    },
  );
}
