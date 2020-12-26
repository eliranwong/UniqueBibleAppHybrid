// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Core libraries
import 'dart:io';
// My libraries
import 'module_description.dart';

final configurationsProvider = FutureProvider<Configurations>((ref) async {
  final Configurations configurations = Configurations();
  await configurations.setDefault();
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
            (ref) => ref.watch(configProvider).state.stringValues["bigScreen"]),
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
    showWorkspaceP = StateProvider<int>(
            (ref) => ref.watch(configProvider).state.intValues["showWorkspace"]),
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

class Configurations {
  SharedPreferences prefs;

  // The following variables change when intValues["backgroundBrightness"] or doubleValues["fontSize"] changes.
  ThemeData mainTheme;
  Map<String, TextStyle> myTextStyle;
  Map<String, Color> myColors;
  Container dropdownUnderline;

  // Default values.

  // Default bool values.
  Map<String, bool> boolValues = {
    "bigScreen": true,
    "showNotes": false,
    "showFlags": false,
    "showPinyin": false,
    "showTransliteration": false,
    "showDrawer": true,
    "showHeadingVerseNo": false,
    "alwaysOpenMarvelBibleExternally": false,
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
    "showWorkspace": 0,
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

  // Functions to work with "settings" or preferences

  List<List<int>> convertListStringToListListInt(List<String> listString) =>
      listString
          .map((i) => i.split(".").map((i) => int.parse(i)).toList())
          .toList();

  List<String> convertListListIntToListString(List<List<int>> listListInt) =>
      [for (List<int> i in listListInt) i.join(".")];
  // same as listListInt.map((i) => i.join(".")).toList()

  Future<void> setDefault() async {
    // Get an instance of SharedPreferences.
    prefs = await SharedPreferences.getInstance();

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

    print("Settings are ready!");
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
      if (listListIntValues[feature] != newSetting) {
        listListIntValues[feature] = newSetting;
        await prefs.setStringList(
            feature, convertListListIntToListString(newSetting));
      }
    }
  }

  Future<void> add(String feature, List<int> newItem) async {
    switch (feature) {
      case "historyActiveVerse":
        List<List<int>> historyActiveVerse = listListIntValues[feature];
        if (newItem != historyActiveVerse.first) {
          historyActiveVerse.insert(0, newItem);
          if (historyActiveVerse.length > 20) historyActiveVerse.sublist(0, 20);
          save(feature, historyActiveVerse);
        }
        break;
      case "favouriteVerse":
        List<List<int>> favouriteVerse = listListIntValues[feature];
        if ((favouriteVerse.isEmpty) || (newItem != favouriteVerse.first)) {
          // avoid duplication in favourite records:
          final int indexFound = favouriteVerse.indexOf(newItem);
          if (indexFound != -1) favouriteVerse.removeAt(indexFound);
          favouriteVerse.insert(0, newItem);
          if (favouriteVerse.length > 20) favouriteVerse.sublist(0, 20);
          save(feature, favouriteVerse);
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
        TextStyle(fontSize: (doubleValues["fontSize"] - 3), color: blueAccent),
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

}
