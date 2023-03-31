// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

part 'codigo.g.dart';

@HiveType(typeId: 1)
class Codigo {
  @HiveField(0)
  final String barCode;

  Codigo(this.barCode);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'barcode': barCode,
    };
  }

  factory Codigo.fromMap(Map<String, dynamic> map) {
    return Codigo(
      map['barcode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Codigo.fromJson(String source) =>
      Codigo.fromMap(json.decode(source) as Map<String, dynamic>);
}
