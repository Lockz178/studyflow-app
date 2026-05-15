import 'package:flutter/foundation.dart';

class PremiumController extends ChangeNotifier {
  bool _isPremium;

  PremiumController({bool isPremium = false}) : _isPremium = isPremium;

  bool get isPremium => _isPremium;

  void setPremium(bool value) {
    if (_isPremium == value) return;
    _isPremium = value;
    notifyListeners();
  }

  void toggle() => setPremium(!isPremium);
}

