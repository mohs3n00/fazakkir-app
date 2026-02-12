import 'package:fazakkir/core/services/sqlite_service.dart';

class TafsirDatabaseService {
  final SQLiteService _sqliteService;

  TafsirDatabaseService(this._sqliteService);

  Future<String?> getTafsirText(String dbPath, int surah, int ayah) async {
    try {
      final db = await _sqliteService.openDb(dbPath);
      // Table: tafsir
      // Columns: ayah_key (1:1), text
      final ayahKey = "$surah:$ayah";

      final List<Map<String, dynamic>> maps = await db.query(
        'tafsir',
        columns: ['text'],
        where: 'ayah_key = ?',
        whereArgs: [ayahKey],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return maps.first['text'] as String?;
      }
      return null;
    } catch (e) {
      // Error querying tafsir database
      return null;
    }
  }
}
