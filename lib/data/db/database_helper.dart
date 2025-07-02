import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/article.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hacker_news.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        time INTEGER,
        url TEXT,
        score INTEGER,
        descendants INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE favoris (
        id INTEGER PRIMARY KEY
      )
    ''');
  }

  Future<void> insertArticle(Article article) async {
    final db = await instance.database;
    await db.insert(
      'articles',
      article.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Article>> getArticles() async {
    final db = await instance.database;
    final maps = await db.query('articles');
    return maps.map((json) => Article.fromJson(json)).toList();
  }

  Future<void> deleteArticle(int id) async {
    final db = await instance.database;
    await db.delete('articles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addFavori(int id) async {
    final db = await instance.database;
    await db.insert('favoris', {
      'id': id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavori(int id) async {
    final db = await instance.database;
    await db.delete('favoris', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<int>> getFavoris() async {
    final db = await instance.database;
    final maps = await db.query('favoris');
    return maps.map((e) => e['id'] as int).toList();
  }

  Future<void> cleanObsoleteArticles(
    Future<bool> Function(int id) isAvailable,
  ) async {
    final db = await instance.database;
    final favIds = await getFavoris();
    final maps = await db.query('articles');
    for (final map in maps) {
      final id = map['id'] as int;
      if (!favIds.contains(id)) {
        final available = await isAvailable(id);
        if (!available) {
          await deleteArticle(id);
        }
      }
    }
  }
}
