class Produto {
  String barcode;
  double quantidade;
  DateTime? validade;
  Produto(this.barcode, {this.quantidade = 1, this.validade});
}
