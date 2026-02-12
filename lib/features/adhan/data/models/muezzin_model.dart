import 'package:equatable/equatable.dart';

class Muezzin extends Equatable {
  final String id;
  final String name; // Arabic display name
  final String fileName;

  const Muezzin({required this.id, required this.name, required this.fileName});

  @override
  List<Object> get props => [id, name, fileName];

  // Static list based on user provided files
  static const List<Muezzin> allMuezzins = [
    Muezzin(
      id: 'abdul_basit',
      name: 'عبد الباسط عبد الصمد',
      fileName: 'Athan Abed Albase6.mp3',
    ),
    Muezzin(
      id: 'ahmad_nuyne3',
      name: 'أحمد نعينع',
      fileName: 'Athan Ahmad Nuyne3.mp3',
    ),
    Muezzin(
      id: 'malek_chebae',
      name: 'مالك شيبة (فجر)',
      fileName: 'Athan Al-fajer - Malek chebae.mp3',
    ),
    Muezzin(
      id: 'hamad_deghreri',
      name: 'حمد دغريري',
      fileName: 'Athan Hamad Deghreri.mp3',
    ),
    Muezzin(
      id: 'hamdan_almalki',
      name: 'حمدان المالكي',
      fileName: 'Athan Hamdan Almalki.mp3',
    ),
    Muezzin(
      id: 'ibrahim_al_arkani',
      name: 'إبراهيم الأركاني',
      fileName: 'Athan Ibrahim Al-Arkani.mp3',
    ),
    Muezzin(
      id: 'majed_al_hamathani',
      name: 'ماجد الحمثاني',
      fileName: 'Athan Majed Al-hamathani.mp3',
    ),
    Muezzin(
      id: 'makkah',
      name: 'أذان مكة المكرمة',
      fileName: 'Athan Makkah.mp3',
    ),
    Muezzin(
      id: 'mansoor_az_zahrani',
      name: 'منصور الزهراني',
      fileName: 'Athan Mansoor Az-Zahrani.mp3',
    ),
    Muezzin(
      id: 'mishary_alafasi',
      name: 'مشاري العفاسي',
      fileName: 'Athan Mishary Alafasi.mp3',
    ),
    Muezzin(
      id: 'mohammad_almenshawy',
      name: 'محمد صديق المنشاوي',
      fileName: 'Athan Mohammad Almenshawy.mp3',
    ),
    Muezzin(
      id: 'mohammad_ref3at',
      name: 'محمد رفعت',
      fileName: 'Athan Mohammad Ref3at.mp3',
    ),
    Muezzin(
      id: 'nasser_alqatami',
      name: 'ناصر القطامي',
      fileName: 'Athan Nasser Alqatami.mp3',
    ),
    Muezzin(
      id: 'suhaib_khatba',
      name: 'صهيب خطبة',
      fileName: 'Athan Suhaib Khatba.mp3',
    ),
  ];
}
