import '../models/study_event.dart';
import 'package:flutter/material.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final List<StudyEvent> events;
  final void Function(DateTime day, List<StudyEvent> events) onDayTap;

  const MonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.events,
    required this.onDayTap,
  });

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String _monthName(int month) {
    const names = [
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
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F162A) : Colors.white;
    final cellSurface = isDark
        ? const Color(0xFF171F33)
        : const Color(0xFFFBFCFF);
    final border = isDark ? const Color(0xFF27304B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = Theme.of(context).colorScheme.onSurfaceVariant;

    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      displayedMonth.year,
      displayedMonth.month,
    );
    final offset = firstDay.weekday - 1;
    final totalSlots = ((offset + daysInMonth + 6) ~/ 7) * 7;

    final today = DateTime.now();
    final isCurrentDisplayedMonth =
        today.year == displayedMonth.year &&
        today.month == displayedMonth.month;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 18 : 10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_monthName(displayedMonth.month)} ${displayedMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 86,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < offset || index >= offset + daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    color: cellSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                );
              }

              final dayNumber = index - offset + 1;
              final dayDate = DateTime(
                displayedMonth.year,
                displayedMonth.month,
                dayNumber,
              );
              final dayEvents = events
                  .where((e) => DateUtils.isSameDay(e.date, dayDate))
                  .toList();
              final isToday = isCurrentDisplayedMonth && dayNumber == today.day;

              return InkWell(
                onTap: () => onDayTap(dayDate, dayEvents),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cellSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? const Color(0xFF7C3AED)
                                : Colors.transparent,
                          ),
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isToday ? Colors.white : textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (dayEvents.isEmpty)
                        const Spacer()
                      else
                        ...dayEvents
                            .take(2)
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: event.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      if (dayEvents.length > 2)
                        Text(
                          '+${dayEvents.length - 2} more',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
