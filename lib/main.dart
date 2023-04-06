import 'package:barcode_scanner/models/codigo.dart';
import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/code_list_provider.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/screens/codigos_screen.dart';
import 'package:barcode_scanner/screens/home_screen.dart';
import 'package:barcode_scanner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProdutoAdapter());
  Hive.registerAdapter(CodigoAdapter());
  await Hive.openBox<Produto>("produtos");
  await Hive.openBox<Codigo>("codigos");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final AZUL = const Color.fromRGBO(87, 186, 250, 1);
  final VERDE = const Color.fromRGBO(97, 214, 186, 1);
  final AMARELO = const Color.fromRGBO(247, 199, 71, 1);
  final PRETO = const Color.fromRGBO(3, 3, 3, 1);
  final CINZA_1 = const Color.fromRGBO(99, 99, 99, 1);
  final CINZA_2 = const Color.fromRGBO(204, 204, 204, 1);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (ctx) => SettingsProvider(),
        ),
        ChangeNotifierProvider<CodeListProvider>(
          create: (ctx) => CodeListProvider(),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, ProdutoProvider>(
          create: (ctx) => ProdutoProvider(null),
          update: (ctx, settings, produto) => ProdutoProvider(settings),
        ),
      ],
      child: MaterialApp(
        supportedLocales: const [Locale("pt", "BR")],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        title: 'Ability Scanner',
        theme: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AZUL,
              secondary: VERDE,
              tertiary: AMARELO,
              onPrimary: PRETO,
              onSecondary: CINZA_1,
              onTertiary: PRETO),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          AppRoutes.HOME: (_) => const HomeScreen(),
          AppRoutes.CODES: (_) => const CodigosScreen(),
        },
      ),
    );
  }
}
