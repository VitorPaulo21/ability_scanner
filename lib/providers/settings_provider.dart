import 'package:flutter/cupertino.dart';

class SettingsProvider with ChangeNotifier {
  bool _quantityAsk = true;
  bool _validityAsk = false;

  bool get quantityAsk => _quantityAsk;
  bool get validityAsk => _validityAsk;

  set quantityAsk(bool value) {
    _quantityAsk = value;
    notifyListeners();
  }

  set validityAsk(bool value) {
    _validityAsk = value;
    notifyListeners();
  }
}
