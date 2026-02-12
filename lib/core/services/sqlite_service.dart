// import 'dart:io';
// import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Conditional import usually handled by main setup

class SQLiteService {
  // Cache connections to avoid re-opening frequently
  final Map<String, Database> _openDatabases = {};

  Future<Database> openDb(String path, {bool readOnly = true}) async {
    if (_openDatabases.containsKey(path)) {
      final db = _openDatabases[path]!;
      if (db.isOpen) {
        return db;
      } else {
        _openDatabases.remove(path);
      }
    }

    try {
      // Ensure directory exists? Usually generic openDatabase handles it if create, but here likely readOnly.
      final db = await openDatabase(
        path,
        readOnly: readOnly,
        // singleInstance: false // If we need multiple? Usually true is fine.
      );
      _openDatabases[path] = db;
      return db;
    } catch (e) {
      debugPrint("Error opening database at $path: $e");
      rethrow;
    }
  }

  Future<void> closeDb(String path) async {
    if (_openDatabases.containsKey(path)) {
      final db = _openDatabases[path]!;
      await db.close();
      _openDatabases.remove(path);
    }
  }

  Future<void> closeAll() async {
    for (final db in _openDatabases.values) {
      await db.close();
    }
    _openDatabases.clear();
  }
}
