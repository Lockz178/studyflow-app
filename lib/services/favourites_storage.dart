import 'package:shared_preferences/shared_preferences.dart';

class FavouritesStorage {
  static const _key = 'favorite_plan_ids';

  Future<Set<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null || list.isEmpty) return {};
    return list.toSet();
  }

  Future<void> saveIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
