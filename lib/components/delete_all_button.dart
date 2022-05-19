import 'package:flutter/material.dart';

import '../providers/produto_provider.dart';

class DeleteAllButton extends StatelessWidget {
  const DeleteAllButton({
    Key? key,
    required this.produtosProvider,
  }) : super(key: key);

  final ProdutoProvider produtosProvider;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          showDialog<bool>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text("Alerta"),
                  content:
                      const Text("Deseja limpar a lista de Códigos de barras?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        },
                        child: const Text("Sim")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(false);
                        },
                        child: const Text("Não"))
                  ],
                );
              }).then((value) {
            if (value ?? false) {
              produtosProvider.clean();
            }
          });
        },
        style: OutlinedButton.styleFrom(
            primary: Colors.red, side: BorderSide(color: Colors.red, width: 2)),
        child: FittedBox(
          child: Row(
            children: const [
              Text("Excluir Estoque"),
              Icon(Icons.delete_forever_outlined),
            ],
          ),
        ));
  }
}
