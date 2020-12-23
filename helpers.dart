import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:convert';

enum DialogAction {
  people,
  locations,
  topics,
  openHere,
  confirmRead,
  confirmSaveRead,
  confirmOpen,
  confirmSaveOpen,
  confirmSaveClose,
  confirmClose,
  delete,
  cancel,
  share,
  addFavourite,
  removeFavourite,
  copy,
  addCopy,
  compareAll,
  crossReference,
  interlinearOHGB,
  morphologyOHGB,
  interlinearLXX1,
  morphologyLXX1,
  interlinearLXX2,
  morphologyLXX2,
  interlinearABP,
  openVerse,
}

enum TtsState {
  playing,
  stopped,
}

class TtsHelper {

  // This workaroundHebrew functions is applicable to Android plaftfrom.
  static String workaroundHebrew(String text) {
    final List<List<String>> searchReplace = [
      ['w', 'v'],
      ['ō|ō|Ō|ô|ŏ', 'ο'],
      ['ê|ē|ĕ', 'e'],
      ['î|ī', 'i'],
      ['û', 'u'],
      //['š', 'sh'],
      ['ś', 's'],
      ['ă|ā|â', 'a'],
      ['[ʿʾ]', ''],
    ];
    for (List<String> i in searchReplace) {
      final String search = i.first;
      final String replace = i.last;
      text = text.replaceAll(RegExp(search), replace);
    }
    return text;
  }

  static String removeGreekAccents(String text) {
    List<List<String>> searchReplace = [
      ['[ἀἄᾄἂἆἁἅᾅἃάᾴὰᾶᾷᾳᾆᾀ]', 'α'],
      ['[ἈἌἎἉἍἋ]', 'Α'],
      ['[ἐἔἑἕἓέὲ]', 'ε'],
      ['[ἘἜἙἝἛ]', 'Ε'],
      ['[ἠἤᾔἢἦᾖᾐἡἥἣἧᾗᾑήῄὴῆῇῃ]', 'η'],
      ['[ἨἬἪἮἩἭἫ]', 'Η'],
      ['[ἰἴἶἱἵἳἷίὶῖϊΐῒ]', 'ι'],
      ['[ἸἼἹἽ]', 'Ι'],
      ['[ὀὄὂὁὅὃόὸ]', 'ο'],
      ['[ὈὌὉὍὋ]', 'Ο'],
      ['[ῥ]', 'ρ'],
      ['[Ῥ]', 'Ρ'],
      ['[ὐὔὒὖὑὕὓὗύὺῦϋΰῢ]', 'υ'],
      ['[ὙὝὟ]', 'Υ'],
      ['[ὠὤὢὦᾠὡὥὧᾧώῴὼῶῷῳᾤὣ]', 'ω'],
      ['[ὨὬὪὮὩὭὯ]', 'Ω'],
      [
        "[\-\—\,\;\:\\\?\.\·\·\'\‘\’\᾿\‹\›\“\”\«\»\(\)\[\]\{\}\⧼\⧽\〈\〉\*\‿\᾽\⇔\¦]",
        ""
      ],
    ];
    for (List<String> i in searchReplace) {
      final String search = i.first;
      final String replace = i.last;
      text = text.replaceAll(RegExp(search), replace);
    }
    return text;
  }

}

/*class FileIOHelper {

  String getDataPath(String dataType, [String module]) => "assets/$dataType/$module.json";

}*/

class JsonHelper {

  Future<dynamic> getJsonObject(filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    dynamic jsonObject = jsonDecode(jsonString);
    return jsonObject;
  }

}

class RegexHelper {

  RegExp searchPattern;
  String patternString;
  List<List<String>> searchReplace;

  String Function(Match) replacement(String pattern) => (Match match) => pattern
      .replaceAllMapped(new RegExp(r'\\(\d+)'), (m) => match[int.parse(m[1])]);

  String replaceAllSmart(
          String source, Pattern pattern, String replacementPattern) =>
      source.replaceAllMapped(pattern, replacement(replacementPattern));

  String doSearchReplace(String text,
      {bool multiLine = false,
      bool caseSensitive = true,
      bool unicode = false,
      bool dotAll = false}) {
    String replacedText = text;
    for (List<String> i in searchReplace) {
      final String search = i.first;
      final String replace = i.last;
      replacedText = replaceAllSmart(
          replacedText,
          RegExp(search,
              multiLine: multiLine,
              caseSensitive: caseSensitive,
              unicode: unicode,
              dotAll: dotAll),
          replace);
    }
    return replacedText;
  }

}

class InterlinearHelper {

  TextStyle _verseFontGreek,
      _activeVerseFontGreek,
      _verseFontHebrew,
      _activeVerseFontHebrew,
      _interlinearStyleDim,
      _interlinearStyle;

  InterlinearHelper(Map<String, TextStyle> verseTextStyle) {
    _verseFontGreek = verseTextStyle["verseFontGreek"];
    _activeVerseFontGreek = verseTextStyle["activeVerseFontGreek"];
    _verseFontHebrew = verseTextStyle["verseFontHebrew"];
    _activeVerseFontHebrew = verseTextStyle["activeVerseFontHebrew"];
    _interlinearStyleDim = verseTextStyle["interlinearStyleDim"];
    _interlinearStyle = verseTextStyle["interlinearStyle"];
  }

  List<TextSpan> getInterlinearSpan(String module, String text, int book, [bool isActive = false]) {
    bool isHebrewBible = (book < 40) && (module == "OHGBi");

    TextStyle originalStyle;
    if (!isActive) {
      originalStyle = _verseFontGreek;
      if (isHebrewBible) originalStyle = _verseFontHebrew;
    } else {
      originalStyle = _activeVerseFontGreek;
      if (isHebrewBible) originalStyle = _activeVerseFontHebrew;
    }
    List<TextSpan> words = <TextSpan>[];
    List<String> wordList = text.split("｜");
    for (String word in wordList) {
      if (word.startsWith("＠")) {
        if (isHebrewBible) {
          List<String> glossList = word.substring(1).split(" ");
          for (String gloss in glossList) {
            if ((gloss.startsWith("[")) || (gloss.endsWith("]"))) {
              gloss = gloss.replaceAll(RegExp(r"[\[\]\+\.]"), "");
              words.add(TextSpan(text: "$gloss ", style: _interlinearStyleDim));
            } else {
              words.add(TextSpan(text: "$gloss ", style: _interlinearStyle));
            }
          }
        } else {
          words
              .add(TextSpan(text: word.substring(1), style: _interlinearStyle));
        }
      } else {
        words.add(TextSpan(text: word, style: originalStyle));
      }
    }

    return words;
  }

}
