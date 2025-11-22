import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pobrecom.dart';

class DespesaLocalService {
  static final DespesaLocalService _instance = DespesaLocalService._internal();
  Database? _db;

  factory DespesaLocalService() => _instance;

  DespesaLocalService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'despesas.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE despesas (
            id INTEGER PRIMARY KEY,
            valor REAL,
            pago INTEGER,
            descricao TEXT,
            data TEXT,
            userId INTEGER
          )
        ''');
      },
    );
  }

  Future<void> createDespesa(Despesa despesa) async {
    final db = await database;
    await db.insert(
      'despesas',
      {
        'id': despesa.id,
        'valor': despesa.valor,
        'pago': despesa.pago ? 1 : 0,
        'descricao': despesa.descricao,
        'data': despesa.data.toIso8601String(),
        'userId': despesa.userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Despesa>> getDespesas() async {
    final db = await database;
    final maps = await db.query('despesas');
    return maps.map((map) => Despesa(
      id: map['id'] as int,
      valor: map['valor'] as double,
      pago: (map['pago'] as int) == 1,
      descricao: map['descricao'] as String,
      data: DateTime.parse(map['data'] as String),
      userId: map['userId'] as int,
    )).toList();
  }

  Future<Despesa> updateDespesa({required int id, required bool pago}) async {
    final db = await database;

    // Atualizar o registro no banco de dados
    await db.update(
      'despesas',
      {
        'pago': pago ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Buscar o registro atualizado
    final List<Map<String, dynamic>> result = await db.query(
      'despesas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Despesa(
        id: result[0]['id'] as int,
        valor: result[0]['valor'] as double,
        pago: (result[0]['pago'] as int) == 1,
        descricao: result[0]['descricao'] as String,
        data: DateTime.parse(result[0]['data'] as String),
        userId: result[0]['userId'] as int,
      );
    } else {
      throw Exception('Despesa não encontrada após a atualização.');
    }
  }

  Future<void> deleteDespesa(int id) async {
    final db = await database;
    await db.delete(
      'despesas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDespesas() async {
    final db = await database;
    await db.delete('despesas');
  }
}

class DespesaBuilder {
  int? id;
  double? valor;
  bool pago = false;
  String? descricao;
  DateTime? data;
  int? userId;

  DespesaBuilder setId(int id) {
    this.id = id;
    return this;
  }

  DespesaBuilder setValor(double valor) {
    this.valor = valor;
    return this;
  }

  DespesaBuilder setPago(bool pago) {
    this.pago = pago;
    return this;
  }

  DespesaBuilder setDescricao(String descricao) {
    this.descricao = descricao;
    return this;
  }

  DespesaBuilder setData(DateTime data) {
    this.data = data;
    return this;
  }

  DespesaBuilder setUserId(int userId) {
    this.userId = userId;
    return this;
  }

  Despesa build() {
    return Despesa(
      id: id ?? DateTime.now().millisecondsSinceEpoch,
      valor: valor ?? 0.0,
      pago: pago,
      descricao: descricao ?? '',
      data: data ?? DateTime.now(),
      userId: userId ?? 0,
    );
  }
}
