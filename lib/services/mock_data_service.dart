import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/plan_template.dart';
import '../models/study_event.dart';

class MockDataService {
  static List<String> subjects = [
    'Math',
    'SQL',
    'Programming',
    'UI Design',
    'English',
  ];

  static List<String> learningTips = [
    'Use active recall before rereading. Try to answer from memory first, then check your notes.',
  ];

  static List<_EventSeed> _eventSeeds = const [
    _EventSeed(
      title: 'Submit programming homework',
      course: 'Programming',
      day: 18,
      color: Color(0xFF06B6D4),
    ),
  ];

  static Map<String, List<PlanTemplate>> _templatesBySubject = {
    'Math': const [
      PlanTemplate(
        title: 'Review key formulas',
        details:
            'Go through the main formulas and summary notes for 45 minutes.',
      ),
    ],
  };

  static bool _loaded = false;

  /// Clears cached seed data (for tests).
  static void reset() {
    _loaded = false;
  }

  static List<String> get allLearningTips => List<String>.unmodifiable(learningTips);

  static Future<void> loadFromAssets() async {
    if (_loaded) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/studyflow_seed_data.json',
    );
    loadFromJsonString(jsonString);
  }

  static void loadFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    subjects = (decoded['subjects'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    learningTips = (decoded['learningTips'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    _eventSeeds = (decoded['eventSeeds'] as List<dynamic>).map((item) {
      final map = item as Map<String, dynamic>;
      return _EventSeed(
        title: map['title'].toString(),
        course: map['course'].toString(),
        day: map['day'] as int,
        color: _colorFromHex(map['color'].toString()),
      );
    }).toList();

    final templates = decoded['templates'] as Map<String, dynamic>;
    _templatesBySubject = templates.map((subject, value) {
      final items = (value as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        return PlanTemplate(
          title: map['title'].toString(),
          details: map['details'].toString(),
        );
      }).toList();

      return MapEntry(subject, items);
    });

    _loaded = true;
  }

  static String getRandomTip() {
    if (learningTips.isEmpty) {
      return 'Create a clear study goal and review it at the end of the day.';
    }

    return learningTips[Random().nextInt(learningTips.length)];
  }

  static List<StudyEvent> buildEventsAroundNow(DateTime now) {
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    final events = [
      ..._seedMonthEvents(previousMonth),
      ..._seedMonthEvents(currentMonth),
      ..._seedMonthEvents(nextMonth),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  static List<StudyEvent> _seedMonthEvents(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    int safeDay(int day) => min(max(day, 1), daysInMonth);

    return _eventSeeds.map((seed) {
      return StudyEvent(
        title: seed.title,
        course: seed.course,
        date: DateTime(month.year, month.month, safeDay(seed.day)),
        color: seed.color,
      );
    }).toList();
  }

  static List<PlanTemplate> templatesForSubject(String subject) {
    return _templatesBySubject[subject] ??
        _templatesBySubject['English'] ??
        const [
          PlanTemplate(
            title: 'Study session',
            details: 'Review the topic and complete one focused exercise.',
          ),
        ];
  }

  static Color _colorFromHex(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }
}

class _EventSeed {
  final String title;
  final String course;
  final int day;
  final Color color;

  const _EventSeed({
    required this.title,
    required this.course,
    required this.day,
    required this.color,
  });
}
