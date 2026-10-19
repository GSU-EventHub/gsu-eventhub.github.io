import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'models/event.dart';
import 'storage/key_value.dart';

class Planner extends ChangeNotifier {
  static const storageKey = 'gsu-eventhub.events.v1';
  final KeyValueStore storage;
  List<Event> _events = [];
  List<Event> get events => List.unmodifiable(_events);
  String? warning;
  DateTime selectedDate = DateTime.now();
  String calendarView = 'Month';
  double calendarVertical = 420,
      calendarHorizontal = 0,
      calendarMonthScroll = 0;
  String query = '', category = 'All', status = 'All';
  String eventSection = 'Upcoming';
  void updateFilters({String? search, String? category, String? status}) {
    if (search != null) query = search;
    if (category != null) this.category = category;
    if (status != null) this.status = status;
    notifyListeners();
  }

  void selectSection(String value) {
    eventSection = value;
    notifyListeners();
  }

  Planner(this.storage) {
    load();
  }

  void load() {
    _events = [];
    warning = null;
    try {
      final raw = storage.read(storageKey);
      if (raw == null) return;
      final data = jsonDecode(raw);
      if (data is! Map || data['version'] != 1 || data['events'] is! List) {
        throw const FormatException('Unrecognized saved data');
      }
      var skipped = 0;
      final seen = <String>{};
      for (final item in data['events']) {
        try {
          final event = Event.fromJson(Map<String, dynamic>.from(item as Map));
          if (!seen.add(event.id)) throw const FormatException('Duplicate ID');
          _events.add(event);
        } catch (_) {
          skipped++;
        }
      }
      if (skipped > 0) {
        warning =
            '$skipped invalid saved event(s) could not be loaded. Valid events are still available.';
      }
    } catch (_) {
      warning =
          'Saved data could not be read. You can start a new planner; saving will replace unreadable data.';
    }
  }

  Event? find(String id) {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  bool _commit(List<Event> next) {
    try {
      storage.write(
        storageKey,
        jsonEncode({
          'version': 1,
          'events': next.map((e) => e.toJson()).toList(),
        }),
      );
      _events = next;
      warning = null;
      notifyListeners();
      return true;
    } catch (_) {
      warning =
          'Your browser could not save this change. Check available storage and privacy settings, then try again.';
      notifyListeners();
      return false;
    }
  }

  bool save(Event event) =>
      _commit([..._events.where((e) => e.id != event.id), event]);
  bool delete(String id) => _commit(_events.where((e) => e.id != id).toList());
  List<Event> filtered() {
    final q = query.trim().toLowerCase();
    return _events
        .where(
          (e) =>
              (q.isEmpty ||
                  e.title.toLowerCase().contains(q) ||
                  e.venue.toLowerCase().contains(q)) &&
              (category == 'All' || e.category == category) &&
              (status == 'All' || e.status == status),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }
}
