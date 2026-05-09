import 'dart:math';
import 'package:flutter/material.dart';
import '../models/study_event.dart';
import '../models/plan_template.dart';

class MockDataService {
  static const List<String> subjects = [
    'Math',
    'SQL',
    'Programming',
    'UI Design',
    'English',
  ];

  static const List<String> learningTips = [
    'Use active recall before rereading. Try to answer from memory first, then check your notes.',
    'For harder subjects, study in short focused blocks and finish each block with one quick recap.',
    'A premium study routine is simple: one clear goal, one distraction-free block, one short review.',
    'When a task feels too big, break it into review, practice, and recap. Small wins reduce stress.',
    'Track visible progress. A clear plan and a moving progress bar make it easier to stay consistent.',
    'Do the most mentally difficult task first while your energy is still high.',
  ];

  static String getRandomTip() {
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

    return [
      StudyEvent(
        title: 'Database assignment submission',
        course: 'SQL Basics',
        date: DateTime(month.year, month.month, safeDay(2)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'UI workshop revision',
        course: 'Mobile App Design',
        date: DateTime(month.year, month.month, safeDay(4)),
        color: const Color(0xFF8B5CF6),
      ),
      StudyEvent(
        title: 'Math practice set',
        course: 'Calculus',
        date: DateTime(month.year, month.month, safeDay(9)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'Pair discussion meeting',
        course: 'Communication Skills',
        date: DateTime(month.year, month.month, safeDay(13)),
        color: const Color(0xFFEC4899),
      ),
      StudyEvent(
        title: 'Submit programming homework',
        course: 'Programming',
        date: DateTime(month.year, month.month, safeDay(18)),
        color: const Color(0xFF06B6D4),
      ),
      StudyEvent(
        title: 'Server lab checkpoint',
        course: 'Server Technologies',
        date: DateTime(month.year, month.month, safeDay(24)),
        color: const Color(0xFFF97316),
      ),
      StudyEvent(
        title: 'Security week review',
        course: 'Cybersecurity',
        date: DateTime(month.year, month.month, safeDay(26)),
        color: const Color(0xFF8B5CF6),
      ),
      StudyEvent(
        title: 'HTTPS practice task',
        course: 'Web Services',
        date: DateTime(month.year, month.month, safeDay(30)),
        color: const Color(0xFFF97316),
      ),
    ];
  }

  static List<PlanTemplate> templatesForSubject(String subject) {
    switch (subject) {
      case 'Math':
        return const [
          PlanTemplate(
            title: 'Review key formulas',
            details:
                'Go through the main formulas and summary notes for 45 minutes.',
          ),
          PlanTemplate(
            title: 'Solve easy exercises',
            details:
                'Warm up with simple questions and focus on correct method.',
          ),
          PlanTemplate(
            title: 'Medium practice set',
            details: 'Solve mixed problems without checking notes too early.',
          ),
          PlanTemplate(
            title: 'Fix weak areas',
            details: 'Review mistakes and rewrite full correct solution steps.',
          ),
          PlanTemplate(
            title: 'Timed problem session',
            details: 'Simulate a short test and manage time more carefully.',
          ),
          PlanTemplate(
            title: 'Formula recap',
            details:
                'Condense the important formulas into one clean review page.',
          ),
          PlanTemplate(
            title: 'Final revision',
            details:
                'Mix theory, formulas, and harder problems in one session.',
          ),
        ];
      case 'SQL':
        return const [
          PlanTemplate(
            title: 'Review SQL basics',
            details: 'Study SELECT, WHERE, ORDER BY, and LIMIT with examples.',
          ),
          PlanTemplate(
            title: 'Filtering practice',
            details:
                'Write queries with conditions, sorting, and pattern matching.',
          ),
          PlanTemplate(
            title: 'Joins focus',
            details: 'Practice INNER JOIN and LEFT JOIN on sample tables.',
          ),
          PlanTemplate(
            title: 'Aggregation day',
            details: 'Use COUNT, AVG, SUM, GROUP BY, and HAVING in exercises.',
          ),
          PlanTemplate(
            title: 'Mini assignment',
            details: 'Complete one realistic database task end to end.',
          ),
          PlanTemplate(
            title: 'Debug wrong queries',
            details:
                'Review failed queries and understand the logic behind fixes.',
          ),
          PlanTemplate(
            title: 'Final SQL recap',
            details:
                'Mix joins, filters, and aggregates in one focused review.',
          ),
        ];
      case 'Programming':
        return const [
          PlanTemplate(
            title: 'Core syntax review',
            details:
                'Refresh variables, conditions, functions, and basic structure.',
          ),
          PlanTemplate(
            title: 'Small coding tasks',
            details: 'Solve short exercises and focus on readable code.',
          ),
          PlanTemplate(
            title: 'Loops and collections',
            details:
                'Practice iteration, lists, arrays, and common logic patterns.',
          ),
          PlanTemplate(
            title: 'Build one mini feature',
            details:
                'Turn a small idea into working code from start to finish.',
          ),
          PlanTemplate(
            title: 'Debugging session',
            details: 'Find and fix errors slowly, one cause at a time.',
          ),
          PlanTemplate(
            title: 'Refactor session',
            details:
                'Clean naming, remove clutter, and improve code structure.',
          ),
          PlanTemplate(
            title: 'Final mixed challenge',
            details: 'Combine several concepts in one realistic practice task.',
          ),
        ];
      case 'UI Design':
        return const [
          PlanTemplate(
            title: 'Layout principles',
            details:
                'Study spacing, alignment, and visual hierarchy in mobile UI.',
          ),
          PlanTemplate(
            title: 'Design inspiration review',
            details: 'Analyze modern screens and note what feels premium.',
          ),
          PlanTemplate(
            title: 'Wireframe practice',
            details: 'Sketch rough screens before thinking about colors.',
          ),
          PlanTemplate(
            title: 'Typography and color',
            details:
                'Focus on contrast, font scale, and cleaner visual rhythm.',
          ),
          PlanTemplate(
            title: 'Improve one screen',
            details:
                'Take one weak screen and redesign it more professionally.',
          ),
          PlanTemplate(
            title: 'Consistency check',
            details: 'Unify buttons, cards, icons, spacing, and corner radius.',
          ),
          PlanTemplate(
            title: 'Final polish pass',
            details: 'Review the whole interface and refine small details.',
          ),
        ];
      default:
        return const [
          PlanTemplate(
            title: 'Vocabulary review',
            details: 'Revise useful academic words and short examples.',
          ),
          PlanTemplate(
            title: 'Reading session',
            details: 'Read an article and highlight difficult expressions.',
          ),
          PlanTemplate(
            title: 'Writing practice',
            details: 'Write one paragraph and improve grammar and clarity.',
          ),
          PlanTemplate(
            title: 'Listening practice',
            details: 'Listen to English content and summarize the main idea.',
          ),
          PlanTemplate(
            title: 'Speaking practice',
            details: 'Explain a topic aloud and work on fluency.',
          ),
          PlanTemplate(
            title: 'Grammar focus',
            details: 'Review one grammar topic and do short exercises.',
          ),
          PlanTemplate(
            title: 'Final recap',
            details: 'Mix vocabulary, reading, and writing in one session.',
          ),
        ];
    }
  }
}
