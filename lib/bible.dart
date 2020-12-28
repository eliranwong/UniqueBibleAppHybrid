import 'package:sqflite/sqflite.dart';
import 'file_mx.dart';

class Bible {

  final String module, filePath;
  final FileMx fileMx;
  Database db;
  List<int> bookList, chapterList, verseList;
  List<List<dynamic>> chapterData;

  Bible(this.module, this.filePath, this.fileMx);

  Future<void> openDatabase() async {
    db = await fileMx.openSqliteDB("FULLPATH", filePath);
  }

  Future<void> updateBCVMenu(List<int> bcvList) async {
    bookList = await getBookList();
    chapterList = await getChapterList(bcvList);
    verseList = await getVerseList(bcvList);
  }

  Future<void> updateChapterData(List<int> bcvList) async {
    chapterData = await getChapterData(bcvList);
  }

  Future<List<int>> getBookList() async {
    final String query = "SELECT DISTINCT Book FROM Verses ORDER BY Book";
    final List<Map<String, dynamic>> results = await fileMx.queryOpenedSqliteDB(db, query, []);
    return [for (Map<String, dynamic> result in results) if (result["Book"] != 0) result["Book"]];
  }

  Future<List<int>> getChapterList(List<int> bcvList) async {
    final String query = "SELECT DISTINCT Chapter FROM Verses WHERE Book=? ORDER BY Chapter";
    final List<Map<String, dynamic>> results = await fileMx.queryOpenedSqliteDB(db, query, [bcvList.first]);
    return [for (Map<String, dynamic> result in results) result["Chapter"]];
  }

  Future<List<int>> getVerseList(List<int> bcvList) async {
    final String query = "SELECT DISTINCT Verse FROM Verses WHERE Book=? AND Chapter=? ORDER BY Verse";
    final List<Map<String, dynamic>> results = await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return [for (Map<String, dynamic> result in results) result["Verse"]];
  }

  List<dynamic> verseDataToList(Map<String, dynamic> verseData) => [[verseData["Book"], verseData["Chapter"], verseData["Verse"]], verseData["Scripture"], module];

  Future<List<dynamic>> getSingleVerseData(List<int> bcvList) async {
    final String query = "SELECT * FROM Verses WHERE Book=? AND Chapter=? AND Verse=?";
    final List<Map<String, dynamic>> results = await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return (results.isNotEmpty) ? verseDataToList(results.first) : [];
  }

  Future<List<List<dynamic>>> getChapterData(List<int> bcvList) async {
    final String query = "SELECT * FROM Verses WHERE Book=? AND Chapter=? ORDER BY Verse";
    final List<Map<String, dynamic>> results = await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return [for (Map<String, dynamic> result in results) verseDataToList(result)];
  }

}