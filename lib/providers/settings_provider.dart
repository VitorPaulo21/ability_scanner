import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _quantityAsk = true;
  bool _validityAsk = false;
  bool _continuousScanner = false;

  bool get quantityAsk => _quantityAsk;
  bool get validityAsk => _validityAsk;
  bool get continuousScanner => _continuousScanner;
  SettingsProvider() {
    sync();
  }
  set quantityAsk(bool value) {
    _quantityAsk = value;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("quantityAsk", _quantityAsk));
  }

  set validityAsk(bool value) {
    _validityAsk = value;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("validityAsk", _validityAsk));
  }

  set continuousScanner(bool value) {
    _continuousScanner = value;
    notifyListeners();
    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool("continuousScanner", _continuousScanner));
  }

  void sync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _quantityAsk = prefs.getBool("quantityAsk") ?? true;
    _validityAsk = prefs.getBool("validityAsk") ?? false;
    _continuousScanner = prefs.getBool("continuousScanner") ?? false;
    notifyListeners();
  }
}
