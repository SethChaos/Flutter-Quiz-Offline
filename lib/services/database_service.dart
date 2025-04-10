import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quizz/models/aircraft.dart';
import 'package:quizz/models/crew_type.dart';
import 'package:quizz/models/topic.dart';
import 'package:quizz/models/question.dart';
import 'package:quizz/models/option.dart';
import 'package:quizz/models/user_progress.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quizz.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<void> _createDB(Database db, int version) async {
    // Aircraft table
    await db.execute('''
      CREATE TABLE aircraft (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_asset TEXT
      )
    ''');

    // Crew type table
    await db.execute('''
      CREATE TABLE crew_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        aircraft_id INTEGER NOT NULL,
        FOREIGN KEY (aircraft_id) REFERENCES aircraft (id)
      )
    ''');

    // Topics table
    await db.execute('''
      CREATE TABLE topic (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        crew_id INTEGER NOT NULL,
        aircraft_id INTEGER NOT NULL,
        FOREIGN KEY (crew_id) REFERENCES crew_type (id),
        FOREIGN KEY (aircraft_id) REFERENCES aircraft (id)
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE question (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        explanation TEXT,
        FOREIGN KEY (topic_id) REFERENCES topic (id)
      )
    ''');

    // Options table
    await db.execute('''
      CREATE TABLE option (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES question (id)
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        attempt_date TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES question (id)
      )
    ''');
  }

  Future<void> importQuestionsData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/aviation_questions.json');
      final jsonData = json.decode(jsonString);

      final db = await database;

      // Import aircraft data
      for (var aircraftData in jsonData['aircraft']) {
        final aircraftId = await db.insert('aircraft', {
          'name': aircraftData['name'],
          'image_asset': aircraftData['image_asset'] ?? 'assets/images/aircraft_default.png',
        });

        // Import crew types
        for (var crewData in aircraftData['crew_types']) {
          final crewId = await db.insert('crew_type', {
            'name': crewData['name'],
            'aircraft_id': aircraftId,
          });

          // Import topics
          for (var topicData in crewData['topics']) {
            final topicId = await db.insert('topic', {
              'name': topicData['name'],
              'crew_id': crewId,
              'aircraft_id': aircraftId,
            });

            // Import questions
            for (var questionData in topicData['questions']) {
              final questionId = await db.insert('question', {
                'topic_id': topicId,
                'question_text': questionData['question'],
                'explanation': questionData['explanation'],
              });

              // Import options
              for (var optionData in questionData['options']) {
                await db.insert('option', {
                  'question_id': questionId,
                  'text': optionData['text'],
                  'is_correct': optionData['isCorrect'] ? 1 : 0,
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error importing data: $e');
    }
  }

  // Get all aircraft
  Future<List<Aircraft>> getAircraft() async {
    final db = await database;
    final result = await db.query('aircraft');
    return result.map((map) => Aircraft.fromMap(map)).toList();
  }

  // Get crew types by aircraft ID
  Future<List<CrewType>> getCrewTypes(int aircraftId) async {
    final db = await database;
    final result = await db.query(
      'crew_type',
      where: 'aircraft_id = ?',
      whereArgs: [aircraftId],
    );
    return result.map((map) => CrewType.fromMap(map)).toList();
  }

  // Get topics by crew ID and aircraft ID
  Future<List<Topic>> getTopics(int crewId, int aircraftId) async {
    final db = await database;
    final result = await db.query(
      'topic',
      where: 'crew_id = ? AND aircraft_id = ?',
      whereArgs: [crewId, aircraftId],
    );
    return result.map((map) => Topic.fromMap(map)).toList();
  }

  // Get questions by topic ID
  Future<List<Question>> getQuestions(int topicId) async {
    final db = await database;
    final questionsResult = await db.query(
      'question',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );

    List<Question> questions = [];

    for (var questionMap in questionsResult) {
      final optionsResult = await db.query(
        'option',
        where: 'question_id = ?',
        whereArgs: [questionMap['id']],
      );

      final options = optionsResult.map((map) => Option.fromMap(map)).toList();
      questions.add(Question.fromMap(questionMap, options));
    }

    return questions;
  }

  // Save user progress
  Future<int> saveProgress(UserProgress progress) async {
    final db = await database;
    return await db.insert('user_progress', progress.toMap());
  }

  // Get user progress for a topic
  Future<List<UserProgress>> getProgressForTopic(int topicId) async {
    final db = await database;
    final questions = await getQuestions(topicId);
    final questionIds = questions.map((q) => q.id).toList();

    final progressResult = await db.query(
      'user_progress',
      where: 'question_id IN (${List.filled(questionIds.length, '?').join(',')})',
      whereArgs: questionIds,
      orderBy: 'attempt_date DESC',
    );

    return progressResult.map((map) => UserProgress.fromMap(map)).toList();
  }

  // Get incorrect answers for review
  Future<Map<Question, UserProgress>> getIncorrectAnswers(int topicId) async {
    final db = await database;
    final questions = await getQuestions(topicId);

    Map<Question, UserProgress> incorrectAnswers = {};

    for (var question in questions) {
      final progressResult = await db.query(
        'user_progress',
        where: 'question_id = ? AND is_correct = 0',
        whereArgs: [question.id],
        orderBy: 'attempt_date DESC',
        limit: 1,
      );

      if (progressResult.isNotEmpty) {
        incorrectAnswers[question] = UserProgress.fromMap(progressResult.first);
      }
    }

    return incorrectAnswers;
  }

  // Get topic completion percentage
  Future<double> getTopicCompletion(int topicId) async {
    final db = await database;
    final questions = await getQuestions(topicId);

    if (questions.isEmpty) return 0.0;

    int correctAnswersCount = 0;

    for (var question in questions) {
      final result = await db.query(
        'user_progress',
        where: 'question_id = ? AND is_correct = 1',
        whereArgs: [question.id],
      );

      if (result.isNotEmpty) {
        correctAnswersCount++;
      }
    }

    return correctAnswersCount / questions.length;
  }
}
