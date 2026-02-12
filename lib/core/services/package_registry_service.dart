import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PackageType { voice, tafsir, recitationDb, tafsirDb }

class PackageEntry {
  final String id;
  final PackageType type;
  final String localPath;
  final bool isInstalled;
  final String? version;

  PackageEntry({
    required this.id,
    required this.type,
    required this.localPath,
    required this.isInstalled,
    this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'localPath': localPath,
      'isInstalled': isInstalled,
      'version': version,
    };
  }

  factory PackageEntry.fromJson(Map<String, dynamic> json) {
    return PackageEntry(
      id: json['id'],
      type: PackageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PackageType.voice, // Fallback
      ),
      localPath: json['localPath'],
      isInstalled: json['isInstalled'],
      version: json['version'],
    );
  }
}

final packageRegistryProvider = Provider<PackageRegistryService>((ref) {
  throw UnimplementedError('Initialize packageRegistryProvider in main.dart');
});

class PackageRegistryService {
  final SharedPreferences _prefs;
  static const String _key = 'downloaded_packages_registry';

  PackageRegistryService(this._prefs);

  List<PackageEntry> getInstalledPackages() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => PackageEntry.fromJson(e)).toList();
  }

  Future<void> registerPackage(PackageEntry entry) async {
    final packages = getInstalledPackages();
    // Remove if exists
    packages.removeWhere((p) => p.id == entry.id && p.type == entry.type);
    packages.add(entry);
    await _savePackages(packages);
  }

  Future<void> unregisterPackage(String id, PackageType type) async {
    final packages = getInstalledPackages();
    packages.removeWhere((p) => p.id == id && p.type == type);
    await _savePackages(packages);
  }

  bool isPackageInstalled(String id, PackageType type) {
    return getInstalledPackages().any(
      (p) => p.id == id && p.type == type && p.isInstalled,
    );
  }

  Future<void> _savePackages(List<PackageEntry> packages) async {
    final jsonString = json.encode(packages.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}
