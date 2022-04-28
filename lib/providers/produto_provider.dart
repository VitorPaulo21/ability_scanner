import 'package:barcode_scanner/models/produto.dart';
import 'package:flutter/cupertino.dart';

class ProdutoProvider with ChangeNotifier {
  List<Produto> _produtos = [];

  List<Produto> get produtos => [..._produtos];
 
  void addProduto(Produto produto) {
    if (_produtos.any((prod) => prod.barcode == produto.barcode)) {
      _produtos
          .firstWhere((prod) => prod.barcode == produto.barcode)
          .quantidade += produto.quantidade;
      notifyListeners();
      return;
    }
    _produtos.add(produto);
    notifyListeners();
  }

  void acrescentProduto(Produto produto, {double quantity = 1}) {
    if (_produtos.contains(produto)) {
      _produtos.firstWhere((element) => element == produto).quantidade +=
          quantity;
      notifyListeners();
    }
  }

  void acrescentBarcode(String barcode, {double quantity = 1}) {
    try {
      _produtos
          .firstWhere((produto) => produto.barcode == barcode)
          .quantidade += quantity;

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
      _produtos.firstWhere((element) => element.barcode == barcode).quantidade =
          quantity;
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
    if (removed) {
      notifyListeners();
    }
    return removed;
  }
}
