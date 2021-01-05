// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'module_description.dart';
import 'bible.dart';
import 'file_mx.dart';
import 'bible_parser.dart';
//import 'bible_books.dart';

final configurationsProvider = FutureProvider<Configurations>((ref) async {
  final Configurations configurations = Configurations();
  await configurations.setup();
  return configurations;
});

final configProvider = StateProvider<Configurations>((ref) {
  final AsyncValue<Configurations> config = ref.watch(configurationsProvider);
  return config.when(
    loading: () => Configurations(),
    error: (error, stack) => Configurations(),
    data: (config) => config,
  );
});

//final configCopyProvider = StateProvider<Configurations>((ref) => Configurations());

final showDrawerP = StateProvider<bool>(
        (ref) => ref.watch(configProvider).state.boolValues["showDrawer"]),
    keepDrawerOpenP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["keepDrawerOpen"]),
    showVerseSelectionP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showVerseSelection"]),
    parallelVersesP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["parallelVerses"]),
    bigScreenP = StateProvider<bool>(
        (ref) => ref.watch(configProvider).state.boolValues["bigScreen"]),
    showNotesP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showNotes"]),
    showFlagsP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showFlags"]),
    showPinyinP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showPinyin"]),
    showTransliterationP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showTransliteration"]),
    showHeadingVerseNoP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["showHeadingVerseNo"]),
    alwaysOpenMarvelBibleExternallyP = StateProvider<bool>(
            (ref) => ref.watch(configProvider).state.boolValues["alwaysOpenMarvelBibleExternally"]);

final abbreviationsP = StateProvider<String>(
        (ref) => ref.watch(configProvider).state.stringValues["abbreviations"]),
    bible1P = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["bible1"]),
    bible2P = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["bible2"]),
    iBibleP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["iBible"]),
    marvelBibleP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["marvelBible"]),
    marvelCommentaryP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["marvelCommentary"]),
    ttsChineseP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["ttsChinese"]),
    ttsEnglishP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["ttsEnglish"]),
    ttsGreekP = StateProvider<String>(
            (ref) => ref.watch(configProvider).state.stringValues["ttsGreek"]);

final fontSizeP = StateProvider<double>(
        (ref) => ref.watch(configProvider).state.doubleValues["fontSize"]),
    morphologyVersionP = StateProvider<double>(
            (ref) => ref.watch(configProvider).state.doubleValues["morphologyVersion"]),
    lexiconVersionP = StateProvider<double>(
            (ref) => ref.watch(configProvider).state.doubleValues["lexiconVersion"]),
    toolsVersionP = StateProvider<double>(
            (ref) => ref.watch(configProvider).state.doubleValues["toolsVersion"]),
    speechRateP = StateProvider<double>(
            (ref) => ref.watch(configProvider).state.doubleValues["speechRate"]);

final instantActionP = StateProvider<int>(
        (ref) => ref.watch(configProvider).state.intValues["instantAction"]),
    favouriteActionP = StateProvider<int>(
            (ref) => ref.watch(configProvider).state.intValues["favouriteAction"]),
    workspaceLayoutP = StateProvider<int>(
            (ref) => ref.watch(configProvider).state.intValues["workspaceLayout"]),
    backgroundBrightnessP = StateProvider<int>(
            (ref) => ref.watch(configProvider).state.intValues["backgroundBrightness"]);

final compareBibleListP = StateProvider<List<String>>(
        (ref) => ref.watch(configProvider).state.listStringValues["compareBibleList"]);

final historyActiveVerseP = StateProvider<List<List<int>>>(
        (ref) => ref.watch(configProvider).state.listListIntValues["historyActiveVerse"]),
    favouriteVerseP = StateProvider<List<List<int>>>(
            (ref) => ref.watch(configProvider).state.listListIntValues["favouriteVerse"]);

final mainThemeP = StateProvider<ThemeData>((ref) => ref.watch(configProvider).state.mainTheme);
final myColorsP = StateProvider<Map<String, Color>>((ref) => ref.watch(configProvider).state.myColors);
final myTextStyleP = StateProvider<Map<String, TextStyle>>((ref) => ref.watch(configProvider).state.myTextStyle);
final dropdownUnderlineP = StateProvider<Container>((ref) => ref.watch(configProvider).state.dropdownUnderline);

final menuBookP = StateProvider<int>((ref) => ref.watch(configProvider).state.bibleDB1.menuBook);
final menuChapterP = StateProvider<int>((ref) => ref.watch(configProvider).state.bibleDB1.menuChapter);
final menuChapterListP = StateProvider<List<int>>((ref) => ref.watch(configProvider).state.bibleDB1.menuChapterList);
final menuVerseListP = StateProvider<List<int>>((ref) => ref.watch(configProvider).state.bibleDB1.menuVerseList);

final bibleSearchDataP = StateProvider<Map<String, dynamic>>(
    (ref) {
      Map<String, dynamic> data = {};
      data["module"] = ref.watch(configProvider).state.bibleDB1.module;
      data["lastBibleSearchHit"] = ref.watch(configProvider).state.bibleDB1.lastBibleSearchHit;
      data["lastBibleSearchEntry"] = ref.watch(configProvider).state.bibleDB1.lastBibleSearchEntry;
      data["lastBibleSearchResults"] = ref.watch(configProvider).state.bibleDB1.lastBibleSearchResults;
      data["lastBibleSearchResultsLazy"] = ref.watch(configProvider).state.bibleDB1.lastBibleSearchResultsLazy;
      return data;
    }
);
final multipleVersesP = StateProvider<Map<String, dynamic>>(
        (ref) {
      Map<String, dynamic> data = {};
      data["multipleVersesShowVersion"] = ref.watch(configProvider).state.multipleVersesShowVersion;
      //data["multipleVersesData"] = ref.watch(configProvider).state.multipleVersesData;
      data["multipleVersesDataLazy"] = ref.watch(configProvider).state.multipleVersesDataLazy;
      return data;
    }
);

final searchEntryOptionP = StateProvider<int>((ref) => ref.watch(configProvider).state.searchEntryOption);
final searchEntryExclusionP = StateProvider<bool>((ref) => ref.watch(configProvider).state.searchEntryExclusion);
final searchWholeBibleP = StateProvider<bool>((ref) => ref.watch(configProvider).state.searchWholeBible);
final bibleSearchBookFilterP = StateProvider<Set<int>>((ref) => ref.watch(configProvider).state.bibleDB1.bibleSearchBookFilter);
final chapterData1P = StateProvider<List<List<dynamic>>>((ref) => ref.watch(configProvider).state.chapterData1);
final chapterData2P = StateProvider<List<List<dynamic>>>((ref) => ref.watch(configProvider).state.chapterData2);
final activeScrollIndex1P = StateProvider<int>((ref) => ref.watch(configProvider).state.activeScrollIndex1);
final activeScrollIndex2P = StateProvider<int>((ref) => ref.watch(configProvider).state.activeScrollIndex2);
final parserP = StateProvider<BibleParser>((ref) => BibleParser(ref.watch(abbreviationsP).state));
final activeVerseReferenceP = StateProvider<String>((ref) => ref.watch(configProvider).state.activeVerseReference);

class Configurations {
  SharedPreferences prefs;

  // The following variables change when intValues["backgroundBrightness"] or doubleValues["fontSize"] changes.
  ThemeData mainTheme;
  Map<String, TextStyle> myTextStyle;
  Map<String, Color> myColors;
  Container dropdownUnderline;

  // Variables which are not stored in preferences.
  // Search
  bool searchWholeBible = true, searchEntryExclusion = false;
  int searchEntryOption = 0;
  // Multiple verses
  bool multipleVersesShowVersion = false;
  List<List<dynamic>> multipleVersesData = [], multipleVersesDataLazy = [];
  int searchItemsPerPage = 20;

  // Variables which are stored in preferences.
  // Default values.
  // Default bool values.
  Map<String, bool> boolValues = {
    "bigScreen": true,
    "showVerseSelection": false,
    "showNotes": false,
    "showFlags": false,
    "showPinyin": false,
    "showTransliteration": false,
    "showDrawer": true,
    "keepDrawerOpen": false,
    "showHeadingVerseNo": false,
    "alwaysOpenMarvelBibleExternally": false,
    "parallelVerses": false,
  };
  // Default String values.
  Map<String, String> stringValues = {
    "abbreviations": "ENG",
    "bible1": "KJV",
    "bible2": "NET",
    "iBible": "OHGBi",
    "marvelBible": "MAB",
    "marvelCommentary": "cCBSC",
    "ttsChinese": "zh-CN",
    "ttsEnglish": "en-GB",
    "ttsGreek": "modern",
  };
  // Default double values.
  Map<String, double> doubleValues = {
    "fontSize": 20.0,
    "morphologyVersion": 0.0,
    "lexiconVersion": 0.0,
    "toolsVersion": 0.0,
    "speechRate": (Platform.isAndroid) ? 1.0 : 0.5,
  };
  // Default double values.
  Map<String, int> intValues = {
    "instantAction": 1,
    "favouriteAction": 2,
    "backgroundBrightness": 0,
    "workspaceLayout": 0,
  };
  // Default List<String> values.
  Map<String, List<String>> listStringValues = {
    "compareBibleList": ModuleDescription.compareBibleList,
  };
  // Default List<List<int>> values.
  Map<String, List<List<int>>> listListIntValues = {
    "historyActiveVerse": [
      [43, 3, 16]
    ],
    "favouriteVerse": [
      [43, 3, 16]
    ],
  };

  // Variables to work with bibles
  String marvelData, activeVerseReference;
  FileMx fileMx;
  Map<String, List<String>> allBibles, allBiblesByLanguages = {};
  Bible bibleDB1, bibleDB2, bibleDB3, iBibleDB, tBibleDB, headingsDB;
  List<List<dynamic>> chapterData1, chapterData1Parallel, chapterData2;
  int activeScrollIndex1, activeScrollIndex2;
  BibleParser parser;

  // Functions to work with "settings" or preferences

  List<List<int>> convertListStringToListListInt(List<String> listString) =>
      listString
          .map((i) => i.split(".").map((i) => int.parse(i)).toList())
          .toList();

  List<String> convertListListIntToListString(List<List<int>> listListInt) =>
      [for (List<int> i in listListInt) i.join(".")];

  Future<void> setup() async {
    // Set up share preferences.
    await setDefault();
    // Set up bible parser
    parser = BibleParser(stringValues["abbreviations"]);
    // Set up bibles.
    await setupResources();
  }

  Future<void> setDefault() async {
    // Get an instance of SharedPreferences.
    prefs = await SharedPreferences.getInstance();
    // Clear all preferences ONLY for debug purpose
    //prefs.clear();

    // Preferences with bool values
    for (String key in boolValues.keys) {
      final bool storedValue = prefs.getBool(key);
      if (storedValue == null) {
        prefs.setBool(key, boolValues[key]);
      } else {
        boolValues[key] = storedValue;
      }
    }
    // Preferences with String values
    for (String key in stringValues.keys) {
      final String storedValue = prefs.getString(key);
      if (storedValue == null) {
        prefs.setString(key, stringValues[key]);
      } else {
        stringValues[key] = storedValue;
      }
    }
    // Preferences with int values
    for (String key in intValues.keys) {
      final int storedValue = prefs.getInt(key);
      if (storedValue == null) {
        prefs.setInt(key, intValues[key]);
      } else {
        intValues[key] = storedValue;
      }
    }
    // Preferences with double values
    for (String key in doubleValues.keys) {
      final double storedValue = prefs.getDouble(key);
      if (storedValue == null) {
        prefs.setDouble(key, doubleValues[key]);
      } else {
        doubleValues[key] = storedValue;
      }
    }
    // Preferences with List<String> values
    for (var key in listStringValues.keys) {
      final List<String> storedValue = prefs.getStringList(key);
      if (storedValue == null) {
        prefs.setStringList(key, listStringValues[key]);
      } else {
        listStringValues[key] = storedValue;
      }
    }
    // Preferences with List<String> values, converted from List<List<int>> values.
    for (var key in listListIntValues.keys) {
      final List<String> storedValue = prefs.getStringList(key);
      if (storedValue == null) {
        prefs.setStringList(
            key, convertListListIntToListString(listListIntValues[key]));
      } else {
        listListIntValues[key] = convertListStringToListListInt(storedValue);
      }
    }

    // Update text styles, colours, theme data
    updateTheme();
  }

  Future<void> changeWorkspaceLayout() async {
    int workspaceLayout = intValues["workspaceLayout"];
    if (workspaceLayout == 2) {
      workspaceLayout = 0;
    } else {
      workspaceLayout++;
    }
    await save("workspaceLayout", workspaceLayout);
  }

  Future<void> save(String feature, dynamic newSetting) async {
    if (stringValues.containsKey(feature)) {
      if (stringValues[feature] != newSetting) {
        stringValues[feature] = newSetting;
        await prefs.setString(feature, newSetting as String);
      }
    } else if (boolValues.containsKey(feature)) {
      if (boolValues[feature] != newSetting) {
        boolValues[feature] = newSetting;
        await prefs.setBool(feature, newSetting as bool);
      }
    } else if (doubleValues.containsKey(feature)) {
      if (doubleValues[feature] != newSetting) {
        doubleValues[feature] = newSetting;
        await prefs.setDouble(feature, newSetting as double);
        if (feature == "fontSize") updateTheme();
      }
    } else if (intValues.containsKey(feature)) {
      if (intValues[feature] != newSetting) {
        intValues[feature] = newSetting;
        await prefs.setInt(feature, newSetting as int);
        if (feature == "backgroundBrightness") updateTheme();
      }
    } else if (listStringValues.containsKey(feature)) {
      if (listStringValues[feature] != newSetting) {
        listStringValues[feature] = newSetting;
        await prefs.setStringList(feature, newSetting as List<String>);
      }
    } else if (listListIntValues.containsKey(feature)) {
      listListIntValues[feature] = newSetting;
      await prefs.setStringList(
          feature, convertListListIntToListString(newSetting));
    }
  }

  Future<void> add(String feature, List<dynamic> newItemDynamic) async {
    List<int> newItem = [for (dynamic i in newItemDynamic) i as int];
    switch (feature) {
      case "historyActiveVerse":
        List<List<int>> historyActiveVerse = listListIntValues[feature];
        if (newItem.join(".") != historyActiveVerse.first.join(".")) {
          historyActiveVerse.insert(0, newItem);
          if (historyActiveVerse.length > 20) historyActiveVerse.sublist(0, 20);
          await save(feature, historyActiveVerse);
          updateActiveVerseReference(newItem);
          updateActiveScrollIndex(newItem);
        }
        break;
      case "favouriteVerse":
        List<List<int>> favouriteVerse = listListIntValues[feature];
        if ((favouriteVerse.isEmpty) || (newItem.join(".") != favouriteVerse.first.join("."))) {
          // avoid duplication in favourite records:
          final int indexFound = favouriteVerse.indexOf(newItem);
          if (indexFound != -1) favouriteVerse.removeAt(indexFound);
          favouriteVerse.insert(0, newItem);
          if (favouriteVerse.length > 20) favouriteVerse.sublist(0, 20);
          await save(feature, favouriteVerse);
        }
        break;
    }
  }

  Future<void> remove(String feature, List<int> binItem) async {
    if (feature == "favouriteVerse") {
      List<List<int>> favouriteVerse = listListIntValues[feature];
      final int indexFound = favouriteVerse.indexOf(binItem);
      if (indexFound != -1) favouriteVerse.removeAt(indexFound);
      save(feature, favouriteVerse);
    }
  }

  // Text styles and colours

  // Run the following function when intValues["backgroundBrightness"] or doubleValues["fontSize"] is changed.
  void updateTheme() {
    Color backgroundColor, canvasColor, cardColor,
        blueAccent, indigo, black, blue, deepOrange, grey,
        appBarColor, floatingButtonColor, bottomAppBarColor,
        dropdownBackground, dropdownBorder, dropdownDisabled, dropdownEnabled;

    final int backgroundBrightness = intValues["backgroundBrightness"];
    // adjustment with changes of brightness
    backgroundColor = Colors.blueGrey[backgroundBrightness];

    if (backgroundBrightness >= 500) {
      canvasColor = Colors.blueGrey[backgroundBrightness - 200];
      cardColor = Colors.blueGrey[backgroundBrightness - 200];
      blueAccent = Colors.blueAccent[100];
      indigo = Colors.indigo[200];
      black = Colors.grey[300];
      blue = Colors.blue[300];
      deepOrange = Colors.deepOrange[300];
      grey = Colors.grey[400];
      appBarColor = Colors.blueGrey[backgroundBrightness - 200];
      floatingButtonColor = Colors.blueGrey[backgroundBrightness - 300];
      bottomAppBarColor = Colors.grey[500];
      dropdownBackground = Colors.blueGrey[backgroundBrightness - 200];
      dropdownBorder = Colors.grey[400];
      dropdownDisabled = Colors.blueAccent[100];
      dropdownEnabled = Colors.blueAccent[100];
    } else {
      canvasColor = Colors.blueGrey[backgroundBrightness];
      cardColor = Colors.grey[300];
      blueAccent = Colors.blue[700];
      indigo = Colors.indigo[700];
      black = Colors.black;
      blue = Colors.blueAccent[700];
      deepOrange = Colors.deepOrange[700];
      grey = Colors.grey[700];
      //appBarColor = Theme.of(context).appBarTheme.color;
      appBarColor = Colors.blue[600];
      floatingButtonColor = Colors.blue[600];
      bottomAppBarColor = Colors.grey[backgroundBrightness + 100];
      dropdownBackground = Colors.blueGrey[backgroundBrightness];
      dropdownBorder = Colors.grey[700];
      dropdownDisabled = Colors.blueAccent[700];
      dropdownEnabled = Colors.blueAccent[700];
    }

    // define a set of colors
    myColors = {
      "blueAccent": blueAccent,
      "indigo": indigo,
      "black": black,
      "blue": blue,
      "deepOrange": deepOrange,
      "grey": grey,
      "appBarColor": appBarColor,
      "floatingButtonColor": floatingButtonColor,
      "bottomAppBarColor": bottomAppBarColor,
      "background": backgroundColor,
      "canvasColor": canvasColor,
      "cardColor": cardColor,
      "dropdownBackground": dropdownBackground,
      "dropdownBorder": dropdownBorder,
      "dropdownDisabled": dropdownDisabled,
      "dropdownEnabled": dropdownEnabled,
    };

    // update various font text style here
    TextStyle verseNoFont =
        TextStyle(fontSize: (doubleValues["fontSize"] - 3), color: blueAccent, decoration: TextDecoration.underline),
    verseFont = TextStyle(fontSize: doubleValues["fontSize"], color: black),
    verseFontHebrew = TextStyle(
        fontFamily: "Ezra SIL",
        fontSize: (doubleValues["fontSize"] + 4),
        color: black),
    verseFontGreek =
        TextStyle(fontSize: (doubleValues["fontSize"] + 2), color: black),
    activeVerseNoFont = TextStyle(
        fontSize: (doubleValues["fontSize"] - 3),
        color: blue,
        fontWeight: FontWeight.bold),
    activeVerseFont =
        TextStyle(fontSize: doubleValues["fontSize"], color: indigo),
    activeVerseFontHebrew = TextStyle(
        fontFamily: "Ezra SIL",
        fontSize: (doubleValues["fontSize"] + 4),
        color: indigo),
    activeVerseFontGreek =
        TextStyle(fontSize: (doubleValues["fontSize"] + 2), color: indigo),
    interlinearStyle =
        TextStyle(fontSize: (doubleValues["fontSize"] - 3), color: deepOrange),
    interlinearStyleDim = TextStyle(
        fontSize: (doubleValues["fontSize"] - 3),
        color: grey,
        fontStyle: FontStyle.italic),
    subtitleStyle = TextStyle(
      fontSize: (doubleValues["fontSize"] - 4),
      color: (backgroundBrightness >= 700)
          ? Colors.grey[400]
          : grey,
    ),
    highlightStyle = TextStyle(
          fontWeight: FontWeight.bold,
          //fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        );

    // set the same font settings, which is passed to search delegate
    myTextStyle = {
      "HebrewFont": TextStyle(fontFamily: "Ezra SIL"),
      "verseNoFont": verseNoFont,
      "verseFont": verseFont,
      "verseFontHebrew": verseFontHebrew,
      "verseFontGreek": verseFontGreek,
      "activeVerseNoFont": activeVerseNoFont,
      "activeVerseFont": activeVerseFont,
      "activeVerseFontHebrew": activeVerseFontHebrew,
      "activeVerseFontGreek": activeVerseFontGreek,
      "interlinearStyle": interlinearStyle,
      "interlinearStyleDim": interlinearStyleDim,
      "subtitleStyle": subtitleStyle,
      "highlightStyle": highlightStyle,
    };

    mainTheme = ThemeData(
      //primaryColor: myColors["appBarColor"],
      appBarTheme: AppBarTheme(color: myColors["appBarColor"]),
      scaffoldBackgroundColor:
      Colors.blueGrey[intValues["backgroundBrightness"]],
      canvasColor: myColors["canvasColor"],
      unselectedWidgetColor: myColors["blue"],
      accentColor: myColors["blueAccent"],
      dividerColor: myColors["grey"],
      cardColor: myColors["cardColor"],
      /*chipTheme: ChipThemeData(
          backgroundColor: Colors.lightBlue,
      ),*/
      textTheme: TextTheme(
        bodyText1: verseFont,
        subtitle1: subtitleStyle,
      ),
    );

    dropdownUnderline = Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dropdownBorder))),
    );
  }

  static Future<void> goTo(BuildContext context, Widget widget) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => widget));
  }

  // Set up resources
  Future<void> setupResources() async {
    marvelData = await StorageMx.getUserDirectoryPath();
    fileMx = FileMx(marvelData);
    // pending: message to Android users for not granting storage permission
    // copied required resources for loading
    await copyAssetsResources();

    await setupBibles();
  }

  // Bibles-related functions

  Future<void> setupBibles() async {
    final Map<String, String> bibleFiles = await checkInstalledBibles();
    allBibles = {for (MapEntry i in bibleFiles.entries) basenameWithoutExtension(i.key): [(extension(i.key).isNotEmpty) ? extension(i.key) : "en", await getBibleInfo(i.value), i.value]};
    allBibles.forEach((k, v) => allBiblesByLanguages[v.first] = (allBiblesByLanguages.containsKey(v.first) ? [...allBiblesByLanguages[v.first], ...[k]] : [k]));
    // Load bible databases.
    final List<int> activeVerse = listListIntValues["historyActiveVerse"].first;
    await openBibleDatabase();
    await updateBCVMenu(activeVerse);
    await updateDBChapterData(activeVerse);
    updateActiveVerseReference(activeVerse);
    updateActiveScrollIndex(activeVerse);
  }

  Future<void> newVerseSelected(List<dynamic> bcvList) async {
    final List<int> activeVerse = listListIntValues["historyActiveVerse"].first;
    if (bcvList.sublist(0, 3).join(".") != activeVerse.sublist(0, 3).join(".")) {
      if (bcvList.sublist(0, 2).join(".") != activeVerse.sublist(0, 2).join(".")) {
        await updateBCVMenu(bcvList);
        await updateDBChapterData(bcvList);
      }
      await add("historyActiveVerse", bcvList);
    }
  }

  Future<void> openBibleDatabase() async {
    await openBibleDB1();
    await openBibleDB2();
  }

  Future<void> openBibleDB1({String module = ""}) async {
    await bibleDB1?.db?.close();
    final String bible = (module.isEmpty) ? stringValues["bible1"] : module;
    bibleDB1 = Bible(bible, allBibles[bible].last, fileMx);
    await bibleDB1.openDatabase();
    if (module.isNotEmpty) await save("bible1", module);
  }

  Future<void> openBibleDB2({String module = ""}) async {
    await bibleDB2?.db?.close();
    final String bible = (module.isEmpty) ? stringValues["bible2"] : module;
    bibleDB2 = Bible(bible, allBibles[bible].last, fileMx);
    await bibleDB2.openDatabase();
    if (module.isNotEmpty) await save("bible2", module);
  }

  Future<void> swapBibles() async {
    final Bible tempBible = bibleDB1;
    bibleDB1 = bibleDB2;
    bibleDB2 = tempBible;

    // update preferences
    await save("bible1", bibleDB1.module);
    await save("bible2", bibleDB2.module);

    // Update chapter data for display
    updateDisplayChapterData();

    final List<int> activeVerse = listListIntValues["historyActiveVerse"].first;
    updateActiveScrollIndex(activeVerse);
  }

  Future<void> updateBCVMenu(List<int> activeVerse) async {
    // Update bibleDB1
    await bibleDB1.updateBCVMenu(activeVerse);
    // Update bibleDB2
    await bibleDB2.updateBCVMenu(activeVerse);
  }

  void restoreMenuBookChapter() {
    final List<int> activeVerse = listListIntValues["historyActiveVerse"].first;
    bibleDB1.menuBook = activeVerse.first;
    bibleDB1.menuChapter = activeVerse[1];
  }

  Future<void> updateDBChapterData(List<int> activeVerse) async {
    // Update bibleDB1
    await bibleDB1.updateChapterData(activeVerse);
    // Update bibleDB2
    await bibleDB2.updateChapterData(activeVerse);

    // Update chapter data for display
    updateDisplayChapterData();
  }

  void updateDisplayChapterData() {
    // Setup chapterData1Parallel
    int vs1 = bibleDB1.verseList.first;
    int ve1 = bibleDB1.verseList.last;

    int vs2 = bibleDB2.verseList.first;
    int ve2 = bibleDB2.verseList.last;

    int vs, ve;
    vs = (vs1 <= vs2) ? vs1 : vs2;
    ve = (ve1 >= ve2) ? ve1 : ve2;

    chapterData1Parallel = [];
    for (var i = vs; i <= ve; i++) {
      int indexInBibleDB1 = bibleDB1.verseList.indexOf(i);
      if (indexInBibleDB1 != -1) chapterData1Parallel.add(bibleDB1.chapterData[indexInBibleDB1]);
      int indexInBibleDB2 = bibleDB2.verseList.indexOf(i);
      if (indexInBibleDB2 != -1) chapterData1Parallel.add(bibleDB2.chapterData[indexInBibleDB2]);
    }

    // chapterData1 changes when users turn on or off parallel verses.
    chapterData1 = (boolValues["parallelVerses"]) ? chapterData1Parallel : bibleDB1.chapterData;
    // chapterData2 always use secondary bible data.
    chapterData2 = bibleDB2.chapterData;
  }

  void updateParserAbbreviations() => parser.updateAbbreviations(stringValues["abbreviations"]);
  void updateActiveVerseReference(List<int> activeVerse) => activeVerseReference = parser.bcvToVerseReference(activeVerse.sublist(0, 3));

  void updateActiveScrollIndex(List<int> activeVerse) {
    // useful references on finding index
    // https://api.flutter.dev/flutter/dart-core/Iterable/firstWhere.html
    // https://fireship.io/snippets/dart-how-to-get-the-index-on-array-loop-map/
    // https://coflutter.com/dart-how-to-find-an-item-in-a-list/
    // Note that lists cannot be tested for equality.
    // Therefore, cannot use (data.first == activeVerse.sublist(0, 3)) for test.
    final int activeVerseIndex1 = chapterData1.indexWhere((data) => data.first.join(".") == activeVerse.sublist(0, 3).join("."));
    activeScrollIndex1 = (activeVerseIndex1 == -1) ? 0 : activeVerseIndex1;
    final int activeVerseIndex2 = chapterData2.indexWhere((data) => data.first.join(".") == activeVerse.sublist(0, 3).join("."));
    activeScrollIndex2 = (activeVerseIndex2 == -1) ? 0 : activeVerseIndex2;
  }

  Future<String> getBibleInfo(String fullPath) async {
    final String query = "SELECT Scripture FROM Verses WHERE Book=0 AND Chapter=0 AND Verse=0";
    final List<Map<String, dynamic>> results = await fileMx.querySqliteDB("FULLPATH", fullPath, query, []);
    return (results.isNotEmpty) ? results.first["Scripture"] : "";
  }

  Future<void> copyAssetsResources() async {
    Map<String, List<String>> resources = {
      "bibles": ["KJV.bible", "NET.bible"],
    };
    for (String resource in resources.keys) {
      resources[resource].forEach((filename) async {
        await fileMx.copyAssetsFileToUserDirectory(resource, filename);
      });
    }
  }

  Future<Map<String, String>> checkInstalledBibles() async {
    final String biblesFolder = await fileMx.getUserDirectoryFolder("bibles");
    return fileMx.getDirectoryItems(biblesFolder, filter: ".bible");
  }

  void updateMultipleVersesShowVersion(bool value) => multipleVersesShowVersion = value;
  void updateMultipleVersesData(List<List<dynamic>> data) {
    multipleVersesData = data;
    multipleVersesDataLazy = (multipleVersesData.length > searchItemsPerPage) ? [...multipleVersesData.sublist(0, searchItemsPerPage), []] : multipleVersesData;
  }
  void updateMultipleVersesDataLazy() {
    int currentLazyItemsNo = multipleVersesDataLazy.length - 1;
    int currentLazyItemsMoreNo = currentLazyItemsNo + searchItemsPerPage;
    multipleVersesDataLazy = (multipleVersesData.length > currentLazyItemsMoreNo)
        ? [...multipleVersesData.sublist(0, currentLazyItemsMoreNo), []] : multipleVersesData;
  }

}
