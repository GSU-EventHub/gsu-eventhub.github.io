import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsu_eventhub/planner.dart';
import 'package:gsu_eventhub/storage/file_store.dart';
import 'planner_test.dart' show fixture;

void main() {
  late Directory directory;
  setUp(
    () => directory = Directory.systemTemp.createTempSync('eventhub-test-'),
  );
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'native events, edits, and final deletion survive reopening storage',
    () {
      final planner = Planner(FileStore(directory));
      expect(planner.events, isEmpty);
      expect(planner.save(fixture()), isTrue);
      final reopened = Planner(FileStore(directory));
      expect(reopened.events.single.title, 'Research seminar');
      expect(reopened.save(fixture(title: 'Edited event')), isTrue);
      expect(Planner(FileStore(directory)).events.single.title, 'Edited event');
      expect(reopened.delete('one'), isTrue);
      expect(Planner(FileStore(directory)).events, isEmpty);
    },
  );

  test('interrupted temporary files do not replace saved events', () {
    final planner = Planner(FileStore(directory))..save(fixture());
    File(
      '${directory.path}/${Planner.storageKey}.json.tmp',
    ).writeAsStringSync('incomplete');
    expect(
      Planner(FileStore(directory)).events.single.id,
      planner.events.single.id,
    );
  });

  test('native malformed data is preserved until an intentional save', () {
    final file = File('${directory.path}/${Planner.storageKey}.json')
      ..writeAsStringSync('invalid JSON');
    final planner = Planner(FileStore(directory));
    expect(planner.events, isEmpty);
    expect(planner.warning, isNotNull);
    expect(file.readAsStringSync(), 'invalid JSON');
    expect(planner.save(fixture()), isTrue);
    expect(Planner(FileStore(directory)).events, hasLength(1));
  });

  test('failed native writes retain the saved list', () {
    final planner = Planner(FileStore(directory))..save(fixture());
    Directory('${directory.path}/${Planner.storageKey}.json.tmp').createSync();
    expect(planner.delete('one'), isFalse);
    expect(planner.events, hasLength(1));
    expect(Planner(FileStore(directory)).events, hasLength(1));
    expect(planner.warning, isNotNull);
  });
}
