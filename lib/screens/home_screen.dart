import 'dart:async';

import 'package:barcode_scanner/components/app_drawer.dart';
import 'package:barcode_scanner/components/link_to_site.dart';
import 'package:barcode_scanner/components/link_to_whatsapp.dart';
import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String code = "";
  Barcode? result;
  QRViewController? controller;
  GlobalKey key = GlobalKey();
  bool isAwayting = false;
  bool continuousScanner = false;
  DateTime? validade;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isScanning = false;
  String query = "";
  bool scan = false;
  Color scanColor = Colors.orange;
  @override
  Widget build(BuildContext context) {
    double avaliableScreenSpace = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).viewInsets.bottom;
    ProdutoProvider produtosProvider = Provider.of<ProdutoProvider>(context);

    continuousScanner =
        Provider.of<SettingsProvider>(context, listen: false).continuousScanner;
    return WillPopScope(
      onWillPop: () async {
        // FocusManager.instance.primaryFocus?.unfocus();
        bool closeReturn = false;
        await showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Alerta"),
                content: const Text("Deseja sair da aplica????o?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    child: const Text("Sim"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                    child: const Text("N??o"),
                  ),
                ],
              );
            }).then((value) => closeReturn = value ?? false);
        return Future.value(closeReturn);
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      // padding: EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          // shape: BoxShape.circle,
                          // gradient: LinearGradient(
                          //   colors: [
                          //     Color.fromRGBO(110, 193, 228, 1),
                          //     Color.fromRGBO(97, 206, 112, 1)
                          //   ],
                          // ),
                          ),
                      child: Image.asset("lib/assets/abilityIcon.png",
                          height: 25)),
                  SizedBox(
                    width: 8,
                  ),
                  const Text("Ability Scanner"),
                ],
              ),
              centerTitle: true,
              
              actions: [
                if (produtosProvider.produtos.isNotEmpty)
                  IconButton(
                      onPressed: () {
                        Functions.exportDialog(context, produtosProvider);
                      },
                      icon: const Icon(Icons.exit_to_app))
              ],
            ),
            bottomSheet: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [LinkToSite(), LinkToWhatsApp()],
                ),
              ),
            ),
            drawer: AppDrawer(),
            body: Column(
              children: [
                if (!isScanning) BarcodeScanner(context),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      if (isScanning)
                        Expanded(
                          child: CupertinoTextField(
                            onChanged: (txt) {
                              setState(() {
                                query = txt;
                              });
                            },
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.search),
                            ),
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isScanning = false;
                                  query = "";
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.clear),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(90),
                              ),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      if (!isScanning)
                        CupertinoSwitch(
                            value: continuousScanner,
                            onChanged: (value) {
                              Provider.of<SettingsProvider>(context,
                                      listen: false)
                                  .continuousScanner = value;
                              setState(() {
                                continuousScanner = value;
                                scan = false;
                              });
                            }),
                      const SizedBox(
                        width: 10,
                      ),
                      if (!isScanning)
                        const FittedBox(child: Text("Escanear Continuo")),
                      if (!isScanning)
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  isScanning = true;
                                  scan = false;
                                });
                              },
                              icon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      if (!continuousScanner || isScanning)
                        ElevatedButton(
                            onPressed: scan
                                ? null
                                : () {
                                    if (isScanning) {
                                      scanDialog(context, query);
                                    } else {
                                      showDialog<bool>(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog(
                                              title: const Text("Escanear"),
                                              content: const Text(
                                                  "Deseja escanear um C??digo"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop(true);
                                                  },
                                                  child: Text("Sim"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop(false);
                                                  },
                                                  child: Text("N??o"),
                                                )
                                              ],
                                            );
                                          }).then((value) {
                                        setState(() {
                                          scan = value ?? false;
                                        });
                                        Future.delayed(Duration(
                                                seconds: Provider.of<
                                                            SettingsProvider>(
                                                        context,
                                                        listen: false)
                                                    .waitScanTime))
                                            .then((value) {
                                          setState(() {
                                            scan = false;
                                          });
                                        });
                                      });
                                    }
                                  },
                            child: Text(scan
                                ? "Aguardando"
                                : isScanning
                                    ? "Inserrir"
                                    : "Escanear")),
                    ],
                  ),
                ),
                Expanded(child: listOfScannedCodes(context)),
                const SizedBox(
                  height: 40,
                )
              ],
            )),
      ),
    );
  }

  

  Padding listOfScannedCodes(BuildContext context) {
    List<Produto> produtos = isScanning
        ? Provider.of<ProdutoProvider>(context, listen: false)
            .produtos
            .where((element) => element.barcode.contains(query))
            .toList()
        : Provider.of<ProdutoProvider>(context, listen: false).produtos;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListView.builder(
          itemCount: produtos.length,
          itemBuilder: (ctx, index) {
            TextEditingController quantityController = TextEditingController();
            bool isInteger(num value) => (value % 1) == 0;
            if (isInteger(produtos[index].quantidade)) {
              quantityController.text =
                  produtos[index].quantidade.toInt().toString();
            } else {
              quantityController.text =
                  produtos[index].quantidade.toStringAsFixed(2);
            }
            return barcodeListItem(
                produtos, index, quantityController, context);
          }),
    );
  }

  ListTile barcodeListItem(List<Produto> produtos, int index,
      TextEditingController quantityController, BuildContext context) {
    return ListTile(
      title: Text(produtos[index].barcode),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 130,
            child: CupertinoTextField(
              textInputAction: TextInputAction.done,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              controller: quantityController,
              prefix: GestureDetector(
                onTap: () {
                  Provider.of<ProdutoProvider>(context, listen: false)
                      .acrescentProduto(produtos[index]);
                },
                child: Icon(Icons.add),
              ),
              suffix: GestureDetector(
                onTap: () {
                  if (produtos[index].quantidade == 1) {
                    showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Alerta"),
                            content: const Text(
                                "A quantidade atual a ser removida ira zerar a quantidade do material no sistema deseja continuar?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                },
                                child: const Text("Sim"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(false);
                                },
                                child: const Text("N??o"),
                              ),
                            ],
                          );
                        }).then((value) {
                      if (value ?? false) {
                        Provider.of<ProdutoProvider>(context, listen: false)
                            .reduceProduto(produtos[index]);
                      }
                    });
                  } else {
                    Provider.of<ProdutoProvider>(context, listen: false)
                        .reduceProduto(produtos[index]);
                  }
                },
                child: Icon(Icons.remove),
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                double? value = double.tryParse(text);
                if (value != null) {
                  Provider.of<ProdutoProvider>(context, listen: false)
                      .setQuantityByProduto(produtos[index], value);
                } else {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text("Alerta"),
                          content: const Text("Valor Inv??lido"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: const Text("Ok"),
                            ),
                          ],
                        );
                      });
                }
              },
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text("Alerta"),
                      content: const Text(
                          "Tem certeza que deseja excluir este item?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(true);
                            },
                            child: const Text("Ok")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(false);
                            },
                            child: const Text("Cancelar")),
                      ],
                    );
                  }).then((value) {
                if (value ?? false) {
                  Provider.of<ProdutoProvider>(context, listen: false)
                      .removeProduto(produtos[index]);
                }
              });
            },
            icon: const Icon(Icons.delete_forever),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Container BarcodeScanner(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? 200
          : 110,
      child: QRView(
        key: key,
        onQRViewCreated: (controller) {
          this.controller = controller;

          controller.scannedDataStream.listen(
            (scanData) {
              // controller.pauseCamera();

              // showDialog(
              //     context: context,
              //     builder: (ctx) {
              //       TextEditingController addController = TextEditingController();
              //       addController.text = "1";
              //       GlobalKey<FormState> formkey = GlobalKey<FormState>();
              //       return AlertDialog(
              //         title: Text(scanData.code.toString()),
              //         content: Form(
              //           key: formkey,
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text("Adicionar Produto:"),
              //               const SizedBox(
              //                 height: 10,
              //               ),
              //               TextFormField(
              //                 controller: addController,
              //                 keyboardType: const TextInputType.numberWithOptions(
              //                     decimal: true),
              //                 decoration: InputDecoration(
              //                   border: OutlineInputBorder(
              //                       borderRadius: const BorderRadius.all(
              //                           Radius.circular(10)),
              //                       borderSide: BorderSide(
              //                           color:
              //                               Theme.of(context).colorScheme.primary,
              //                           width: 2)),
              //                   label: Text("Qauntidade:"),
              //                 ),
              //                 validator: (txt) {
              //                   if ((double.tryParse(txt ?? "d")) == null) {
              //                     return "Valor Inv??lido";
              //                   }
              //                 },
              //               ),
              //             ],
              //           ),
              //         ),
              //         actions: [
              //           TextButton(
              //             onPressed: () {
              //               bool isvalid =
              //                   formkey.currentState?.validate() ?? false;
              //               if (isvalid) {
              //                 produtosProvider.addProduto(Produto(
              //                     scanData.code.toString(),
              //                     quantidade: double.parse(addController.text)));
              //               }
              //               Navigator.of(context).pop();
              //             },
              //             child: const Text("Ok"),
              //           ),
              //           TextButton(
              //             onPressed: () {
              //               Navigator.of(context).pop();
              //             },
              //             child: const Text("Cancelar"),
              //           ),
              //         ],
              //       );
              //     }).then((value) => controller.resumeCamera());
            },
          ).onData((scanData) {
            if (continuousScanner || scan) {
              print(scan);
              setState(() {
                scanColor = Colors.green;
              });
              controller.pauseCamera();

              scanDialog(
                context,
                scanData.code.toString(),
              ).then((value) {
                setState(() {
                  scanColor = Colors.orange;
                });
                controller.resumeCamera();
              });
              setState(() {
                scan = false;
              });
            }
          });
        },
        cameraFacing: CameraFacing.back,
        overlay: QrScannerOverlayShape(
            borderRadius: 10,
            borderWidth: 5,
            borderColor: scanColor,
            cutOutHeight: 85,
            cutOutWidth: MediaQuery.of(context).size.width * 0.8),
        //teste 2
      ),
    );
  }

  Future<dynamic> scanDialog(
    BuildContext context,
    String scanData,
  ) async {
    playScanSound();
    if (!Provider.of<SettingsProvider>(context, listen: false).quantityAsk &&
        !Provider.of<SettingsProvider>(context, listen: false).validityAsk) {
      Provider.of<ProdutoProvider>(context, listen: false)
          .addProduto(Produto(scanData));
      return await Future<void>.delayed(const Duration(milliseconds: 1000));
    }
    return showDialog(
        context: context,
        builder: (ctx) {
          TextEditingController addController = TextEditingController();
          addController.text = "1";
          GlobalKey<FormState> formkey = GlobalKey<FormState>();

          return AlertDialog(
            title: Text(scanData),
            content: StatefulBuilder(builder: (context, state) {
              return Form(
                key: formkey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Adicionar Produto:"),
                      const SizedBox(
                        height: 10,
                      ),
                      if (Provider.of<SettingsProvider>(context, listen: false)
                          .quantityAsk)
                        TextFormField(
                          controller: addController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2)),
                            label: const Text("Qauntidade:"),
                          ),
                          validator: (txt) {
                            if ((double.tryParse(txt ?? "d")) == null) {
                              return "Valor Inv??lido";
                            }
                          },
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (Provider.of<SettingsProvider>(context, listen: false)
                          .validityAsk)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text("validade: "),
                            const SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      context: context,
                                      builder: (ctx) {
                                        DateTime? currentDate = DateTime.now();

                                        return ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: Scaffold(
                                            body: CupertinoDatePicker(
                                              initialDateTime: DateTime.now(),
                                              onDateTimeChanged: (date) {
                                                currentDate = date;
                                              },
                                              dateOrder:
                                                  DatePickerDateOrder.dmy,
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              use24hFormat: true,
                                            ),
                                            bottomSheet: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      state(() {
                                                        validade = currentDate;
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Selecionar")),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                style: OutlinedButton.styleFrom(
                                    primary:
                                        Theme.of(context).colorScheme.primary,
                                    side: const BorderSide(color: Colors.grey),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
                                child: Text(validade == null
                                    ? "00/00/0000"
                                    : DateFormat("dd/MM/yyyy")
                                        .format(validade!))),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  bool isvalid = formkey.currentState?.validate() ?? false;
                  if (isvalid) {
                    Provider.of<ProdutoProvider>(context, listen: false)
                        .addProduto(Produto(scanData,
                            quantidade: double.parse(addController.text),
                            validade: validade));
                  }
                  Navigator.of(context, rootNavigator: true).pop();
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
        }).then((value) {
      validade = null;
      code = "";
    });
  }

  void playScanSound() async {
    AssetsAudioPlayer.playAndForget(
      Audio("lib/assets/beep.mp3"),
    );
  }

  Widget botomScanBar(double avaliableScreenSpace, BuildContext context,
      ProdutoProvider produtosProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      height: avaliableScreenSpace * 0.085,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green),
              onPressed: () async {
                FlutterBarcodeScanner.scanBarcode(
                  "#FFBF00",
                  "Cancel",
                  true,
                  ScanMode.BARCODE,
                ).then((barcode) {
                  if (barcode == "-1") {
                    return;
                  } else {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          TextEditingController addController =
                              TextEditingController();
                          addController.text = "1";
                          GlobalKey<FormState> formkey = GlobalKey<FormState>();
                          return AlertDialog(
                            title: Text(barcode),
                            content: Form(
                              key: formkey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Adicionar Produto:"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: addController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2)),
                                      label: Text("Qauntidade:"),
                                    ),
                                    validator: (txt) {
                                      if ((double.tryParse(txt ?? "d")) ==
                                          null) {
                                        return "Valor Inv??lido";
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  bool isvalid =
                                      formkey.currentState?.validate() ?? false;
                                  if (isvalid) {
                                    produtosProvider.addProduto(Produto(barcode,
                                        quantidade:
                                            double.parse(addController.text)));
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ok"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancelar"),
                              ),
                            ],
                          );
                        });
                  }
                });
              },
              child: Text("Adicionar"),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                String barcode = await FlutterBarcodeScanner.scanBarcode(
                  "#FFBF00",
                  "Cancelar",
                  true,
                  ScanMode.BARCODE,
                );
                showDialog<Map<String, Object>>(
                    context: context,
                    builder: (ctx) {
                      bool isExistentProduct = produtosProvider.produtos
                          .any((element) => element.barcode == barcode);
                      TextEditingController reduceController =
                          TextEditingController();
                      reduceController.text = "1";
                      GlobalKey<FormState> formkey = GlobalKey<FormState>();
                      return AlertDialog(
                        title: Text(barcode),
                        content: Form(
                          key: formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isExistentProduct)
                                const Text("Produto n??o adicionado ao sistema"),
                              if (isExistentProduct)
                                const Text("Remover Produto:"),
                              const SizedBox(
                                height: 10,
                              ),
                              if (isExistentProduct)
                                TextFormField(
                                  controller: reduceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    prefixText: "-",
                                    border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2)),
                                    label: const Text("Qauntidade:"),
                                  ),
                                  validator: (txt) {
                                    if ((double.tryParse(txt ?? "d")) == null) {
                                      return "Valor Inv??lido";
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              bool isvalid =
                                  formkey.currentState?.validate() ?? false;
                              if (isvalid && isExistentProduct) {
                                bool willRemove = produtosProvider.produtos
                                        .firstWhere((element) =>
                                            element.barcode == barcode)
                                        .quantidade ==
                                    1;

                                Navigator.of(context, rootNavigator: true).pop(
                                  {
                                    "willRemove": willRemove,
                                    "value":
                                        double.parse(reduceController.text),
                                  },
                                );
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
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
                    }).then((data) {
                  if (data != null) {
                    bool willRemove = false;
                    if (data.containsKey("willRemove")) {
                      if (data["willRemove"] as bool == true) {
                        willRemove = true;
                      }
                    }
                    if (willRemove) {
                      showDialog<bool>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Alerta"),
                              content: const Text(
                                  "A quantidade atual a ser removida ira zerar a quantidade do material no sistema deseja continuar?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(true);
                                  },
                                  child: const Text("Sim"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(false);
                                  },
                                  child: const Text("N??o"),
                                ),
                              ],
                            );
                          }).then((value) {
                        if (value ?? false) {
                          produtosProvider.reduceBarcode(barcode,
                              quantity: data["value"] as double);
                        }
                      });
                    } else {
                      produtosProvider.reduceBarcode(barcode,
                          quantity: data["value"] as double);
                    }
                  }
                });
              },
              child: const Text("Remover"),
            ),
          ),
        ],
      ),
    );
  }
}
