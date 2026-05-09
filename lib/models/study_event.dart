import 'package:flutter/material.dart';

class StudyEvent {
  final String title;
  final String course;
  final DateTime date;
  final Color color;

  const StudyEvent({
    required this.title,
    required this.course,
    required this.date,
    required this.color,
  });
}
