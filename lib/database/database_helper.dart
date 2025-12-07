import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/contact.dart';
import '../models/manutencao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('revise_car.db');
    return _database!;
  }

  Future<Database> _initDB(String caminhoArquivo) async {
    final caminhoBanco = await getDatabasesPath();
    final caminho = join(caminhoBanco, caminhoArquivo);

    return await openDatabase(
      caminho,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database banco, int versao) async {
    // Tabela de usuários
    await banco.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Tabela de contatos
    await banco.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        workingHours TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await banco.execute('''
      CREATE TABLE manutencoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        local TEXT NOT NULL,
        descricao TEXT NOT NULL,
        valor REAL NOT NULL
      )
    ''');
  }

  // ========== OPERAÇÕES DE USUÁRIO ==========
  Future<int> inserirUsuario(User usuario) async {
    final banco = await database;
    return await banco.insert('users', usuario.toMap());
  }

  Future<User?> obterUsuarioPorEmail(String email) async {
    final banco = await database;
    final resultados = await banco.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (resultados.isNotEmpty) {
      return User.fromMap(resultados.first);
    }
    return null;
  }

  Future<User?> fazerLogin(String email, String senha) async {
    final banco = await database;
    final resultados = await banco.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, senha],
    );

    if (resultados.isNotEmpty) {
      return User.fromMap(resultados.first);
    }
    return null;
  }

  // ========== OPERAÇÕES DE CONTATO ==========
  Future<int> inserirContato(Contact contato) async {
    final banco = await database;
    return await banco.insert('contacts', contato.toMap());
  }

  Future<List<Contact>> obterTodosContatos() async {
    final banco = await database;
    final resultados = await banco.query('contacts', orderBy: 'name');
    return resultados.map((resultado) => Contact.fromMap(resultado)).toList();
  }

  Future<List<Contact>> buscarContatos(String busca) async {
    final banco = await database;
    final resultados = await banco.query(
      'contacts',
      where: 'name LIKE ? OR phone LIKE ? OR address LIKE ?',
      whereArgs: ['%$busca%', '%$busca%', '%$busca%'],
      orderBy: 'name',
    );
    return resultados.map((resultado) => Contact.fromMap(resultado)).toList();
  }

  Future<List<Contact>> obterContatosFavoritos() async {
    final banco = await database;
    final resultados = await banco.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'name',
    );
    return resultados.map((resultado) => Contact.fromMap(resultado)).toList();
  }

  Future<Contact?> obterContatoPorId(int id) async {
    final banco = await database;
    final resultados = await banco.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultados.isNotEmpty) {
      return Contact.fromMap(resultados.first);
    }
    return null;
  }

  Future<int> atualizarContato(Contact contato) async {
    final banco = await database;
    return await banco.update(
      'contacts',
      contato.toMap(),
      where: 'id = ?',
      whereArgs: [contato.id],
    );
  }

  Future<int> excluirContato(int id) async {
    final banco = await database;
    return await banco.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> alternarFavorito(int id, bool ehFavorito) async {
    final banco = await database;
    return await banco.update(
      'contacts',
      {'isFavorite': ehFavorito ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== OPERAÇÕES DE MANUTENÇÃO ==========
  Future<int> inserirManutencao(Manutencao manutencao) async {
    final banco = await database;
    return await banco.insert('manutencoes', manutencao.toMap());
  }
  
  Future<List<Manutencao>> obterTodasManutencoes() async {
    final banco = await database;
    final resultados = await banco.query('manutencoes', orderBy: 'data DESC');
    return resultados.map((resultado) => Manutencao.fromMap(resultado)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

