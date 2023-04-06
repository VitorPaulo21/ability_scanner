import 'package:barcode_scanner/components/delete_all_button.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/utils/app_routes.dart';
import 'package:barcode_scanner/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      bottomSheet: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(
                  child: DeleteAllButton(),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: exportButton(context, settingsProvider)),
              ],
            ),
          )),
      body: SizedBox(
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      leading: const Icon(FontAwesomeIcons.barcode),
                      title: const Text("Códigos Importados"),
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.CODES);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                  ],
                ),
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
      const Text("Separador do arquivo de saída"),
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
              SizedBox(
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
          return Drager(
            layoutOrganization[0] == "Codico"
                ? "Código"
                : layoutOrganization[0],
            right: true,
          );
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
          return Drager(
            layoutOrganization[1] == "Codico"
                ? "Código"
                : layoutOrganization[1],
            left: true,
            right: true,
          );
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
          return Drager(
            layoutOrganization[2] == "Codico"
                ? "Código"
                : layoutOrganization[2],
            left: true,
          );
        }),
      ],
    );
  }

  Column exportExtensionSitchField(SettingsProvider settingsProvider) {
    return Column(children: [
      const Text("Extenção de Exportação"),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(".txt"),
              SizedBox(
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
          activeColor: Theme.of(context).colorScheme.primary,
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
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) {
            settingsProvider.quantityAsk = value;
          }),
      title: const Text("Perguntar Quantidade"),
      subtitle:
          const Text("Pergunta a quantidade do produto após escanear o código"),
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
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    "lib/assets/abilityIcon.png",
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text("Ability Informática"),
                      const SizedBox(
                        height: 8,
                      ),
                      const LinkToSite(),
                      const SizedBox(
                        height: 8,
                      ),
                      const LinkToWhatsApp()
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

  Widget Drager(String data, {bool left = false, bool right = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
      ),
      child: Draggable(
        maxSimultaneousDrags: 1,
        data: data,
        feedback: Container(
          width: 30,
          height: 20,
          color: Colors.grey,
          child: const FittedBox(
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
        child: Text((left ? "< " : "") + data + (right ? " >" : "")),
      ),
    );
  }
}
