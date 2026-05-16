import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plan_item.dart';
import '../models/study_event.dart';
import '../models/study_plan.dart';
import '../services/mock_data_service.dart';

class StudyFlowController extends ChangeNotifier {
  static const _plansKey = 'studyflow_plans';

  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String _learningTip = '';
  List<StudyEvent> _allEvents = [];
  int _deadlineWindowDays = 7;

  final List<StudyPlan> _plans = [];
  bool _isLoadingSeedData = true;
  String? _seedDataError;

  DateTime get displayedMonth => _displayedMonth;
  String get learningTip => _learningTip;
  List<StudyEvent> get allEvents => List.unmodifiable(_allEvents);
  int get deadlineWindowDays => _deadlineWindowDays;
  List<StudyPlan> get plans => List.unmodifiable(_plans);
  bool get isLoadingSeedData => _isLoadingSeedData;
  String? get seedDataError => _seedDataError;

  StudyPlan? planById(String id) {
    for (final p in _plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> initialize() async {
    await loadSeedData(DateTime.now());
    await _restorePlans();
  }

  Future<void> _persistPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _plans.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_plansKey, list);
    } catch (_) {}
  }

  Future<void> _restorePlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_plansKey);
      if (list == null || list.isEmpty) return;
      final loaded = list
          .map((s) => StudyPlan.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
      _plans.addAll(loaded);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadSeedData(DateTime now) async {
    _isLoadingSeedData = true;
    _seedDataError = null;
    notifyListeners();

    try {
      await MockDataService.loadFromAssets();
      _learningTip = MockDataService.getRandomTip();
      _allEvents = MockDataService.buildEventsAroundNow(now);
      _isLoadingSeedData = false;
      _seedDataError = null;
    } catch (error) {
      _seedDataError = error.toString();
      _isLoadingSeedData = false;
    }
    notifyListeners();
  }

  void setDeadlineWindowDays(int days) {
    _deadlineWindowDays = days;
    notifyListeners();
  }

  void previousMonth() {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
      1,
    );
    notifyListeners();
  }

  void nextMonth() {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      1,
    );
    notifyListeners();
  }

  void deletePlanById(String planId) {
    _plans.removeWhere((plan) => plan.id == planId);
    notifyListeners();
    _persistPlans();
  }

  void notifyPlansUpdated() {
    notifyListeners();
    _persistPlans();
  }

  StudyPlan buildPlan({
    required String topic,
    required String subject,
    required int totalDays,
  }) {
    final templates = MockDataService.templatesForSubject(subject);

    final items = List.generate(totalDays, (index) {
      final template = templates[index % templates.length];
      return PlanItem(
        day: index + 1,
        title: template.title,
        details: template.details,
      );
    });

    return StudyPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      topic: topic,
      subject: subject,
      totalDays: totalDays,
      createdAt: DateTime.now(),
      items: items,
    );
  }

  StudyPlan addPlan({
    required String topic,
    required String subject,
    required int totalDays,
  }) {
    final cleanTopic = topic.trim().isEmpty ? subject : topic.trim();
    final plan = buildPlan(
      topic: cleanTopic,
      subject: subject,
      totalDays: totalDays,
    );
    _plans.insert(0, plan);
    notifyListeners();
    _persistPlans();
    return plan;
  }

  void createPlanFromValues({
    required String topic,
    required String subject,
    required int totalDays,
  }) {
    addPlan(topic: topic, subject: subject, totalDays: totalDays);
  }

  List<StudyEvent> eventsForMonth(DateTime month) {
    return _allEvents.where((event) {
      return event.date.year == month.year && event.date.month == month.month;
    }).toList();
  }

  List<StudyEvent> deadlinesToday() {
    final now = DateTime.now();
    return _allEvents
        .where((event) => DateUtils.isSameDay(event.date, now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudyEvent> deadlinesForWindow(int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));

    return _allEvents.where((event) {
      final eventDay = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      return !eventDay.isBefore(start) && eventDay.isBefore(end);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  StudyEvent? nextDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _allEvents.where((event) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      return !day.isBefore(today);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  StudyPlan? firstActivePlan() {
    for (final plan in _plans) {
      if (!plan.isCompleted) return plan;
    }
    return _plans.isNotEmpty ? _plans.first : null;
  }
}
