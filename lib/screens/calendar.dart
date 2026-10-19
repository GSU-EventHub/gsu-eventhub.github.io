import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../planner.dart';
import '../models/event.dart';
import 'common.dart';

class CalendarScreen extends StatefulWidget {
  final Planner planner;
  final bool expanded;
  const CalendarScreen({
    super.key,
    required this.planner,
    this.expanded = false,
  });
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final vertical = ScrollController(
    initialScrollOffset: widget.planner.calendarVertical,
  );
  late final monthScroll = ScrollController(
    initialScrollOffset: widget.planner.calendarMonthScroll,
  );
  late final horizontal = ScrollController(
    initialScrollOffset: widget.planner.calendarHorizontal,
  );
  Planner get p => widget.planner;
  @override
  void initState() {
    super.initState();
    monthScroll.addListener(() => p.calendarMonthScroll = monthScroll.offset);
    vertical.addListener(() => p.calendarVertical = vertical.offset);
    horizontal.addListener(() => p.calendarHorizontal = horizontal.offset);
  }

  @override
  void dispose() {
    monthScroll.dispose();
    vertical.dispose();
    horizontal.dispose();
    super.dispose();
  }

  void move(int amount) => setState(() {
    final d = p.selectedDate;
    p.selectedDate = p.calendarView == 'Month'
        ? DateTime(d.year, d.month + amount, 1)
        : d.add(Duration(days: amount * (p.calendarView == 'Week' ? 7 : 1)));
  });
  DateTime get weekStart {
    final d = p.selectedDate;
    return DateTime(d.year, d.month, d.day - d.weekday + 1);
  }

  String get heading => switch (p.calendarView) {
    'Month' => '${monthNames[p.selectedDate.month - 1]} ${p.selectedDate.year}',
    'Week' =>
      '${dateLabel(weekStart)} – ${dateLabel(weekStart.add(const Duration(days: 6)))}',
    _ => dateLabel(p.selectedDate),
  };
  String addAt(DateTime d) =>
      '/events/new?at=${Uri.encodeComponent(d.toIso8601String())}';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: p,
    builder: (c, _) => AppFrame(
      title: widget.expanded ? 'Expanded timetable' : 'Calendar',
      planner: p,
      selected: widget.expanded ? null : 2,
      add: true,
      addLocation: addAt(
        p.selectedDate.copyWith(
          hour: 9,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ),
      ),
      actions: [
        IconButton(
          tooltip: widget.expanded ? 'Close expanded view' : 'Expand timetable',
          icon: Icon(
            widget.expanded ? Icons.close_fullscreen : Icons.open_in_full,
          ),
          onPressed: () {
            if (widget.expanded) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/calendar');
              }
            } else {
              if (p.calendarView == 'Month') {
                p.calendarView = 'Week';
              }
              context.push('/calendar?expanded=1');
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: ['Day', 'Week', 'Month']
                        .map(
                          (v) => ChoiceChip(
                            label: Text(v),
                            selected: p.calendarView == v,
                            onSelected: (_) => setState(() {
                              p.calendarView = v;
                              p.calendarHorizontal = 0;
                              if (horizontal.hasClients) {
                                horizontal.jumpTo(0);
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => p.selectedDate = DateTime.now()),
                  child: const Text('Today'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous',
                  onPressed: () => move(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    heading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next',
                  onPressed: () => move(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: p.calendarView == 'Month' ? month() : timetable()),
          ],
        ),
      ),
    ),
  );
  Widget month() {
    final first = DateTime(p.selectedDate.year, p.selectedDate.month, 1);
    final begin = first.subtract(Duration(days: first.weekday - 1));
    final rows =
        ((first.weekday - 1 + DateTime(first.year, first.month + 1, 0).day) / 7)
            .ceil();
    final selected =
        p.events.where((e) => sameDay(e.start, p.selectedDate)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return SingleChildScrollView(
      controller: monthScroll,
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: weekdays
                .map(
                  (d) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...List.generate(
            rows,
            (row) => Row(
              children: List.generate(7, (col) {
                final d = DateTime(
                  begin.year,
                  begin.month,
                  begin.day + row * 7 + col,
                );
                final count = p.events.where((e) => sameDay(e.start, d)).length;
                final active = sameDay(d, p.selectedDate);
                return Expanded(
                  child: Semantics(
                    label: '${dateLabel(d)}, $count events',
                    selected: active,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => p.selectedDate = d),
                      child: Container(
                        height: 66,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: active ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffdddddd)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : d.month == first.month
                                    ? Colors.black
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (count > 0)
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: active ? Colors.white : Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          sectionTitle(context, dateLabel(p.selectedDate)),
          if (selected.isEmpty)
            const EmptyState(
              title: 'An open day',
              message: 'Add an event or select another date.',
            ),
          ...selected.map((e) => EventCard(event: e)),
        ],
      ),
    );
  }

  Widget timetable() => LayoutBuilder(
    builder: (context, size) {
      final count = p.calendarView == 'Day' ? 1 : 7;
      final begin = count == 1
          ? DateTime(
              p.selectedDate.year,
              p.selectedDate.month,
              p.selectedDate.day,
            )
          : weekStart;
      final width = max(
        size.maxWidth,
        count == 7 ? 7 * 145.0 + 64 : size.maxWidth,
      );
      final dayWidth = (width - 64) / count;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (count == 7 && width > size.maxWidth)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Scroll sideways for more days. Tap an hour to add.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          Expanded(
            child: Scrollbar(
              controller: horizontal,
              thumbVisibility: count == 7,
              notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: horizontal,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 64),
                          ...List.generate(count, (i) {
                            final d = DateTime(
                              begin.year,
                              begin.month,
                              begin.day + i,
                            );
                            return SizedBox(
                              width: dayWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '${weekdays[d.weekday - 1]} ${d.day}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: vertical,
                          child: SingleChildScrollView(
                            controller: vertical,
                            child: SizedBox(
                              height: 24 * 60 + 8,
                              child: Stack(
                                children: [
                                  ...List.generate(
                                    24,
                                    (h) => Positioned(
                                      top: h * 60,
                                      left: 0,
                                      width: width,
                                      height: 60,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 64,
                                            child: Text(
                                              '${h % 12 == 0 ? 12 : h % 12} ${h < 12 ? 'AM' : 'PM'}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          ...List.generate(
                                            count,
                                            (i) => InkWell(
                                              onTap: () => context.push(
                                                addAt(
                                                  DateTime(
                                                    begin.year,
                                                    begin.month,
                                                    begin.day + i,
                                                    h,
                                                  ),
                                                ),
                                              ),
                                              child: Semantics(
                                                button: true,
                                                label:
                                                    'Add event on ${dateLabel(DateTime(begin.year, begin.month, begin.day + i))} at ${timeLabel(DateTime(2000, 1, 1, h))}',
                                                child: Container(
                                                  width: dayWidth,
                                                  height: 60,
                                                  decoration:
                                                      const BoxDecoration(
                                                        border: Border(
                                                          top: BorderSide(
                                                            color: Color(
                                                              0xffdddddd,
                                                            ),
                                                          ),
                                                          left: BorderSide(
                                                            color: Color(
                                                              0xffeeeeee,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ...List.generate(count, (i) {
                                    final d = DateTime(
                                      begin.year,
                                      begin.month,
                                      begin.day + i,
                                    );
                                    final events =
                                        p.events
                                            .where((e) => sameDay(e.start, d))
                                            .toList()
                                          ..sort(
                                            (a, b) =>
                                                a.start.compareTo(b.start),
                                          );
                                    // Greedy lanes keep overlapping events side by side at their actual times.
                                    final laneEnds = <DateTime>[];
                                    final lanes = <String, int>{};
                                    for (final e in events) {
                                      var lane = laneEnds.indexWhere(
                                        (end) => !end.isAfter(e.start),
                                      );
                                      if (lane < 0) {
                                        lane = laneEnds.length;
                                        laneEnds.add(e.end);
                                      } else {
                                        laneEnds[lane] = e.end;
                                      }
                                      lanes[e.id] = lane;
                                    }
                                    final laneCount = max(1, laneEnds.length);
                                    return events.map((e) {
                                      final top =
                                          e.start.hour * 60.0 + e.start.minute;
                                      final height = e.end
                                          .difference(e.start)
                                          .inMinutes
                                          .toDouble();
                                      final eventWidth =
                                          (dayWidth - 6) / laneCount;
                                      return Positioned(
                                        top: top,
                                        left:
                                            64 +
                                            i * dayWidth +
                                            lanes[e.id]! * eventWidth +
                                            3,
                                        width: eventWidth - 2,
                                        height: height,
                                        child: Semantics(
                                          label:
                                              '${e.title}, ${timeLabel(e.start)} to ${timeLabel(e.end)}, ${e.status}',
                                          button: true,
                                          child: Tooltip(
                                            message:
                                                '${e.title}\n${timeLabel(e.start)} – ${timeLabel(e.end)}\n${e.status}',
                                            child: Material(
                                              color: e.status == 'Attended'
                                                  ? const Color(0xffdedede)
                                                  : const Color(0xff242424),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: () => context.push(
                                                  '/events/${e.id}',
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Text(
                                                    '${e.title}\n${timeLabel(e.start)}\n${e.status}',
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          e.status == 'Attended'
                                                          ? Colors.black
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  }).expand((items) => items),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 85),
        ],
      );
    },
  );
}
