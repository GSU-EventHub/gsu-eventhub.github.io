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
      await t.tap(find.text('Open planner'));
      await t.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);
      await t.tap(find.text('Add event'));
      await t.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save event'));
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
      await t.ensureVisible(find.text('Save event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save event'));
      await t.pumpAndSettle();
      expect(find.text('End must be after start.'), findsOneWidget);
      expect(p.events, isEmpty);
      await t.enterText(
        find.widgetWithText(TextFormField, 'End time'),
        '3:30 PM',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save event'));
      await t.pumpAndSettle();
      expect(find.text('Event saved'), findsOneWidget);
      expect(p.events.single.title, 'Campus workshop');
      await t.tap(find.text('View event'));
      await t.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Edit event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Edit event'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Revised workshop',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save event'));
      await t.pumpAndSettle();
      await t.tap(find.text('View event'));
      await t.pumpAndSettle();
      expect(find.text('Revised workshop'), findsOneWidget);
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Delete event'));
      await t.pumpAndSettle();
      await t.tap(find.text('Delete event'));
      await t.pumpAndSettle();
      expect(find.text('Delete this event?'), findsOneWidget);
      await t.tap(find.text('Keep event'));
      await t.pumpAndSettle();
      expect(p.events, hasLength(1));
      await t.tap(find.text('Delete event'));
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
        '/',
        '/events?filters=1',
        '/events/new/date?value=2030-05-10',
        '/events/new/start-time?value=540',
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
      await t.tap(find.text('Add event'));
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
  testWidgets(
    'mobile navigation has four large targets and fresh planners are empty',
    (t) async {
      final p = Planner(BrowserStore());
      await t.binding.setSurfaceSize(const Size(320, 640));
      await t.pumpWidget(EventHub(planner: p));
      await t.pumpAndSettle();
      expect(find.textContaining('No account needed'), findsNothing);
      await t.tap(find.text('Open planner'));
      await t.pumpAndSettle();
      expect(p.events, isEmpty);
      expect(find.text('No events yet'), findsOneWidget);
      for (final name in ['Home', 'Events', 'Calendar', 'Add event']) {
        final size = t.getSize(find.byKey(ValueKey('nav-$name')));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      await t.tap(find.byKey(const ValueKey('nav-Events')));
      await t.pumpAndSettle();
      expect(find.text('No events yet'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('nav-Calendar')));
      await t.pumpAndSettle();
      expect(find.text('An open day'), findsOneWidget);
      await t.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'date picker selection and time picker Back preserve the form draft',
    (t) async {
      final p = Planner(BrowserStore());
      await t.binding.setSurfaceSize(const Size(390, 844));
      await t.pumpWidget(EventHub(planner: p, initialLocation: '/events/new'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Draft event',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Choose date'));
      await t.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await t.tap(find.text('20').last);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      final now = DateTime.now();
      expect(
        find.text(dateInput(DateTime(now.year, now.month, 20))),
        findsOneWidget,
      );
      expect(find.text('Draft event'), findsOneWidget);
      await t.ensureVisible(find.byTooltip('Choose start time'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Choose start time'));
      await t.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      GoRouter.of(t.element(find.byType(EventForm))).pop();
      await t.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(find.text('Draft event'), findsOneWidget);
      expect(p.events, isEmpty);
      await t.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'filter Back retains choices and phone layouts handle text scaling and keyboard',
    (t) async {
      final p = Planner(BrowserStore())..save(fixture());
      await t.binding.setSurfaceSize(const Size(320, 640));
      await t.pumpWidget(EventHub(planner: p, initialLocation: '/events'));
      await t.pumpAndSettle();
      await t.tap(find.text('Filters'));
      await t.pumpAndSettle();
      await t.tap(find.text('Sports'));
      await t.pumpAndSettle();
      GoRouter.of(t.element(find.text('Category'))).pop();
      await t.pumpAndSettle();
      expect(find.text('Category'), findsNothing);
      expect(p.category, 'Sports');
      expect(find.text('No matching events'), findsOneWidget);
      t.binding.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(t.binding.platformDispatcher.clearTextScaleFactorTestValue);
      for (final route in ['/dashboard', '/calendar', '/events/new']) {
        await t.pumpWidget(
          EventHub(key: UniqueKey(), planner: p, initialLocation: route),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: 'Text scale 1.3: $route');
      }
      t.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(t.view.resetViewInsets);
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Save event'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: 'Keyboard inset');
      await t.binding.setSurfaceSize(null);
    },
  );
}
