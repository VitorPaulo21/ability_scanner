import 'dart:convert';

import 'package:barcode_scanner/components/delete_all_button.dart';
import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<String> layoutOrganization = [
    "Codico",
    "Quant",
    "Data",
  ];
  // String item1 = "7891035";
  // String item2 = "9.0";
  // String item3 = DateFormat("dd/MM/yyyy").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
 
    layoutOrganization = Provider.of<SettingsProvider>(context, listen: false)
        .layoutOrganization;
    return Drawer(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Ability Scanner"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      bottomSheet:
          Container(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(
                  child: DeleteAllButton(
                     ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: exportButton(context, settingsProvider)),
              ],
            ),
          )),
      body: Container(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).viewInsets.top -
            MediaQuery.of(context).viewPadding.top -
            50,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                ...bilityTopIcon(context),
                askQuantitySwitchListile(settingsProvider),
                const SizedBox(
                  height: 10,
                ),
                askValiditySwitchListile(settingsProvider),
                const SizedBox(
                  height: 15,
                ),
                exportExtensionSitchField(settingsProvider),
                const SizedBox(
                  height: 15,
                ),
                exportFileSeparatorSwitchField(settingsProvider),
                draggerLayoutConfig(settingsProvider)
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Column exportFileSeparatorSwitchField(SettingsProvider settingsProvider) {
    return Column(children: [
      Text("Separador do arquivo de saída"),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                ";",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Container(
                  width: 120,
                  child: Slider(
                    value: settingsProvider.fileSeparator ? 1 : 0,
                    onChanged: (value) {
                      settingsProvider.fileSeparator =
                          value == 0 ? false : true;
                    },
                    divisions: 1,
                    label: settingsProvider.fileSeparator ? "," : ";",
                  )),
              const Text(
                ",",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      
    ]);
  }

  Row draggerLayoutConfig(SettingsProvider settingsProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DragTarget<String>(onAccept: (data) {
          data = data == "Código" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[0];
          layoutOrganization[0] = data;

          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[0] == "Codico"
              ? "Código"
              : layoutOrganization[0]);
        }),
        const SizedBox(width: 5),
        Text(settingsProvider.fileSeparator ? "," : ";"),
        const SizedBox(width: 5),
        DragTarget<String>(onAccept: (data) {
          data = data == "Código" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[1];
          layoutOrganization[1] = data;

          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[1] == "Codico"
              ? "Código"
              : layoutOrganization[1]);
        }),
        const SizedBox(width: 5),
        Text(settingsProvider.fileSeparator ? "," : ";"),
        const SizedBox(width: 5),
        DragTarget<String>(onAccept: (data) {
          data = data == "Código" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[2];
          layoutOrganization[2] = data;
          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[2] == "Codico"
              ? "Código"
              : layoutOrganization[2]);
        }),
      ],
    );
  }

  Column exportExtensionSitchField(SettingsProvider settingsProvider) {
    return Column(children: [
      Text("Extenção de Exportação"),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(".txt"),
              Container(
                width: 120,
                child: Consumer<SettingsProvider>(builder: (ctx, seetings, _) {
                  return Slider(
                    value: settingsProvider.fileFormat ? 1 : 0,
                    onChanged: (value) {
                      settingsProvider.fileFormat = value == 0 ? false : true;
                    },
                    divisions: 1,
                    label: settingsProvider.fileFormat ? ".csv" : ".txt",
                  );
                }),
              ),
              const Text(
                ".csv\n(Excel)",
                textAlign: TextAlign.center,
              )
            ],
          ),
        ],
      ),
    ]);
  }

  ListTile askValiditySwitchListile(SettingsProvider settingsProvider) {
    return ListTile(
      leading: CupertinoSwitch(
          value: settingsProvider.validityAsk,
          onChanged: (value) {
            settingsProvider.validityAsk = value;
          }),
      title: const Text("Perguntar Validade"),
      subtitle:
          const Text("Pergunta a validade do produto após escanear o código"),
    );
  }

  ListTile askQuantitySwitchListile(SettingsProvider settingsProvider) {
    return ListTile(
      leading: CupertinoSwitch(
          value: settingsProvider.quantityAsk,
          onChanged: (value) {
            settingsProvider.quantityAsk = value;
          }),
      title: const Text("Perguntar Quantidade"),
      subtitle:
          const Text("Pergunta a quantidade do produto após escanear o código"),
    );
  }

  List<Widget> bilityTopIcon(BuildContext context) {
    return [
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        radius: 58,
        child: Image.asset(
          "lib/assets/abilityIcon.png",
          fit: BoxFit.cover,
          height: 80,
          width: 80,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      const FittedBox(
        child: Text(
          "Ability Scanner",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      const SizedBox(
        height: 25 / 2,
      ),
      const Divider(
        thickness: 1,
      ),
      const SizedBox(
        height: 25 / 2,
      )
    ];
  }

  Widget exportButton(BuildContext context, SettingsProvider settingsProvider) {
    return ElevatedButton(
        onPressed: () {
          Provider.of<ProdutoProvider>(context, listen: false).export(
              settingsProvider.fileFormat ? ".csv" : ".txt",
              settingsProvider.fileSeparator ? "," : ";",
              settingsProvider.layoutOrganization);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Exportar"),
            SizedBox(
              width: 5,
            ),
            Icon(Icons.exit_to_app),
          ],
        ));
  }

  Widget Drager(String data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(2),
        ),
      ),
      child: Draggable(
        maxSimultaneousDrags: 1,
        data: data,
        child: Text(data),
        feedback: Container(
          width: 30,
          height: 20,
          color: Colors.grey,
          child: FittedBox(
              child: Icon(
            Icons.abc,
            color: Colors.white,
          )),
        ),
        childWhenDragging: Container(
          alignment: Alignment.center,
          color: Colors.grey[800],
          width: 30,
          child: const Text(
            "...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
