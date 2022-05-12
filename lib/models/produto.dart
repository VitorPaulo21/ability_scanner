import 'package:hive/hive.dart';
part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto {
  @HiveField(0)
  String barcode;
  @HiveField(1)
  double quantidade;
  @HiveField(2)
  DateTime? validade;
  Produto(this.barcode, {this.quantidade = 1, this.validade});
}
