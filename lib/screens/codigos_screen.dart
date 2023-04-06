import 'package:barcode_scanner/components/dialogs.dart';
import 'package:barcode_scanner/models/codigo.dart';
import 'package:barcode_scanner/providers/code_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CodigosScreen extends StatelessWidget {
  const CodigosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CodeListProvider codeListProvider =
        Provider.of<CodeListProvider>(context, listen: true);
    List<Codigo> codigos = codeListProvider.codigos;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ),
        title: const Text("Códigos Importados"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                Dialogs.dialogWithOptions(context, "Alerta",
                        "Deseja mesmo limpar a lista de códigos importados atual?")
                    .then((value) {
                  if (value ?? false) {
                    codeListProvider.clearAll();
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary, width: 2)),
              child: const Text("Limpar Lista"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: codigos.length,
              itemBuilder: (context, index) {
                return ListTile(
                    key: UniqueKey(),
                    title: Text(codigos[index].barCode),
                    leading: const Icon(FontAwesomeIcons.barcode),
                    trailing: IconButton(
                        splashRadius: 20,
                        onPressed: () {
                          Dialogs.dialogWithOptions(context, "Alerta",
                                  "Deseja mesmo remover este item da lista de códigos importados atual?")
                              .then((value) {
                            if (value ?? false) {
                              codeListProvider.clearOne(codigos[index]);
                            }
                          });
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red[800],
                        )));
              },
            ),
          ),
        ],
      ),
    );
  }
}
