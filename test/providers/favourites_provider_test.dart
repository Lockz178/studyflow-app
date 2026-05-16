import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow_app/providers/favourites_provider.dart';

void main() {
  group('FavouritesProvider', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('toggle persists ids', () async {
      final provider = FavouritesProvider();
      await provider.load();

      await provider.toggle('plan-a');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_plan_ids'), ['plan-a']);

      await provider.toggle('plan-a');
      expect(prefs.getStringList('favorite_plan_ids'), isEmpty);
    });

    test('pruneMissingPlans strips orphaned ids', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_plan_ids': ['gone', 'keep'],
      });

      final provider = FavouritesProvider();
      await provider.load();

      await provider.pruneMissingPlans({'keep'});

      expect(provider.ids, {'keep'});
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_plan_ids'), ['keep']);
    });
  });
}
