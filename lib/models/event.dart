const categories = ['Seminar', 'Workshop', 'Sports', 'Club Activity', 'Other'];
const statuses = ['Interested', 'Going', 'Attended'];

class Event {
  final String id, title, venue, category, status, organizer, description;
  final DateTime start, end;
  const Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.category,
    required this.status,
    required this.start,
    required this.end,
    this.organizer = '',
    this.description = '',
  });

  bool get isPast => end.isBefore(DateTime.now());
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'venue': venue,
    'category': category,
    'status': status,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'organizer': organizer,
    'description': description,
  };
  factory Event.fromJson(Map<String, dynamic> json) {
    String field(String name) =>
        json[name] is String ? json[name] as String : '';
    final start = DateTime.parse(field('start'));
    final end = DateTime.parse(field('end'));
    if (!RegExp(r'^[A-Za-z0-9_-]{1,100}$').hasMatch(field('id')) ||
        field('title').trim().isEmpty ||
        field('venue').trim().isEmpty ||
        !categories.contains(field('category')) ||
        !statuses.contains(field('status')) ||
        !end.isAfter(start) ||
        start.year != end.year ||
        start.month != end.month ||
        start.day != end.day) {
      throw const FormatException('Invalid event');
    }
    return Event(
      id: field('id'),
      title: field('title'),
      venue: field('venue'),
      category: field('category'),
      status: field('status'),
      start: start,
      end: end,
      organizer: field('organizer'),
      description: field('description'),
    );
  }
}

const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String dateLabel(DateTime date) =>
    '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
String timeLabel(DateTime date) =>
    '${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
String dateInput(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
DateTime? parseDate(String text) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) return null;
  final d = DateTime.tryParse(text);
  return d != null && dateInput(d) == text && d.year >= 1900 && d.year <= 2200
      ? d
      : null;
}

int? parseTime(String text) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(text.trim());
  if (match == null) return null;
  final h = int.parse(match[1]!);
  final m = int.parse(match[2]!);
  if (h < 1 || h > 12 || m > 59) return null;
  return (h % 12 + (match[3]!.toUpperCase() == 'PM' ? 12 : 0)) * 60 + m;
}
