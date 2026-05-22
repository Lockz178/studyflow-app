import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database seeded on first launch from the bundled JSON asset.
///
/// Satisfies the coursework requirement:
/// "Data comes from … a database populated with a JSON file in the assets."
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'studyflow.db'),
      version: 1,
      onCreate: _createTables,
    );
    await _seedIfEmpty();
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE learning_tips (
        id  INTEGER PRIMARY KEY AUTOINCREMENT,
        tip TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE event_seeds (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        title  TEXT    NOT NULL,
        course TEXT    NOT NULL,
        day    INTEGER NOT NULL,
        color  TEXT    NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE plan_templates (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        title   TEXT NOT NULL,
        details TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedIfEmpty() async {
    final count = Sqflite.firstIntValue(
          await _db!.rawQuery('SELECT COUNT(*) FROM subjects'),
        ) ??
        0;
    if (count > 0) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/studyflow_seed_data.json',
    );
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final batch = _db!.batch();

    for (final name in decoded['subjects'] as List<dynamic>) {
      batch.insert('subjects', {'name': name.toString()});
    }

    for (final tip in decoded['learningTips'] as List<dynamic>) {
      batch.insert('learning_tips', {'tip': tip.toString()});
    }

    for (final seed in decoded['eventSeeds'] as List<dynamic>) {
      final m = seed as Map<String, dynamic>;
      batch.insert('event_seeds', {
        'title': m['title'].toString(),
        'course': m['course'].toString(),
        'day': m['day'] as int,
        'color': m['color'].toString(),
      });
    }

    final templates = decoded['templates'] as Map<String, dynamic>;
    for (final entry in templates.entries) {
      for (final item in entry.value as List<dynamic>) {
        final m = item as Map<String, dynamic>;
        batch.insert('plan_templates', {
          'subject': entry.key,
          'title': m['title'].toString(),
          'details': m['details'].toString(),
        });
      }
    }

    await batch.commit(noResult: true);
  }

  Future<List<String>> getSubjects() async {
    final rows = await _db!.query('subjects', orderBy: 'id');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<String>> getLearningTips() async {
    final rows = await _db!.query('learning_tips', orderBy: 'id');
    return rows.map((r) => r['tip'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getEventSeeds() async {
    return _db!.query('event_seeds', orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getTemplatesForSubject(
    String subject,
  ) async {
    return _db!.query(
      'plan_templates',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'id',
    );
  }
}
