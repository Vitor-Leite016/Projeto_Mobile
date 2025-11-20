import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pobrecom.dart';

class TodoLocalService {
  static final TodoLocalService _instance = TodoLocalService._internal();
  Database? _db;

  factory TodoLocalService() => _instance;

  TodoLocalService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY,
            title TEXT,
            completed INTEGER,
            userId INTEGER
          )
        ''');
      },
    );
  }

  Future<void> createTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      {
        'id': todo.id,
        'title': todo.title,
        'completed': todo.completed ? 1 : 0,
        'userId': todo.userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return maps.map((map) => Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      completed: (map['completed'] as int) == 1,
      userId: map['userId'] as int,
    )).toList();
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      {
        'title': todo.title,
        'completed': todo.completed ? 1 : 0,
        'userId': todo.userId,
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTodos() async {
    final db = await database;
    await db.delete('todos');
  }
}
