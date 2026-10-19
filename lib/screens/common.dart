import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../branding.dart';
import '../models/event.dart';
import '../planner.dart';

IconData statusIcon(String status) => switch (status) {
  'Going' => Icons.check_circle_outline,
  'Attended' => Icons.task_alt,
  _ => Icons.bookmark_border,
};

class AppFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Planner planner;
  final int? selected;
  final bool add;
  final String? addLocation;
  final List<Widget>? actions;
  const AppFrame({
    super.key,
    required this.title,
    required this.child,
    required this.planner,
    this.selected,
    this.add = false,
    this.addLocation,
    this.actions,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: selected != null
          ? AppBrand(
              subtitle: selected == 2 ? 'Calendar' : 'Campus event planner',
            )
          : Text(title),
      leading: selected == null
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            )
          : null,
      actions: actions,
    ),
    body: SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              ListenableBuilder(
                listenable: planner,
                builder: (c, _) => planner.warning == null
                    ? const SizedBox.shrink()
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: HubColors.pale,
                        child: Text(
                          planner.warning!,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: selected == null
        ? null
        : PlannerNavigation(
            selected: selected!,
            addLocation: addLocation ?? '/events/new',
          ),
    // Expanded timetable has no navigation bar, but retains the calendar's Add action.
    floatingActionButton: selected == null && add
        ? FloatingActionButton.extended(
            onPressed: () => context.push(addLocation ?? '/events/new'),
            backgroundColor: HubColors.green,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add event'),
          )
        : null,
  );
}

class PlannerNavigation extends StatelessWidget {
  final int selected;
  final String addLocation;
  const PlannerNavigation({
    super.key,
    required this.selected,
    required this.addLocation,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
    child: Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: HubColors.line),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0c213830),
                blurRadius: 22,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: LayoutBuilder(
              builder: (c, box) => Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        child: _destination(
                          context,
                          i,
                          horizontal: box.maxWidth > 460,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget _destination(BuildContext context, int i, {required bool horizontal}) {
    const labels = ['Home', 'Events', 'Calendar', 'Add event'];
    const icons = [
      Icons.space_dashboard_outlined,
      Icons.event_note_outlined,
      Icons.calendar_month_outlined,
      Icons.add,
    ];
    final active = i == selected, isAdd = i == 3;
    final color = isAdd
        ? Colors.white
        : active
        ? HubColors.green
        : HubColors.muted;
    final pieces = [
      Icon(icons[i], size: 22, color: color),
      SizedBox(width: horizontal ? 7 : 0, height: horizontal ? 0 : 5),
      FlexibleText(label: labels[i], color: color, horizontal: horizontal),
    ];
    return Semantics(
      selected: active,
      child: TextButton(
        key: ValueKey('nav-${labels[i]}'),
        onPressed: () {
          if (isAdd) {
            context.push(addLocation);
          } else if (i != selected) {
            context.go(['/dashboard', '/events', '/calendar'][i]);
          }
        },
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 60),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 9),
          backgroundColor: isAdd
              ? HubColors.green
              : active
              ? HubColors.pale
              : Colors.transparent,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: horizontal
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: pieces)
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: pieces,
              ),
      ),
    );
  }
}

class FlexibleText extends StatelessWidget {
  final String label;
  final Color color;
  final bool horizontal;
  const FlexibleText({
    super.key,
    required this.label,
    required this.color,
    required this.horizontal,
  });
  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: horizontal ? 12 : 11,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
    return horizontal ? Flexible(child: text) : text;
  }
}

class Content extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Content({super.key, required this.child, this.maxWidth = 1120});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width < 600 ? 20 : 28,
          28,
          MediaQuery.sizeOf(context).width < 600 ? 20 : 28,
          32,
        ),
        child: child,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, message;
  final IconData icon;
  final VoidCallback? onAdd;
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.calendar_today_outlined,
    this.onAdd,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xfff8faf5),
              border: Border.all(color: HubColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: const Color(0xff7d947f)),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: HubColors.muted, fontSize: 13),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add an event'),
            ),
          ],
        ],
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: status == 'Attended' ? const Color(0xffeeeff3) : HubColors.pale,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon(status), size: 15, color: HubColors.green),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            status,
            style: const TextStyle(fontSize: 12, color: HubColors.green),
          ),
        ),
      ],
    ),
  );
}

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => context.push('/events/${event.id}'),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xfff3f6ef),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: HubColors.line),
              ),
              child: Column(
                children: [
                  Text(
                    monthNames[event.start.month - 1]
                        .substring(0, 3)
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: HubColors.muted),
                  ),
                  Text(
                    '${event.start.day}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${timeLabel(event.start)} – ${timeLabel(event.end)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HubColors.muted,
                    ),
                  ),
                  Text(
                    event.venue,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HubColors.muted,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 12,
                    runSpacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        event.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: HubColors.muted,
                        ),
                      ),
                      StatusBadge(status: event.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: HubColors.muted),
          ],
        ),
      ),
    ),
  );
}

Widget sectionTitle(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.only(top: 23, bottom: 12),
  child: Text(title, style: Theme.of(context).textTheme.titleMedium),
);
