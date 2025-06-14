import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/workout.dart';
import '../../providers/workout_data.dart';

class CalendarSection extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const CalendarSection({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.onFormatChanged,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  List<WorkoutRecord> _getWorkoutsForDay(BuildContext context, DateTime day) {
    final provider = Provider.of<WorkoutData>(context, listen: false);
    return provider.workoutsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      color: isDark
          ? Colors.grey[850]
          : Theme.of(context).colorScheme.primary.withAlpha(26),
      child: TableCalendar<WorkoutRecord>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            eventLoader: (day) => _getWorkoutsForDay(context, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(color: textColor),
              weekendTextStyle: TextStyle(color: textColor),
              outsideTextStyle: TextStyle(
                color: textColor?.withAlpha((0.5 * 255).round()),
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withAlpha(179),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle:
                  Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
          ),
    );
  }
}
