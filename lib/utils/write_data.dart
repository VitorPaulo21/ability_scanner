import 'dart:io';


import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WriteData {
  static Future<String> get InternalDirectory async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getFile(String extension) async {
    String path = await InternalDirectory;

    return File("$path/data$extension");
  }

  static void writeData(List<String> data, String extension) async {
    String dataString = "";
    File file = await getFile(extension);
    data.forEach((element) {
      dataString = "$dataString$element\n";
    });
    await file.writeAsString(dataString);
    await Share.shareFiles([file.path]);
    
  }
}
