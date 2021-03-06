import 'dart:convert';

import 'package:barcode_scanner/components/delete_all_button.dart';
import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'link_to_site.dart';
import 'link_to_whatsapp.dart';


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
        title: const Text("Ability Scanner"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.menu_open,
              size: 25,
            )),
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
                abilityTopIcon(context),
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
      Text("Separador do arquivo de sa??da"),
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
          data = data == "C??digo" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[0];
          layoutOrganization[0] = data;

          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[0] == "Codico"
              ? "C??digo"
              : layoutOrganization[0]);
        }),
        const SizedBox(width: 5),
        Text(settingsProvider.fileSeparator ? "," : ";"),
        const SizedBox(width: 5),
        DragTarget<String>(onAccept: (data) {
          data = data == "C??digo" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[1];
          layoutOrganization[1] = data;

          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[1] == "Codico"
              ? "C??digo"
              : layoutOrganization[1]);
        }),
        const SizedBox(width: 5),
        Text(settingsProvider.fileSeparator ? "," : ";"),
        const SizedBox(width: 5),
        DragTarget<String>(onAccept: (data) {
          data = data == "C??digo" ? "Codico" : data;
          layoutOrganization[layoutOrganization.indexOf(data)] =
              layoutOrganization[2];
          layoutOrganization[2] = data;
          settingsProvider.layoutOrganization = layoutOrganization;
        }, builder: (ctx, candidate, rejected) {
          return Drager(layoutOrganization[2] == "Codico"
              ? "C??digo"
              : layoutOrganization[2]);
        }),
      ],
    );
  }

  Column exportExtensionSitchField(SettingsProvider settingsProvider) {
    return Column(children: [
      Text("Exten????o de Exporta????o"),
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
          const Text("Pergunta a validade do produto ap??s escanear o c??digo"),
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
          const Text("Pergunta a quantidade do produto ap??s escanear o c??digo"),
    );
  }

  Widget abilityTopIcon(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse("https://www.abilityonline.com.br/links"),
                      mode: LaunchMode.externalApplication);
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 29,
                  child: Image.asset(
                    "lib/assets/abilityIcon.png",
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Desenvolvido Por",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text("Ability Inform??tica"),
                      const SizedBox(
                        height: 8,
                      ),
                      LinkToSite(),
                      const SizedBox(
                        height: 8,
                      ),
                      LinkToWhatsApp()
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
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
        ],
      ),
    );
  }

  Widget exportButton(BuildContext context, SettingsProvider settingsProvider) {
    return ElevatedButton(
        onPressed: () {
          Functions.exportDialog(
              context, Provider.of<ProdutoProvider>(context, listen: false));
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




