import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/article.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _tableName = 'articles';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hacker_news.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Supprimer la base de données existante pour éviter les conflits
    try {
      await deleteDatabase(path);
      debugPrint('DatabaseHelper: Ancienne base de données supprimée');
    } catch (e) {
      debugPrint('DatabaseHelper: Erreur lors de la suppression: $e');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        url TEXT,
        score INTEGER NOT NULL,
        descendants INTEGER NOT NULL,
        time INTEGER NOT NULL,
        commentIds TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE favoris (
        id INTEGER PRIMARY KEY
      )
    ''');
    debugPrint('DatabaseHelper: Nouvelle base de données créée avec succès');
  }

  Future<void> insertArticle(Article article) async {
    final db = await database;
    await db.insert(
        _tableName,
        {
          'id': article.id,
          'title': article.title,
          'author': article.author,
          'url': article.url,
          'score': article.score,
          'descendants': article.descendants,
          'time': article.time,
          'commentIds': article.commentIds.join(','),
          'isFavorite': 0, // Par défaut non favori
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertArticles(List<Article> articles) async {
    final db = await database;
    final batch = db.batch();

    for (final article in articles) {
      batch.insert(
          _tableName,
          {
            'id': article.id,
            'title': article.title,
            'author': article.author,
            'url': article.url,
            'score': article.score,
            'descendants': article.descendants,
            'time': article.time,
            'commentIds': article.commentIds.join(','),
            'isFavorite': 0, // Par défaut non favori
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<List<Article>> getArticles({
    int limit = 20,
    int offset = 0,
    String sortBy = 'score',
  }) async {
    final db = await database;
    String orderBy;

    switch (sortBy) {
      case 'score':
        orderBy = 'score DESC';
        break;
      case 'time':
        orderBy = 'time DESC';
        break;
      case 'comments':
        orderBy = 'descendants DESC';
        break;
      default:
        orderBy = 'score DESC';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final commentIdsString = map['commentIds'] as String?;
      final commentIds =
          commentIdsString?.split(',').map((id) => int.parse(id)).toList() ??
              [];

      return Article(
        id: map['id'],
        title: map['title'],
        author: map['author'],
        url: map['url'],
        score: map['score'],
        descendants: map['descendants'],
        time: map['time'],
        commentIds: commentIds,
      );
    });
  }

  Future<List<Article>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'time DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final commentIdsString = map['commentIds'] as String?;
      final commentIds =
          commentIdsString?.split(',').map((id) => int.parse(id)).toList() ??
              [];

      return Article(
        id: map['id'],
        title: map['title'],
        author: map['author'],
        url: map['url'],
        score: map['score'],
        descendants: map['descendants'],
        time: map['time'],
        commentIds: commentIds,
      );
    });
  }

  Future<void> toggleFavorite(int articleId, bool isFavorite) async {
    final db = await instance.database;
    await db.update(
      _tableName,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> cleanNonFavorites() async {
    final db = await instance.database;
    final deleted = await db.delete(
      _tableName,
      where: 'isFavorite = ?',
      whereArgs: [0],
    );
    debugPrint('DatabaseHelper: $deleted articles non-favoris supprimés');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<void> addFavori(int id) async {
    final db = await instance.database;
    await db.insert(
        'favoris',
        {
          'id': id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
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
}
