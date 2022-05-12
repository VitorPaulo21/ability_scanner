import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _quantityAsk = true;
  bool _validityAsk = false;
  bool _continuousScanner = false;
  bool _fileFormat = true;
  bool _fileSeparator = false;
  List<String> _layoutOrganization = [
    "Codico",
    "Quant",
    "Data",
  ];

  bool get quantityAsk => _quantityAsk;
  bool get validityAsk => _validityAsk;
  bool get fileFormat => _fileFormat;
  bool get fileSeparator => _fileSeparator;
  bool get continuousScanner => _continuousScanner;
  List<String> get layoutOrganization => _layoutOrganization;
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

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool("continuousScanner", _continuousScanner));
  }

  set fileFormat(bool value) {
    _fileFormat = value;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("fileFormat", _fileFormat));
  }

  set fileSeparator(bool value) {
    _fileSeparator = value;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool("fileSeparator", _fileSeparator));
  }

  set layoutOrganization(List<String> value) {
    _layoutOrganization = value;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) =>
        prefs.setStringList("layoutOrganization", _layoutOrganization));
  }

  void sync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _quantityAsk = prefs.getBool("quantityAsk") ?? true;
    _validityAsk = prefs.getBool("validityAsk") ?? false;
    _continuousScanner = prefs.getBool("continuousScanner") ?? false;
    _fileFormat = prefs.getBool("fileFormat") ?? false;
    _fileSeparator = prefs.getBool("fileSeparator") ?? false;
    _layoutOrganization = prefs.getStringList("layoutOrganization") ??
        [
          "Codico",
          "Quant",
          "Data",
        ];
        
    notifyListeners();
  }
}
