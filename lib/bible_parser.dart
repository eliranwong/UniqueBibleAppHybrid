import 'helpers.dart';
import 'bible_books.dart';

class BibleParser {
  Map<String, String> bibleBookNo;
  Map<String, String> standardBookname = {};
  Map<String, String> standardAbbreviation = {};
  Map<String, Set<int>> bookCollections = {};

  // constructor
  BibleParser(String abbreviations) {
    bibleBookNo = BibleBooks.bibleBookNo;
    updateAbbreviations(abbreviations);
  }

  void updateAbbreviations(String abbreviations) {
    // set standard abbreviation
    final Map<String, Map<String, String>> standardAbbreviationsMap = {
      "ENG": BibleBooks.standardAbbreviationENG,
      "TC": BibleBooks.standardAbbreviationTC,
      "SC": BibleBooks.standardAbbreviationSC,
    };
    standardAbbreviation = standardAbbreviationsMap[abbreviations];
    // set standard book name
    final Map<String, Map<String, String>> standardBookNameMap = {
      "ENG": BibleBooks.standardBooknameENG,
      "TC": BibleBooks.standardBooknameTC,
      "SC": BibleBooks.standardBooknameSC,
    };
    standardBookname = standardBookNameMap[abbreviations];
    // set book collections
    final Map<String, Map<String, Set<int>>> bookCollectionsMap = {
      "ENG": BibleBooks.bookCollectionsENG,
      "TC": BibleBooks.bookCollectionsTC,
      "SC": BibleBooks.bookCollectionsSC,
    };
    bookCollections = bookCollectionsMap[abbreviations];
  }

  // function for converting b c v integers to verse reference string
  String bcvToVerseReference(List<int> bcvList) {
    final int b = bcvList[0], c = bcvList[1], v = bcvList[2];
    int c2, v2;
    if (bcvList.length == 5) {
      int c2 = bcvList[3];
      int v2 = bcvList[4];
    }

    final String bookNo = "$b";
    if (standardAbbreviation.containsKey(bookNo)) {
      final String abbreviation = standardAbbreviation[bookNo];
      if ((c2 != null) && (c2 == c) && (v2 > v)) {
        return "$abbreviation $c:$v-$v2";
      } else if ((c2 != null) && (c2 > c)) {
        return "$abbreviation $c:$v-$c2:$v2";
      } else {
        return "$abbreviation $c:$v";
      }
    } else {
      // Book number not recognised.
      return "BOOK 0:0";
    }
  }

  String bcvToChapterReference(List<int> bcvList) {
    String bcvRef;
    if (bcvList.length >= 3) {
      bcvRef = bcvToVerseReference(bcvList);
    } else if (bcvList.length == 2) {
      bcvRef = bcvToVerseReference([...bcvList, 1]);
    }
    return bcvRef.replaceAll(RegExp(r":.*?$"), "");
  }

  String parseText(String text) {
    // setup regexHelper
    final RegexHelper regex = RegexHelper();

    // add a space at the end of the text, to avoid indefinite loop in later steps
    // this extra space will be removed when parsing is finished.
    String taggedText = "$text ";

    // remove bcv tags, if any, to avoid duplication of tagging in later steps
    regex.patternString = r'<ref onclick="bcv\([^\(\)]*?\)">(.*?)</ref>';
    regex.searchPattern = RegExp(regex.patternString, multiLine: true);
    while (regex.searchPattern.hasMatch(taggedText)) {
      regex.searchReplace = [
        [regex.patternString, r'\1'],
      ];
      taggedText = regex.doSearchReplace(taggedText, multiLine: true);
    }

    // search for books; mark them with book numbers, used by https://marvel.bible
    // sorting books by alphabet
    List<String> sortedBooks = bibleBookNo.keys.toList()..sort();
    // sorting books by length
    sortedBooks.sort((a, b) => b.length.compareTo(a.length));

    for (var book in sortedBooks) {
      // get the string of book name
      String bookString = book;

      regex.searchReplace = [
        ['\\.', r'[\.]*?'], // make dot "." optional for an abbreviation
        ['^([0-9]+?) ', r'\1[ ]*?'], // make space " " optional in some cases
        ['^([I]+?) ', r'\1[ ]*?'],
        ['^(IV) ', r'\1[ ]*?'],
      ];
      bookString = regex.doSearchReplace(bookString);

      // get assigned book number from dictionary
      String bookNumber = bibleBookNo[book];

      // search & replace for marking book
      regex.searchReplace = [
        ['($bookString) ([0-9])', '『$bookNumber｜\\1』 \\2'],
      ];
      taggedText = regex.doSearchReplace(taggedText, multiLine: true);
    }

    regex.searchReplace = [
      // add first set of taggings:
      [
        '『([0-9]+?)｜([^『』]*?)』 ([0-9]+?):([0-9]+?)([^0-9])',
        r'<ref onclick="bcv(\1,\3,\4)">\2 \3:\4</ref｝\5'
      ],
      [
        '『([0-9]+?)｜([^『』]*?)』 ([0-9]+?)([^0-9])',
        r'<ref onclick="bcv(\1,\3,)">\2 \3</ref｝\4'
      ],
      // fix references without verse numbers
      // fix books with chapter 1 ONLY; oneChapterBook = [31,57,63,64,65,72,73,75,79,85]
      [
        r'<ref onclick="bcv\((31|57|63|64|65|72|73|75|79|85),([0-9]+?),\)">',
        r'<ref onclick="bcv(\1,1,\2)">'
      ],
      // fix references of chapters without verse number; assign verse number 1 in taggings
      [
        r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),\)">',
        r'<ref onclick="bcv(\1,\2,1)">＊'
      ],
    ];
    taggedText = regex.doSearchReplace(taggedText, multiLine: true);

    // check if verses following tagged references, e.g. Book 1:1-2:1; 3:2-4, 5; Jude 1
    regex.searchPattern = RegExp('</ref｝[,-–;][ ]*?[0-9]', multiLine: true);
    while (regex.searchPattern.hasMatch(taggedText)) {
      regex.searchReplace = [
        [
          r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">([^｝]*?)</ref｝([,-–;][ ]*?)([0-9]+?):([0-9]+?)([^0-9])',
          r'<ref onclick="bcv(\1,\2,\3)">\4</ref｝\5<ref onclick="bcv(\1,\6,\7)">\6:\7</ref｝\8'
        ],
        [
          r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">([^＊][^｝]*?)</ref｝([,-–;][ ]*?)([0-9]+?)([^:0-9])',
          r'<ref onclick="bcv(\1,\2,\3)">\4</ref｝\5<ref onclick="bcv(\1,\2,\6)">\6</ref｝\7'
        ],
        [
          r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">([^＊][^｝]*?)</ref｝([,-–;][ ]*?)([0-9]+?):([^0-9])',
          r'<ref onclick="bcv(\1,\2,\3)">\4</ref｝\5<ref onclick="bcv(\1,\2,\6)">\6</ref｝:\7'
        ],
        [
          r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">(＊[^｝]*?)</ref｝([,-–;][ ]*?)([0-9]+?)([^:0-9])',
          r'<ref onclick="bcv(\1,\2,\3)">\4</ref｝\5<ref onclick="bcv(\1,\6,1)">＊\6</ref｝\7'
        ],
        [
          r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">(＊[^｝]*?)</ref｝([,-–;][ ]*?)([0-9]+?):([^0-9])',
          r'<ref onclick="bcv(\1,\2,\3)">\4</ref｝\5<ref onclick="bcv(\1,\6,1)">＊\6</ref｝:\7'
        ],
      ];
      taggedText = regex.doSearchReplace(taggedText, multiLine: true);
    }

    // clear special markers
    regex.searchReplace = [
      ['『[0-9]+?|([^『』]*?)』', r'\1'],
      [r'(<ref onclick="bcv\([0-9]+?,[0-9]+?,[0-9]+?\)">)＊', r'\1'],
      ['</ref｝', '</ref>'],
    ];
    taggedText = regex.doSearchReplace(taggedText, multiLine: true);

    // handling range of verses
    // e.g. John 3:16 is tagged as <ref onclick="bcv(43,3,16)">John 3:16</ref>
    // e.g. John 3:14-16 is tagged as <ref onclick="bcv(43,3,14,3,16)">John 3:14-16</ref>
    // e.g. John 3:14-4:3 is tagged as <ref onclick="bcv(43,3,14,4,3)">John 3:14-4:3</ref>
    regex.patternString =
        r'<ref onclick="bcv\(([0-9]+?),([0-9]+?),([0-9]+?)\)">([^<>]*?)</ref>([-–])<ref onclick="bcv\(\1,([0-9]+?),([0-9]+?)\)">';
    regex.searchPattern = RegExp(regex.patternString, multiLine: true);
    while (regex.searchPattern.hasMatch(taggedText)) {
      regex.searchReplace = [
        [regex.patternString, r'<ref onclick="bcv(\1,\2,\3,\6,\7)">\4\5'],
      ];
      taggedText = regex.doSearchReplace(taggedText, multiLine: true);
    }

    // remove the extra space, added at the beginning of this function
    taggedText = taggedText.substring(0, (taggedText.length - 1));

    return taggedText;
  }

  List<List<int>> extractAllReferences(String text, {bool tagged = false}) {
    // Parse the text only if it is not already tagged.
    final String taggedText = (!tagged) ? parseText(text) : text;

    List<List<int>> verseReferenceList = [];

    RegExp searchPattern = RegExp(r'bcv\(([0-9]+?,[0-9]+?,[0-9]+?[^\)\(]*?)\)');
    for (RegExpMatch match in searchPattern.allMatches(taggedText)) {
      final List<String> stringList = match.group(1).split(",");
      //verseReferenceList.add(stringList.map((i) => int.parse(i)).toList());
      verseReferenceList.add([for (String i in stringList) int.parse(i)]);
    }

    return verseReferenceList;
  }

  /*
  Future tagFiles(List filePaths) async {
    var fileIO = FileIOHelper();
    for (var filePath in filePaths) {
      var isInputFile = await fileIO.isFile(filePath);
      var fileBasename = fileIO.getBasename(filePath);
      if ((isInputFile) && (!fileBasename.startsWith("."))) {
        var outputFilePath = "${filePath}_output.txt";
        fileIO.formatTextFile(filePath, parseText, outputFilePath);
      }
    }
  }

  Future tagFilesInsideFolder(String folderPath) async {
    var fileList = await FileIOHelper().getFileListInFolder(folderPath);
    tagFiles(fileList);
  }
  */

}
