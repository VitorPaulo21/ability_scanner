import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/produto_provider.dart';
import '../providers/settings_provider.dart';

class Functions {
  static void exportDialog(
      BuildContext context, ProdutoProvider produtosProvider) {
    showDialog<String>(
        context: context,
        builder: (ctx) {
          GlobalKey<FormState> formKey = GlobalKey<FormState>();
          TextEditingController textData = TextEditingController();
          textData.text = "data";
          return AlertDialog(
            title: Text("Escolha o nome do Arquivo"),
            content: Form(
              key: formKey,
              child: TextFormField(
                validator: (txt) {
                  RegExp validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                  if (txt == null) {
                    return "Nome Vazio";
                  }
                  if (txt.isEmpty) {
                    return "Nome Vazio";
                  } else if (!validCharacters.hasMatch(txt)) {
                    return "Somente Letras e Numeros";
                  }
                },
                controller: textData,
                decoration: InputDecoration(
                  label: const Text("Nome do Arquivo"),
                  suffixText:
                      Provider.of<SettingsProvider>(context, listen: false)
                              .fileFormat
                          ? ".csv"
                          : ".txt",
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  bool isValid = formKey.currentState?.validate() ?? false;
                  if (isValid) {
                    Navigator.of(context, rootNavigator: true)
                        .pop(textData.text);
                  }
                },
                child: const Text("Ok"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text("Cancelar"),
              ),
            ],
          );
        }).then(
      (fileName) {
        if (fileName?.isEmpty ?? true) {
          return;
        }
        fileName ??= "data";
        produtosProvider.export(
            Provider.of<SettingsProvider>(context, listen: false).fileFormat
                ? ".csv"
                : ".txt",
            Provider.of<SettingsProvider>(context, listen: false).fileSeparator
                ? ","
                : ";",
            Provider.of<SettingsProvider>(context, listen: false)
                .layoutOrganization,
            fileName);
      },
    );
  }
}
