import 'dart:convert';

import 'package:barcode_scanner/components/dialogs.dart';
import 'package:barcode_scanner/models/codigo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart';

class CodeListProvider with ChangeNotifier {
  List<Codigo> _codigos = [];

  CodeListProvider() {
    syncToHive();
  }

  void syncToHive() async {
    _codigos = Hive.box<Codigo>("codigos").values.toList();
    notifyListeners();
  }

  List<Codigo> get codigos => [..._codigos];

  Future<bool> downloadCodes(
      {required String url, required BuildContext context}) async {
    bool isTimeOuted = false;
    Response response = await get(Uri.parse(url)).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        isTimeOuted = true;
        return Response("", 500);
      },
    );

    if (isTimeOuted) {
      Dialogs.errorDialog(context, "Erro",
          "Não foi possivel conectar-se ao servidor.\nVerifique sua internet ou contate o suporte");
      return false;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      List<dynamic> body = jsonDecode(response.body);
      List<Map<String, dynamic>> items = body.cast<Map<String, dynamic>>();

      if (items.isNotEmpty) {
        Box<Codigo> box = Hive.box<Codigo>("codigos");
        await box.clear();
        _codigos = items.map<Codigo>((map) => Codigo.fromMap(map)).toList();
        box.addAll(_codigos);
        notifyListeners();
        return true;
      } else {
        Dialogs.errorDialog(context, "Alerta",
            "O corpo da requisição está vasio!\nNenhum dado foi importado");
        return false;
      }
    } else {
      Dialogs.errorDialog(context, "Erro",
          "O servidor apresentou um erro ao processar a requisição");
      return false;
    }
  }

  void clearAll() {
    Hive.box<Codigo>("codigos").clear();
    _codigos.clear();
    notifyListeners();
  }

  void clearOne(Codigo codigo) async {
    _codigos.remove(codigo);
    if (codigo.isInBox) {
      await codigo.delete();
    }
    notifyListeners();
  }

  bool isExistentCode(String code) {
    return _codigos.any((codigo) => codigo.barCode == code);
  }

  bool isNotExistentCode(String code) {
    print(code);
    return !isExistentCode(code);
  }
}
