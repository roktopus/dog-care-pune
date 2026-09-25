import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';
import 'pmc/pmc_api.dart';

/// Copy a picker/camera file into durable app storage so later picks cannot wipe it.
Future<String> persistReportPhoto(
  String sourcePath, {
  String? id,
  Directory? documents,
}) async {
  final source = File(sourcePath);
  if (!await source.exists()) {
    throw StateError('Photo file is missing: $sourcePath');
  }
  final root = documents ?? await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(root.path, 'report_photos'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  var ext = p.extension(sourcePath).toLowerCase();
  if (ext.isEmpty || ext.length > 5) ext = '.jpg';
  final name = '${id ?? 'draft_${DateTime.now().millisecondsSinceEpoch}'}$ext';
  final destPath = p.join(dir.path, name);
  if (p.equals(sourcePath, destPath)) return destPath;
  await source.copy(destPath);
  return destPath;
}

abstract class ReportRepository {
  Future<List<DogReport>> load();
  Future<void> upsert(DogReport report);
}

class MemoryReports implements ReportRepository {
  final List<DogReport> items = [];

  @override
  Future<List<DogReport>> load() async => List.of(items);

  @override
  Future<void> upsert(DogReport report) async {
    items.removeWhere((item) => item.id == report.id);
    items.insert(0, report);
  }
}

class SqliteReports implements ReportRepository {
  SqliteReports(this._db);

  final Database _db;

  static Future<SqliteReports> open() async {
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'dog_help_pune.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE reports (id TEXT PRIMARY KEY, payload TEXT NOT NULL, created_at INTEGER NOT NULL)',
        );
      },
    );
    return SqliteReports(db);
  }

  @override
  Future<List<DogReport>> load() async {
    final rows = await _db.query('reports', orderBy: 'created_at DESC');
    return [
      for (final row in rows) DogReport.fromJson(jsonDecode(row['payload']! as String) as Map<String, Object?>),
    ];
  }

  @override
  Future<void> upsert(DogReport report) {
    return _db.insert(
      'reports',
      {
        'id': report.id,
        'payload': jsonEncode(report.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

abstract class SessionStore {
  Future<PmcSession?> read();
  Future<void> write(PmcSession session);
  Future<void> clear();
}

class MemorySession implements SessionStore {
  PmcSession? current;

  @override
  Future<void> clear() async => current = null;

  @override
  Future<PmcSession?> read() async => current;

  @override
  Future<void> write(PmcSession session) async => current = session;
}

class SecureSession implements SessionStore {
  SecureSession({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'pmc_session';

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<PmcSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw);
    if (json is! Map) return null;
    final token = json['token']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final mobile = json['mobile']?.toString() ?? '';
    if (token.isEmpty || userId.isEmpty || mobile.isEmpty) return null;
    return PmcSession(
      token: token,
      userId: userId,
      name: json['name']?.toString() ?? 'Citizen',
      email: json['email']?.toString() ?? '',
      mobile: mobile,
    );
  }

  @override
  Future<void> write(PmcSession session) {
    return _storage.write(
      key: _key,
      value: jsonEncode({
        'token': session.token,
        'userId': session.userId,
        'name': session.name,
        'email': session.email,
        'mobile': session.mobile,
      }),
    );
  }
}
