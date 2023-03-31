import 'package:barcode_scanner/models/codigo.dart';
import 'package:barcode_scanner/providers/code_list_provider.dart';
import 'package:flutter/material.dart';
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
        title: const Text("Códigos Importados"),
      ),
      body: ListView.builder(
        itemCount: codigos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(codigos[index].barCode),
          );
        },
      ),
    );
  }
}
