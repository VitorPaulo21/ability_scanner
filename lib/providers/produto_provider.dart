import 'package:barcode_scanner/models/produto.dart';
import 'package:barcode_scanner/providers/settings_provider.dart';
import 'package:barcode_scanner/utils/write_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ProdutoProvider with ChangeNotifier {
  List<Produto> _produtos = [];

  List<Produto> get produtos => [..._produtos];
  SettingsProvider? settingsProvider;
  ProdutoProvider(this.settingsProvider) {
    syncToHive();
  }
  void syncToHive() async {
    _produtos = await Hive.box<Produto>("produtos").values.toList();
    notifyListeners();
  }
  
  void addProduto(Produto produto) {
    if (produto.validade != null) {
      if (_produtos.any((prod) => prod.validade == null
          ? false
          : DateFormat("dd/MM/yyyy").format(prod.validade!) ==
                  DateFormat("dd/MM/yyyy").format(produto.validade!) &&
              prod.barcode == produto.barcode)) {
        acrescentBarcodeValidity(produto.barcode,
            quantity: produto.quantidade, validity: produto.validade!);
        
      } else {
        
        _produtos.insert(0, produto);
        notifyListeners();
        Hive.box<Produto>("produtos").add(produto);
      }
    } else if (_produtos.any(
        (prod) => prod.barcode == produto.barcode && prod.validade == null)) {
      acrescentBarcodeNoValidity(produto.barcode, quantity: produto.quantidade);
    } else {
      _produtos.insert(0, produto);
      Hive.box<Produto>("produtos").add(produto);
      notifyListeners();
    }
  }

  void acrescentProduto(Produto produto, {double quantity = 1}) {
    if (_produtos.contains(produto)) {
      _produtos.firstWhere((element) => element == produto).quantidade +=
          quantity;
      produto.save();
      notifyListeners();
    }
  }

  void acrescentBarcode(String barcode, {double quantity = 1}) {
    try {
      (_produtos
          .firstWhere((produto) => produto.barcode == barcode)
            ..quantidade += quantity)
          .save();
      
      notifyListeners();
    } catch (e) {
      if (e.runtimeType == StateError) {
        return;
      }
    }
  }

  void acrescentBarcodeNoValidity(String barcode, {double quantity = 1}) {
    try {
      (_produtos
          .firstWhere((produto) =>
              produto.barcode == barcode && produto.validade == null)
            ..quantidade += quantity)
          .save();

      notifyListeners();
    } catch (e) {
      if (e.runtimeType == StateError) {
        return;
      }
    }
  }

  void acrescentBarcodeValidity(String barcode,
      {required DateTime validity, double quantity = 1}) {
    try {
      (_produtos
          .firstWhere((produto) => produto.validade == null
              ? false
              : produto.barcode == barcode &&
                  DateFormat("dd/MM/yyyy").format(produto.validade!) ==
                      DateFormat("dd/MM/yyyy").format(validity))
            ..quantidade += quantity)
          .save();

      notifyListeners();
    } catch (e) {
      if (e.runtimeType == StateError) {
        return;
      }
    }
  }

  void reduceProduto(Produto produto, {double quantity = 1}) {
    if (_produtos.contains(produto)) {
      _produtos.firstWhere((element) => element == produto).quantidade -=
          quantity;
      produto.save();
      if (_produtos.firstWhere((element) => element == produto).quantidade <=
          0) {
        removeProduto(produto);
        return;
      }
      notifyListeners();
    }
  }

  double reduceBarcode(String barcode, {double quantity = 1}) {
    Produto? actualProduct;
    try {
      actualProduct =
          _produtos.firstWhere((produto) => produto.barcode == barcode);
      actualProduct.quantidade -= quantity;
      actualProduct.save();
      if (actualProduct.quantidade <= 0) {
        removeBarcode(barcode);
        return actualProduct.quantidade;
      }
      notifyListeners();
    } catch (e) {
      if (e.runtimeType == StateError) {
        return actualProduct?.quantidade ?? 0;
      }
    }
    return actualProduct?.quantidade ?? 0;
  }

  void setQuantityByProduto(Produto produto, double quantity) {
    if (_produtos.contains(produto)) {
      _produtos.firstWhere((element) => element == produto).quantidade =
          quantity;
      produto.save();
      if (_produtos.firstWhere((element) => element == produto).quantidade <=
          0) {
        removeProduto(produto);
        return;
      }
      notifyListeners();
    }
  }

  void setQuantityByBarcode(String barcode, double quantity) {
    if (_produtos.any((element) => element.barcode == barcode)) {
      (_produtos.firstWhere((element) => element.barcode == barcode)
            ..quantidade = quantity)
          .save();
      if (_produtos
              .firstWhere((element) => element.barcode == barcode)
              .quantidade <=
          0) {
        removeBarcode(barcode);
        return;
      }
      notifyListeners();
    }
  }

  bool removeBarcode(String barcode) {
    try {
      Produto produto =
          _produtos.firstWhere((produto) => produto.barcode == barcode);
      produto.delete();
      notifyListeners();
      return _produtos.remove(produto);
    } catch (e) {
      if (e.runtimeType == StateError) {
        return false;
      }
    }
    return false;
  }

  bool removeProduto(Produto prod) {
    bool removed = _produtos.remove(prod);
    prod.delete();
    if (removed) {
      notifyListeners();
    }
    return removed;
  }

  void export(String extension, String separator, List<String> layout) {
    WriteData.writeData(
      _produtos.map<String>((product) {
        String code =
            extension == ".txt" ? product.barcode : "=\"${product.barcode}\"";

        String data = product.validade == null
            ? ""
            : DateFormat("dd/MM/yyyy").format(product.validade!).toString();

        String item1 = "";
        String item2 = "";
        String item3 = "";
        item1 = layout[0] == "Codico"
            ? code
            : layout[0] == "Quant"
                ? product.quantidade.toString()
                : data;
        item2 = layout[1] == "Codico"
            ? code
            : layout[1] == "Quant"
                ? product.quantidade.toString()
                : data;
        item3 = layout[2] == "Codico"
            ? code
            : layout[2] == "Quant"
                ? product.quantidade.toString()
                : data;
        return "$item1$separator$item2${item3.isEmpty ? settingsProvider!.validityAsk ? separator : "" : separator + item3}";
      }).toList(),
      extension,
    );
  }

  void clean() {
    _produtos.clear();
    Hive.box<Produto>("produtos").clear();
    notifyListeners();
  }
}
