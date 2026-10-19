import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gsu_eventhub/main.dart' as app;
import 'package:gsu_eventhub/planner.dart';
import 'package:gsu_eventhub/storage/file_store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android persistence, CRUD, picker and dialog Back', (
    tester,
  ) async {
    Future<void> reopen() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
    }

    Future<void> tap(String text) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    Future<void> enter(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pumpAndSettle();
    }

    Planner planner() =>
        tester.widget<app.EventHub>(find.byType(app.EventHub)).planner;

    await reopen();
    expect(planner().storage, isA<FileStore>());
    expect(planner().events, isEmpty);
    expect(find.text('Your planner'), findsOneWidget);
    await tap('Add event');
    await enter('Title', 'Android workshop');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text('Android workshop'), findsOneWidget);
    await enter('Date', '2030-05-10');
    await enter('Start time', '2:00 PM');
    await enter('End time', '3:00 PM');
    await enter('Venue', 'Campus hall');
    await tap('Save event');
    expect(find.text('Event saved'), findsOneWidget);
    final id = planner().events.single.id;
    await reopen();
    expect(planner().find(id)?.title, 'Android workshop');
    await tap('Android workshop');
    await tap('Edit event');
    await enter('Title', 'Edited Android workshop');
    await tap('Going');
    await tap('Save event');
    await reopen();
    expect(planner().find(id)?.title, 'Edited Android workshop');
    expect(planner().find(id)?.status, 'Going');
    await tap('Edited Android workshop');
    await tap('Delete event');
    await binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Delete this event?'), findsNothing);
    expect(planner().events, hasLength(1));
    await tap('Delete event');
    await tap('Keep event');
    expect(planner().events, hasLength(1));
    await tap('Delete event');
    await tap('Delete');
    await reopen();
    expect(planner().events, isEmpty);
    expect(find.text('No events yet'), findsOneWidget);
    final store = planner().storage as FileStore;
    final path = '${store.directory.path}/${Planner.storageKey}.json';
    expect(File(path).readAsStringSync(), contains('"events":[]'));
    expect(tester.takeException(), isNull);
  });
}
