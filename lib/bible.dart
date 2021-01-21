import 'package:flutter/material.dart';
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
  String lastBibleSearchEntry = "", lastBibleSearchExclusionEntry = "";
  int lastBibleSearchEntryOption = 0, lastBibleSearchHit = 0, searchItemsPerPage = 20, menuBook, menuChapter;
  Map<int, List<List<dynamic>>> lastBibleSearchResults = {},
      lastBibleSearchResultsLazy = {};

  Bible(this.module, this.filePath, this.fileMx);

  Future<void> openDatabase() async => db = await fileMx.openSqliteDB("FULLPATH", filePath);

  Future<void> updateBCVMenu(List<int> bcvList) async {
    bookList = await getBookList();
    chapterList = await getChapterList(bcvList);
    menuChapterList = chapterList;
    verseList = await getVerseList(bcvList);
    menuVerseList = verseList;
    menuBook = bcvList.first;
    menuChapter = bcvList[1];
  }

  Future<void> updateMenuBook(int book, {int chapter = -1}) async {
    menuBook = book;
    menuChapterList =
        await getChapterList([(chapter == -1) ? menuBook : chapter, 1, 1]);
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
    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String query = "SELECT DISTINCT Book FROM $queryTable ORDER BY Book";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, []);
    return [
      for (Map<String, dynamic> result in results)
        if (result["Book"] != 0) result["Book"]
    ];
  }

  Future<List<int>> getChapterList(List<int> bcvList) async {
    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String query =
        "SELECT DISTINCT Chapter FROM $queryTable WHERE Book=? ORDER BY Chapter";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, [bcvList.first]);
    return [for (Map<String, dynamic> result in results) result["Chapter"]];
  }

  Future<List<int>> getVerseList(List<int> bcvList) async {
    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String query =
        "SELECT DISTINCT Verse FROM $queryTable WHERE Book=? AND Chapter=? ORDER BY Verse";
    final List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    return [for (Map<String, dynamic> result in results) result["Verse"]];
  }

  List<Map<String, dynamic>> transformMorphologyToScripture(List<Map<String, dynamic>> results) {
    Map<String, List<Map<String, dynamic>>> bcvMap = {};
    for (Map<String, dynamic> result in results) {
      final String bcvString = "${result["Book"]}.${result["Chapter"]}.${result["Verse"]}";
      bcvMap[bcvString] = (bcvMap.containsKey(bcvString)) ? [...bcvMap[bcvString], result] : [result];
    }
    List<Map<String, dynamic>> transformedResults = [];
    for (MapEntry entry in bcvMap.entries) {
      String verseText = "";
      int clauseID = entry.value.first["ClauseID"];
      for (Map<String, dynamic> word in entry.value) {
        final wordString = "<cid>${word["ClauseID"]}</cid><wid>${word["WordID"]}</wid><w>${word["Word"]}</w>"
            "<transliterate>${word["Transliteration"]}</transliterate>"
            "<pronounce>${word["Pronunciation"]}</pronounce>"
            "<lexeme>${word["Lexeme"]}</lexeme>"
            "<lexicon>${word["LexicalEntry"]}</lexicon>"
            "<gloss>${word["Gloss"]}</gloss>"
            "<morphCode>${word["MorphologyCode"]}</morphCode><morph>${word["Morphology"]}</morph>"
            "<literal>${word["Interlinear"]}</literal>"
            "<smooth>${word["Translation"]}</smooth>";
        if (word["ClauseID"] == clauseID) {
          verseText = "$verseText｜$wordString";
        } else {
          verseText = "$verseText＠$wordString";
          clauseID++;
        }
      }
      List<int> bcvList = [for (String i in entry.key.split(".")) int.parse(i)];
      transformedResults.add({
        "Book": bcvList.first,
        "Chapter": bcvList[1],
        "Verse": bcvList.last,
        "Scripture": verseText.substring(1, verseText.length),
      });
    }
    return transformedResults;
  }

  List<dynamic> verseDataToList(Map<String, dynamic> verseData) => [
    [verseData["Book"], verseData["Chapter"], verseData["Verse"]],
    verseData["Scripture"],
    module
  ];

  Future<List<dynamic>> getVerseData(List<int> bcvList) async => (bcvList.length > 3) ? await getSingleVerseDataRange(bcvList) : await getSingleVerseData(bcvList);

  Future<List<dynamic>> getSingleVerseData(List<int> bcvList) async {
    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String query =
        "SELECT * FROM $queryTable WHERE Book=? AND Chapter=? AND Verse=?";
    List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 3));
    if (module == "OHGBc") results = transformMorphologyToScripture(results);
    return (results.isNotEmpty) ? verseDataToList(results.first) : [];
  }

  Future<List<dynamic>> getSingleVerseDataRange(List bcvList) async {

    List<List<dynamic>> results = [];
    String verseText ="";

    int b = bcvList[0], c1 = bcvList[1], v1 = bcvList[2];
    int c2 = bcvList[3], v2 = bcvList[4];

    if ((c2 == c1) && (v2 > v1)) {
      // same chapter
      results = [for (int v = v1; v <= v2; v++) await getSingleVerseData([b, c1, v])];
      verseText = <String>[for (List<dynamic> data in results) if (data.isNotEmpty) "[${data.first[2]}] ${data[1]}"].join(" ");
    } else if (c2 > c1) {
      // different chapters
      for (int c = c1; c <= c2; c++) {
        List<int> verseList = await getVerseList([b, c, 1]);
        if (c == c1) {
          results.addAll([for (int v = v1; v <= verseList.last; v++) await getSingleVerseData([b, c, v])]);
        } else if (c < c2) {
          results.addAll([for (int v = verseList.first; v <= verseList.last; v++) await getSingleVerseData([b, c, v])]);
        } else if (c == c2) {
          results.addAll([for (int v = verseList.first; v <= v2; v++) await getSingleVerseData([b, c, v])]);
        }
      }
      verseText = <String>[for (List<dynamic> data in results) if (data.isNotEmpty) "[${data.first[1]}:${data.first[2]}] ${data[1]}"].join(" ");
    }

    return [bcvList, verseText, module];
  }

  Future<List<List<dynamic>>> getChapterData(List<int> bcvList) async {
    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String query =
        "SELECT * FROM $queryTable WHERE Book=? AND Chapter=? ORDER BY Verse";
    List<Map<String, dynamic>> results =
        await fileMx.queryOpenedSqliteDB(db, query, bcvList.sublist(0, 2));
    if (module == "OHGBc") results = transformMorphologyToScripture(results);
    return [
      for (Map<String, dynamic> result in results) verseDataToList(result)
    ];
  }

  Future<void> searchMultipleBooks(String searchEntry, int searchEntryOption,
      {List<int> filter = const [], String exclusion = ""}) async {

    // In case book list is null.
    if (bookList == null) bookList = await getBookList();

    lastBibleSearchEntry = searchEntry;
    lastBibleSearchExclusionEntry = exclusion;
    lastBibleSearchResults = {};
    lastBibleSearchResultsLazy = {};
    lastBibleSearchHit = 0;
    List<int> searchBooks = (filter.isEmpty) ? bookList : filter;
    for (int book in searchBooks) {
      final result =
          await getSearchData(searchEntry, searchEntryOption, book: book, exclusion: exclusion);
      if (result.isNotEmpty) {
        lastBibleSearchResults[book] = result;
        lastBibleSearchResultsLazy[book] = (result.length > searchItemsPerPage)
            ? [...result.sublist(0, searchItemsPerPage), []]
            : result;
        lastBibleSearchHit = lastBibleSearchHit + result.length;
      }
    }
  }

  void updateLastBibleSearchResultsLazy(int key) {
    final List<List<dynamic>> allItems = lastBibleSearchResults[key];
    List<List<dynamic>> currentLazyItems = lastBibleSearchResultsLazy[key];
    int currentLazyItemsNo = currentLazyItems.length - 1;
    int currentLazyItemsMoreNo = currentLazyItemsNo + searchItemsPerPage;
    currentLazyItems = (allItems.length > currentLazyItemsMoreNo)
        ? [...allItems.sublist(0, currentLazyItemsMoreNo), []]
        : allItems;
    lastBibleSearchResultsLazy[key] = currentLazyItems;
  }

  Future<List<List<dynamic>>> getSearchData(
      String searchEntry, int searchEntryOption,
      {int book = 0, String exclusion = ""}) async {

    // Avoid errors if database is closed or not opened.
    if ((db == null) || (!db.isOpen)) await openDatabase();

    String query;
    final String queryTable = (module == "OHGBc") ? "Data" : "Verses";
    final String queryPrefix = "SELECT * FROM $queryTable WHERE";
    final String bookFilter = " Book = ?";
    final String andOperator = " AND ";
    final String querySuffix = "ORDER BY Book, Chapter, Verse";
    String queryCondition;
    List<dynamic> filters;
    String exclusionCondition;
    List<dynamic> exclusionFilters;
    List<Map<String, dynamic>> results;

    switch (searchEntryOption) {
      // Plain text
      case 0:
        filters = ["%$searchEntry%"];
        queryCondition = (module == "OHGBc") ? "Interlinear LIKE ?" : "Scripture LIKE ?";
        break;
      // Regular expression
      case 1:
        filters = [];
        queryCondition = "";
        break;
      // AND combo
      case 2:
        filters = [for (String entry in searchEntry.split("|")) "%$entry%"];
        queryCondition =
            "(${List<String>.generate(filters.length, (i) => (module == "OHGBc") ? "Interlinear LIKE ?" : "Scripture LIKE ?").join(" AND ")})";
        break;
      // OR combo
      case 3:
        filters = [for (String entry in searchEntry.split("|")) "%$entry%"];
        queryCondition =
            "(${List<String>.generate(filters.length, (i) => (module == "OHGBc") ? "Interlinear LIKE ?" : "Scripture LIKE ?").join(" OR ")})";
        break;
      // Advanced
      // Complete SQL statement started with 'SELECT * FROM Verses WHERE'
      case 4:
        filters = [];
        queryCondition = "($searchEntry)";
        break;
      default:
        break;
    }

    if (exclusion.isNotEmpty) {
      exclusionFilters = [for (String entry in exclusion.split("|")) "%$entry%"];
      exclusionCondition =
      "(${List<String>.generate(exclusionFilters.length, (i) => (module == "OHGBc") ? "Interlinear NOT LIKE ?" : "Scripture NOT LIKE ?").join(" AND ")})";
    }

    query =
        "$queryPrefix${(book != 0) ? bookFilter : ''}${(queryCondition.isEmpty ? ' ' : andOperator)}$queryCondition${(exclusion.isEmpty) ? '' : " AND $exclusionCondition"}${(queryCondition.isEmpty ? '' : ' ')}$querySuffix";
    filters = (book != 0) ? [book, ...filters] : filters;
    if (exclusion.isNotEmpty) filters = [...filters, ...exclusionFilters];
    results = await fileMx.queryOpenedSqliteDB(db, query, filters);

    if (module == "OHGBc") results = transformMorphologyToScripture(results);

    // Dealing with regular expression
    if (searchEntryOption == 1) results = results.where((i) => (RegExp(searchEntry).hasMatch(i["Scripture"]))).toList();

    // update lastBibleSearchEntryOption
    lastBibleSearchEntryOption = searchEntryOption;

    return [
      for (Map<String, dynamic> result in results) verseDataToList(result)
    ];
  }
}
