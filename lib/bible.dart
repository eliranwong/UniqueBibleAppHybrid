import 'package:sqflite/sqflite.dart';
import 'file_mx.dart';

class Bible {
  final String module, filePath;
  final FileMx fileMx;
  Database db;
  List<int> bookList, chapterList, verseList, menuChapterList, menuVerseList;
  //Map<int, List<int>> allChapterList;
  //Map<String, List<int>> allVerseList;
  List<List<dynamic>> chapterData;
  Set<int> bibleSearchBookFilter = {};
  String lastBibleSearchEntry = "";
  int lastBibleSearchHit = 0, searchItemsPerPage = 20, menuBook, menuChapter;
  Map<int, List<List<dynamic>>> lastBibleSearchResults = {}, lastBibleSearchResultsLazy = {};

  Bible(this.module, this.filePath, this.fileMx);

  static String processVerseText(String verseText) {
    verseText = verseText.trim();
    if (verseText.contains("<zh>"))
      verseText = verseText.replaceAll(RegExp("<zh>|</zh>"), "");
    return verseText;
  }

  Future<void> openDatabase() async {
    db = await fileMx.openSqliteDB("FULLPATH", filePath);
  }

  Future<void> updateBCVMenu(List<int> bcvList) async {
    bookList = await getBookList();
    /*allChapterList = {for (int book in bookList) book: await getChapterList([book, 1, 1])};
    allVerseList = {};
    for (MapEntry bookChapter in allChapterList.entries) {
      int bookNo = bookChapter.key;
      for (int chapter in bookChapter.value) {
        allVerseList["$bookNo.$chapter"] = await getVerseList([bookNo, chapter, 1]);
      }
    }
    chapterList = allChapterList[bcvList.first];
    verseList = allVerseList["${bcvList.first}.${bcvList[1]}"];*/
    chapterList = await getChapterList(bcvList);
    menuChapterList = chapterList;
    verseList = await getVerseList(bcvList);
    menuVerseList = verseList;
    menuBook = bcvList.first;
    menuChapter = bcvList[1];
  }

  Future<void> updateMenuBook(int book, {int chapter = -1}) async {
    menuBook = book;
    menuChapterList = await getChapterList([(chapter == -1) ? menuBook : chapter, 1, 1]);
    await updateMenuChapter(menuChapterList.first);
  }

  Future<void> updateMenuChapter(int chapter) async {
    menuChapter = chapter;
    menuVerseList = await getVerseList([menuBook, menuChapter, 1]);
  }

  Future<void> updateChapterData(List<int> bcvList) async {
    chapterData = await getChapterData(bcvList);
  }

  Future<List<int>> getBookList() async {
    final String query = "SELECT DISTINCT Book FROM Verses ORDER BY Book";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, []);
    return [
      for (Map<String, dynamic> result in results)
        if (result["Book"] != 0) result["Book"]
    ];
  }

  Future<List<int>> getChapterList(List<int> bcvList) async {
    final String query =
        "SELECT DISTINCT Chapter FROM Verses WHERE Book=? ORDER BY Chapter";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, [bcvList.first]);
    return [for (Map<String, dynamic> result in results) result["Chapter"]];
  }

  Future<List<int>> getVerseList(List<int> bcvList) async {
    final String query =
        "SELECT DISTINCT Verse FROM Verses WHERE Book=? AND Chapter=? ORDER BY Verse";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return [for (Map<String, dynamic> result in results) result["Verse"]];
  }

  List<dynamic> verseDataToList(Map<String, dynamic> verseData) => [
        [verseData["Book"], verseData["Chapter"], verseData["Verse"]],
        verseData["Scripture"],
        module
      ];

  Future<List<dynamic>> getSingleVerseData(List<int> bcvList) async {
    final String query =
        "SELECT * FROM Verses WHERE Book=? AND Chapter=? AND Verse=?";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return (results.isNotEmpty) ? verseDataToList(results.first) : [];
  }

  Future<List<List<dynamic>>> getChapterData(List<int> bcvList) async {
    final String query =
        "SELECT * FROM Verses WHERE Book=? AND Chapter=? ORDER BY Verse";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return [
      for (Map<String, dynamic> result in results) verseDataToList(result)
    ];
  }

  Future<void> searchMultipleBooks(String searchEntry, int searchEntryOption, {List<int> filter = const []}) async {
    lastBibleSearchEntry = searchEntry;
    lastBibleSearchResults = {};
    lastBibleSearchResultsLazy = {};
    lastBibleSearchHit = 0;
    List<int> searchBooks = (filter.isEmpty) ? bookList : filter;
    for (int book in searchBooks) {
      final result = await getSearchData(searchEntry, searchEntryOption, book: book);
      if (result.isNotEmpty) {
        lastBibleSearchResults[book] = result;
        lastBibleSearchHit = lastBibleSearchHit + result.length;
      }
    }
    lastBibleSearchResultsLazy = {
      for (MapEntry i in lastBibleSearchResults.entries)
        i.key: (i.value.length > searchItemsPerPage)
            ? [...i.value.sublist(0, searchItemsPerPage), []]
            : i.value
    };
  }

  void updateLastBibleSearchResultsLazy(int key) {
    final List<List<dynamic>> allItems = lastBibleSearchResults[key];
    List<List<dynamic>> currentLazyItems = lastBibleSearchResultsLazy[key];
    int currentLazyItemsNo = currentLazyItems.length - 1;
    int currentLazyItemsMoreNo = currentLazyItemsNo + searchItemsPerPage;
    currentLazyItems = (allItems.length > currentLazyItemsMoreNo) ? [...allItems.sublist(0, currentLazyItemsMoreNo), []] : allItems;
    lastBibleSearchResultsLazy[key] = currentLazyItems;
  }

  Future<List<List<dynamic>>> getSearchData(String searchEntry, int searchEntryOption, {int book = 0}) async {

    String query;
    final String queryPrefix = "SELECT * FROM Verses WHERE";
    final String bookFilter = " Book = ? AND ";
    String queryCondition;
    List<dynamic> filters;
    List<Map<String, dynamic>> results;

    switch (searchEntryOption) {
      case 0:
        filters = ["%$searchEntry%"];
        queryCondition = "Scripture LIKE ?";
        break;
      case 1:
        filters = [for (String entry in searchEntry.split("|")) "%$entry%"];
        queryCondition = "(${List<String>.generate(filters.length, (i) => "Scripture LIKE ?").join(" AND ")})";
        break;
      case 2:
        filters = [for (String entry in searchEntry.split("|")) "%$entry%"];
        queryCondition = "(${List<String>.generate(filters.length, (i) => "Scripture LIKE ?").join(" OR ")})";
        break;
      case 3:
        filters = [];
        queryCondition = searchEntry;
        break;
      default:
        break;
    }
    query = "$queryPrefix${(book != 0) ? bookFilter : ' '}$queryCondition";
    filters = (book != 0) ? [book, ...filters] : filters;
    results = await fileMx.queryOpenedSqliteDB(db, query, filters);
    return [
      for (Map<String, dynamic> result in results) verseDataToList(result)
    ];
  }
}
