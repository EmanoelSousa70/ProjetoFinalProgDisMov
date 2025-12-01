import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('revise_car.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Tabela de contatos
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        workingHours TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ========== OPERAÇÕES DE USUÁRIO ==========
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // ========== OPERAÇÕES DE CONTATO ==========
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final maps = await db.query('contacts', orderBy: 'name');
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'name LIKE ? OR phone LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name',
    );
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'name',
    );
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  Future<Contact?> getContactById(int id) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'contacts',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

