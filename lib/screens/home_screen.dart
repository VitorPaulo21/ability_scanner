import 'package:barcode_scanner/components/app_drawer.dart';
import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/produto_provider.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

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
  

  @override
  Widget build(BuildContext context) {
    double avaliableScreenSpace = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).viewInsets.bottom;
    ProdutoProvider produtosProvider = Provider.of<ProdutoProvider>(context);
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    continuousScanner =
        Provider.of<SettingsProvider>(context, listen: false).continuousScanner;
    return WillPopScope(
      onWillPop: () async {

        FocusManager.instance.primaryFocus?.unfocus();
        bool closeReturn = false;
        await showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Alerta"),
                content: const Text("Deseja sair da aplicação?"),
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
                    child: const Text("Não"),
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
              title: const Text("Ability Scanner"),
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("lib/assets/abilityIcon.png"),
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      produtosProvider.export(
                          Provider.of<SettingsProvider>(context, listen: false)
                                  .fileFormat
                              ? ".csv"
                              : ".txt");
                    },
                    icon: const Icon(Icons.exit_to_app))
              ],
            ),
            drawer: AppDrawer(),
            body: Column(
              children: [
                BarcodeScanner(context, produtosProvider),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      
                          
                      CupertinoSwitch(
                          value: continuousScanner,
                            onChanged: (value) {
                            Provider.of<SettingsProvider>(context,
                                    listen: false)
                                .continuousScanner = value;
                              setState(() {
                              continuousScanner = value;
                            });
                          }),
                      
                      SizedBox(
                        width: 10,
                      ),
                      Text("Escanear Continuo"),
                      if (!continuousScanner)
                        Expanded(
                            child: Container(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              onPressed: () {
                                if (code.isEmpty || code == "") {
                                  return;
                                }
                                scanDialog(context, code, produtosProvider);
                              },
                              child: Text("Escanear")),
                        ))
                    ],
                  ),
                ),
                Expanded(child: scannedCodes(produtosProvider, context))
              ],
            )
            // bottomNavigationBar:
            //     botomScanBar(avaliableScreenSpace, context, produtosProvider),
            ),
      ),
    );
  }

  Padding scannedCodes(ProdutoProvider produtosProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListView.builder(
          itemCount: produtosProvider.produtos.length,
          itemBuilder: (ctx, index) {
            TextEditingController quantityController = TextEditingController();
            bool isInteger(num value) => (value % 1) == 0;
            if (isInteger(produtosProvider.produtos[index].quantidade)) {
              quantityController.text = produtosProvider
                  .produtos[index].quantidade
                  .toInt()
                  .toString();
            } else {
              quantityController.text = produtosProvider
                  .produtos[index].quantidade
                  .toStringAsFixed(2);
            }
            return ListTile(
              title: Text(produtosProvider.produtos[index].barcode),
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
                          produtosProvider.acrescentProduto(
                              produtosProvider.produtos[index]);
                        },
                        child: Icon(Icons.add),
                      ),
                      suffix: GestureDetector(
                        onTap: () {
                          if (produtosProvider.produtos[index].quantidade ==
                              1) {
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
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(true);
                                        },
                                        child: const Text("Sim"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(false);
                                        },
                                        child: const Text("Não"),
                                      ),
                                    ],
                                  );
                                }).then((value) {
                              if (value ?? false) {
                                produtosProvider.reduceProduto(
                                    produtosProvider.produtos[index]);
                              }
                            });
                          } else {
                            produtosProvider.reduceProduto(
                                produtosProvider.produtos[index]);
                          }
                        },
                        child: Icon(Icons.remove),
                      ),
                      textAlign: TextAlign.center,
                      onSubmitted: (text) {
                        double? value = double.tryParse(text);
                        if (value != null) {
                          produtosProvider.setQuantityByProduto(
                              produtosProvider.produtos[index], value);
                        } else {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Alerta"),
                                  content: const Text("Valor Inválido"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
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
                          produtosProvider
                              .removeProduto(produtosProvider.produtos[index]);
                        }
                      });
                    },
                    icon: Icon(Icons.delete_forever),
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Container BarcodeScanner(
      BuildContext context, ProdutoProvider produtosProvider) {
    return Container(
      alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? 200
          : 110,
      child: QRView(
        key: key,
        onQRViewCreated: (controller) {
          this.controller = controller;

          controller.scannedDataStream.listen((scanData) {
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
            //                     return "Valor Inválido";
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
          }).onData((scanData) {
            if (!continuousScanner) {
              code = scanData.code ?? "";
              return;
            }
            controller.pauseCamera();

            scanDialog(context, scanData.code.toString(), produtosProvider)
                .then((value) => controller.resumeCamera());
          });
        },
        cameraFacing: CameraFacing.back,
        overlay: QrScannerOverlayShape(
            borderRadius: 10,
            borderWidth: 5,
            borderColor: Colors.orange,
            cutOutHeight: 85,
            cutOutWidth: MediaQuery.of(context).size.width * 0.8),
      ),
    );
  }

  Future<dynamic> scanDialog(BuildContext context, String scanData,
      ProdutoProvider produtosProvider) async {
    playScanSound();
    if (!Provider.of<SettingsProvider>(context, listen: false).quantityAsk &&
        !Provider.of<SettingsProvider>(context, listen: false).validityAsk) {
      produtosProvider.addProduto(Produto(scanData));
      return await Future<void>.delayed(Duration(milliseconds: 1000));
    }
    return showDialog(
        context: context,
        builder: (ctx) {
          TextEditingController addController = TextEditingController();
          addController.text = "1";
          GlobalKey<FormState> formkey = GlobalKey<FormState>();
          GlobalKey<State> buttonKey = GlobalKey<State>();

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
                      Text("Adicionar Produto:"),
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
                            label: Text("Qauntidade:"),
                          ),
                          validator: (txt) {
                            if ((double.tryParse(txt ?? "d")) == null) {
                              return "Valor Inválido";
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
            }
            ),
            actions: [
              TextButton(
                onPressed: () {
                  bool isvalid = formkey.currentState?.validate() ?? false;
                  if (isvalid) {
                    produtosProvider.addProduto(Produto(scanData,
                        quantidade: double.parse(addController.text),
                        validade: validade));
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
        }).then((value) => validade = null);
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
                                        return "Valor Inválido";
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
                                const Text("Produto não adicionado ao sistema"),
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
                                      return "Valor Inválido";
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
                                  child: const Text("Não"),
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
              child: Text("Remover"),
            ),
          ),
        ],
      ),
    );
  }
}
