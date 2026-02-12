class QuranPageReciter {
  final String identifier;
  final String name;
  final String englishName;
  // final String assetPath;
  final String remotePath; // For online fallback

  QuranPageReciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    // required this.assetPath,
    required this.remotePath,
  });
}

final List<QuranPageReciter> reciters = [
  QuranPageReciter(
    identifier: "abdul_basit_murattal",
    name: "عبد الباسط عبد الصمد (مرتل)",
    englishName: "Abdul Basit Abdul Samad (Murattal)",
    // assetPath: "assets/reciters/ayah-recitation-abdul-basit-abdul-samad-murattal-hafs-950.db.zip",
    remotePath: "Abdul_Basit_Murattal_64kbps",
  ),
  QuranPageReciter(
    identifier: "maher_al_muaiqly",
    name: "ماهر المعيقلي",
    englishName: "Maher Al Muaiqly",
    // assetPath: "assets/reciters/ayah-recitation-maher-al-mu-aiqly-murattal-hafs-948.db.zip",
    remotePath: "Maher_AlMuaiqly_64kbps",
  ),
  QuranPageReciter(
    identifier: "mahmoud_khalil_al_husary_murattal",
    name: "محمود خليل الحصري (مرتل)",
    englishName: "Mahmoud Khalil Al-Husary (Murattal)",
    // assetPath: "assets/reciters/ayah-recitation-mahmoud-khalil-al-husary-murattal-hafs-957.db.zip",
    remotePath: "Husary_64kbps",
  ),
  QuranPageReciter(
    identifier: "mishari_rashid_al_afasy",
    name: "مشاري راشد العفاسي",
    englishName: "Mishari Rashid Al-Afasy",
    // assetPath: "assets/reciters/ayah-recitation-mishari-rashid-al-afasy-murattal-hafs-953.db.zip",
    remotePath: "Alafasy_128kbps",
  ),
  QuranPageReciter(
    identifier: "mohamed_al_tablawi",
    name: "محمد محمود الطبلاوي",
    englishName: "Mohamed Al-Tablawi",
    // assetPath: "assets/reciters/ayah-recitation-mohamed-al-tablawi-recitation-murattal-hafs-73.db.zip",
    remotePath: "Mohammad_al_Tablaway_128kbps",
  ),
  QuranPageReciter(
    identifier: "muhammad_siddiq_al_minshawi_murattal",
    name: "محمد صديق المنشاوي (مرتل)",
    englishName: "Muhammad Siddiq Al-Minshawi (Murattal)",
    // assetPath: "assets/reciters/ayah-recitation-muhammad-siddiq-al-minshawi-murattal-hafs-959.db.zip",
    remotePath: "Minshawy_Murattal_128kbps",
  ),
  QuranPageReciter(
    identifier: "saad_al_ghamdi",
    name: "سعد الغامدي",
    englishName: "Saad Al-Ghamdi",
    // assetPath: "assets/reciters/ayah-recitation-saad-al-ghamdi-murattal-hafs-954.db.zip",
    remotePath: "Ghamadi_40kbps",
  ),
  QuranPageReciter(
    identifier: "saud_al_shuraim",
    name: "سعود الشريم",
    englishName: "Saud Al-Shuraim",
    // assetPath: "assets/reciters/ayah-recitation-saud-al-shuraim-murattal-hafs-960.db.zip",
    remotePath: "Saood_ash-Shuraym_64kbps",
  ),
  QuranPageReciter(
    identifier: "yasser_al_dosari",
    name: "ياسر الدوسري",
    englishName: "Yasser Al-Dosari",
    // assetPath: "assets/reciters/ayah-recitation-yasser-al-dosari-murattal-hafs-961.db.zip",
    remotePath: "Yasser_Ad-Dussary_128kbps",
  ),
];
