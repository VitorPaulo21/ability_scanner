import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
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
              ),
              ListTile(
                leading: CupertinoSwitch(
                    value: settingsProvider.quantityAsk,
                    onChanged: (value) {
                      settingsProvider.quantityAsk = value;
                    }),
                title: const Text("Perguntar Quantidade"),
                subtitle: const Text(
                    "Pergunta a quantidade do produto após escanear o códico"),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                leading: CupertinoSwitch(
                    value: settingsProvider.validityAsk,
                    onChanged: (value) {
                      settingsProvider.validityAsk = value;
                    }),
                title: const Text("Perguntar Validade"),
                subtitle: const Text(
                    "Pergunta a validade do produto após escanear o códico"),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
