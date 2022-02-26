import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Task{
  int? id;
  late String title;
  String? content;
  DateTime date_add;
  DateTime? plan_date_exec;
  DateTime? real_exec_date;
  String? status;
  DateTime? failure_date;
  String? failure_cause;

  Task({this.id,required this.title,this.content,required this.date_add,
    this.plan_date_exec,this.real_exec_date,this.status,
    this.failure_cause,this.failure_date});
  factory Task.fromMap(Map<String,dynamic> json) =>
      new Task(
          id: json['id'],
          title: json['title'],
        content: json['content'],
        date_add: json['date_add'],
        plan_date_exec: json['plan_date_exec'],
        real_exec_date: json['real_exec_date'],
        failure_cause: json['failure_cause'],
        failure_date: json['failure_date'],
      );

  Map <String,dynamic>toMap(){
    return {
      'id':id,
      'title':title,
      'content':content,
      'date_add':date_add,
      'plan_date_exec':plan_date_exec,
      'real_exec_date':real_exec_date,
      'failure_cause':failure_cause,
      'failure_date':failure_date,
    };
  }
}

class LongTask{
  int? id;
  late String title;
  String? content;
  int? steps;
  DateTime date_add;
  DateTime? plan_date_exec;
  DateTime? real_exec_date;
  String? status;
  DateTime? failure_date;
  String? failure_cause;

  LongTask({this.id,required this.title,this.content,this.steps,required this.date_add,
    this.plan_date_exec,this.real_exec_date,this.status,
    this.failure_cause,this.failure_date});
  factory LongTask.fromMap(Map<String,dynamic> json) =>
      new LongTask(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        steps: json['steps'],
        date_add: json['date_add'],
        plan_date_exec: json['plan_date_exec'],
        real_exec_date: json['real_exec_date'],
        failure_cause: json['failure_cause'],
        failure_date: json['failure_date'],
      );

  Map <String,dynamic>toMap(){
    return {
      'id':id,
      'title':title,
      'content':content,
      'steps':steps,
      'date_add':date_add,
      'plan_date_exec':plan_date_exec,
      'real_exec_date':real_exec_date,
      'failure_cause':failure_cause,
      'failure_date':failure_date,
    };
  }

}

class Reminder{
  int? id;
  String title;
  DateTime date_exec;
  Reminder({this.id,required this.title,required this.date_exec});
}

class DatabaseHelper{
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future <Database> get database async => _database ??= await _initDatabase();

  Future <Database> _initDatabase() async{
    Directory documents_directory = await getApplicationDocumentsDirectory();
    String path = join(documents_directory.path,'tasks.db');
    return await openDatabase(path,version: 1,onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      content TEXT,
      date_add INTEGER,
      plan_date_exec INTEGER,
      real_exec_date INTEGER,
      failure_cause TEXT,
      failure_date INTEGER
      )
        ''');
    await db.execute('''
      CREATE TABLE long_tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      content TEXT,
      steps INTEGER,
      date_add INTEGER,
      plan_date_exec INTEGER,
      real_exec_date INTEGER,
      failure_cause TEXT,
      failure_date INTEGER
      )
        ''');
    await db.execute('''
      CREATE TABLE reminders(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      date_exec INTEGER,
      real_exec_date INTEGER,
      )
        ''');
    /*await db.execute('''
      CREATE TABLE tasks(
      id INTEGER PRIMARY KEY,
      name TEXT)
        ''');
    await db.execute('''
      CREATE TABLE tasks(
      id INTEGER PRIMARY KEY,
      name TEXT)
        ''');*/
  }

  Future<List<dynamic>> get_tasks(String _key) async {
    Database db = await instance.database;
    if (_key == 'task') {
      var tasks = await db.query('tasks',orderBy: 'id');
      List<Task> taskList = tasks.isNotEmpty ?
      tasks.map((c) => Task.fromMap(c)).toList() :
      [];
      return taskList;
    }
    if (_key == 'longtask') {
      var tasks = await db.query('long_tasks',orderBy: 'id');
      List<LongTask> taskList = tasks.isNotEmpty ?
      tasks.map((c) => LongTask.fromMap(c)).toList() :
      [];
      return taskList;
    }
    else {
      return [];
    }
  }

  Future<int> add_task(Task task ) async{
    Database  db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> add_longtask(LongTask task ) async{
    Database  db = await instance.database;
    return await db.insert('long_tasks', task.toMap());
  }

  Future<int> remove(int id) async{
    Database db = await instance.database;
    return await db.delete('tasks',where: 'id = ?', whereArgs: [id]);
  }
}