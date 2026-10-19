import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsu_eventhub/models/event.dart';
import 'package:gsu_eventhub/planner.dart';
import 'package:gsu_eventhub/storage/memory_store.dart';

Event fixture({
  String id = 'one',
  String title = 'Research seminar',
  String venue = 'Main hall',
  String category = 'Seminar',
  String status = 'Interested',
  int hour = 9,
}) => Event(
  id: id,
  title: title,
  venue: venue,
  category: category,
  status: status,
  start: DateTime(2030, 5, 10, hour),
  end: DateTime(2030, 5, 10, hour + 1),
);

class FailingStore extends BrowserStore {
  @override
  void write(String key, String value) => throw StateError('Quota');
}

void main() {
  test('fresh planner is empty, persists edits and intentional deletion', () {
    final disk = BrowserStore();
    final p = Planner(disk);
    expect(p.events, isEmpty);
    expect(p.save(fixture()), isTrue);
    expect(Planner(disk).events.single.title, 'Research seminar');
    expect(p.save(fixture(title: 'Updated workshop')), isTrue);
    expect(Planner(disk).events.single.title, 'Updated workshop');
    expect(p.delete('one'), isTrue);
    expect(Planner(disk).events, isEmpty);
    expect(jsonDecode(disk.values[Planner.storageKey]!)['events'], isEmpty);
  });
  test(
    'search, combined category/status filters and chronological ordering',
    () {
      final p = Planner(BrowserStore());
      p.save(fixture(id: 'late', hour: 14, status: 'Going'));
      p.save(fixture(id: 'early', hour: 8));
      p.save(
        fixture(
          id: 'sport',
          venue: 'Gym',
          category: 'Sports',
          status: 'Going',
          hour: 10,
        ),
      );
      expect(p.filtered().map((e) => e.id), ['early', 'sport', 'late']);
      p.query = 'gYm';
      expect(p.filtered().single.id, 'sport');
      p.category = 'Seminar';
      expect(p.filtered(), isEmpty);
      p.query = 'research';
      p.status = 'Going';
      expect(p.filtered().single.id, 'late');
    },
  );
  test(
    'invalid data recovers valid records and does not silently overwrite',
    () {
      final disk = BrowserStore();
      final raw = jsonEncode({
        'version': 1,
        'events': [
          fixture().toJson(),
          {'bad': true},
          fixture().toJson(),
        ],
      });
      disk.values[Planner.storageKey] = raw;
      final p = Planner(disk);
      expect(p.events, hasLength(1));
      expect(p.warning, contains('2 invalid'));
      expect(disk.values[Planner.storageKey], raw);
    },
  );
  test('malformed data and unsupported schema fail gracefully', () {
    for (final raw in ['not json', '[]', '{"version":2,"events":[]}']) {
      final disk = BrowserStore()..values[Planner.storageKey] = raw;
      final p = Planner(disk);
      expect(p.events, isEmpty);
      expect(p.warning, isNotNull);
      expect(p.save(fixture()), isTrue);
      expect(Planner(disk).events, hasLength(1));
    }
  });
  test('failed storage write keeps current events and exposes warning', () {
    final p = Planner(FailingStore());
    expect(p.save(fixture()), isFalse);
    expect(p.events, isEmpty);
    expect(p.warning, contains('could not save'));
  });
  test('date/time validation rejects rollover, wrong hours, missing AM/PM', () {
    expect(parseDate('2030-02-30'), isNull);
    expect(parseDate('2032-02-29'), isNotNull);
    expect(parseDate('2030-1-01'), isNull);
    expect(parseTime('12:00 AM'), 0);
    expect(parseTime('12:00 PM'), 720);
    expect(parseTime('1:05 pm'), 785);
    expect(parseTime('13:00 PM'), isNull);
    expect(parseTime('9:60 AM'), isNull);
    expect(parseTime('09:00'), isNull);
  });
  test('invalid persisted event is rejected', () {
    final raw = fixture().toJson();
    raw['end'] = raw['start'];
    expect(() => Event.fromJson(raw), throwsFormatException);
  });
}
