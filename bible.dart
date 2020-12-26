import 'package:sqflite/sqflite.dart';
import 'file_mx.dart';

class Bible {

  final String module, filePath;
  final FileMx fileMx;
  Database db;
  Bible(this.module, this.filePath, this.fileMx);

  Future<void> openDatabase() async {
    db = await fileMx.openSqliteDB("FULLPATH", filePath);
  }

}