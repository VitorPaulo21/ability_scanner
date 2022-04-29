import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/screens/home_screen.dart';
import 'package:barcode_scanner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProdutoProvider>(
          create: (ctx) => ProdutoProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (ctx) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Ability Scanner',
        theme: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Color.fromRGBO(23, 24, 56, 1),
                secondary: Colors.amber,
                onPrimary: Colors.white,
                onSecondary: Color.fromRGBO(23, 24, 56, 1),
              ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.HOME: (_) => HomeScreen(),
        },
      ),
    );
  }
}
