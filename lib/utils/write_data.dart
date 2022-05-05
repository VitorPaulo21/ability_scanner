import 'dart:io';

import 'package:path_provider/path_provider.dart';

class WriteData {
  Future<String> get InternalDirectory async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get getFile async {
    String path = await InternalDirectory;

    return File("$path/data.txt");
  }

  void writeData(String data) async {}
}
