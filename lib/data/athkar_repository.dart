import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/athkar_model.dart';
import '../features/athkar/data/azkar_data.dart';

final athkarRepositoryProvider = Provider((ref) => AthkarRepository());

final athkarListProvider = FutureProvider<List<DhikrCategory>>((ref) async {
  final repo = ref.read(athkarRepositoryProvider);
  return repo.loadAthkar();
});

class AthkarRepository {
  Future<List<DhikrCategory>> loadAthkar() async {
    // Simulate async if needed, or just return implementation
    // Using explicit cast or map to ensure type safety
    return azkarData.map((json) => DhikrCategory.fromJson(json)).toList();
  }
}
