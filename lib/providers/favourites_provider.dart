import 'package:flutter/foundation.dart';

import '../services/favourites_storage.dart';

class FavouritesProvider extends ChangeNotifier {
  FavouritesProvider({FavouritesStorage? storage})
    : _storage = storage ?? FavouritesStorage();

  final FavouritesStorage _storage;
  Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);

  Future<void> load() async {
    _ids = await _storage.loadIds();
    notifyListeners();
  }

  bool isFavorite(String planId) => _ids.contains(planId);

  Future<void> toggle(String planId) async {
    if (_ids.contains(planId)) {
      _ids.remove(planId);
    } else {
      _ids.add(planId);
    }
    notifyListeners();
    await _storage.saveIds(_ids);
  }

  Future<void> remove(String planId) async {
    if (!_ids.remove(planId)) return;
    notifyListeners();
    await _storage.saveIds(_ids);
  }

  /// Drops favourite IDs that no longer match any plan (e.g. after delete).
  Future<void> pruneMissingPlans(Set<String> existingPlanIds) async {
    final next = _ids.where(existingPlanIds.contains).toSet();
    if (next.length == _ids.length) return;
    _ids = next;
    notifyListeners();
    await _storage.saveIds(_ids);
  }
}
