import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'module_description.dart';

class Config {

  SharedPreferences prefs;
  ThemeData mainTheme;
  Map<String, TextStyle> verseTextStyle;
  Map<String, Color> myColors;

  // Default values are assigned to some variables.

  // Default bool values.
  Map<String, bool> boolValues = {
    "bigScreen": false,
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
    "instantAction": 0,
    "favouriteAction": 1,
    "backgroundColor": 0,
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

  void updateThemeData() {
    if (myColors != null) {
      mainTheme = ThemeData(
        //primaryColor: myColors["appBarColor"],
        appBarTheme: AppBarTheme(color: myColors["appBarColor"]),
        scaffoldBackgroundColor: Colors.blueGrey[intValues["backgroundColor"]],
        unselectedWidgetColor: myColors["blue"],
        accentColor: myColors["blueAccent"],
        dividerColor: myColors["grey"],
        cardColor: (intValues["backgroundColor"] >= 500)
            ? myColors["appBarColor"]
            : Colors.grey[300],
      );
    }
  }

  List<List<int>> convertListStringToListListInt(List<String> listString) =>
      listString
          .map((i) => i.split(".").map((i) => int.parse(i)).toList())
          .toList();

  List<String> convertListListIntToListString(List<List<int>> listListInt) =>
      listListInt.map((i) => i.join(".")).toList();

  Future<void> setDefault() async {
    // Get an instance of SharedPreferences.
    prefs = await SharedPreferences.getInstance();

    // Preferences with bool values
    for (String key in boolValues.keys) {
      final bool storedValue = prefs.getBool("bigScreen");
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
    // Preferences with String values
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
        prefs.setStringList(key, convertListListIntToListString(listListIntValues[key]));
      } else {
        listListIntValues[key] = convertListStringToListListInt(storedValue);
      }
    }
  }

  Future<void> save(String feature, dynamic newSetting) async {
    if (stringValues.containsKey(feature)) {
      await prefs.setString(feature, newSetting as String);
    } else if (boolValues.containsKey(feature)) {
      await prefs.setBool(feature, newSetting as bool);
    } else if (doubleValues.containsKey(feature)) {
      await prefs.setDouble(feature, newSetting as double);
    } else if (doubleValues.containsKey(feature)) {
      await prefs.setInt(feature, newSetting as int);
    } else if (listStringValues.containsKey(feature)) {
      await prefs.setStringList(feature, newSetting as List<String>);
    }
  }

  Future<void> add(String feature, List<int> newItem) async {
    switch (feature) {
      case "historyActiveVerse":
        List<String> tempHistoryActiveVerse =
            prefs.getStringList("historyActiveVerse");
        final String newAddition = newItem.join(".");
        if (tempHistoryActiveVerse[0] != newAddition) {
          tempHistoryActiveVerse.insert(0, newAddition);
          // set limitations for the number of history records
          if (tempHistoryActiveVerse.length > 20)
            tempHistoryActiveVerse = tempHistoryActiveVerse.sublist(0, 20);
          await prefs.setStringList(
              "historyActiveVerse", tempHistoryActiveVerse);
        }
        break;
      case "favouriteVerse":
        List<String> tempFavouriteVerse = prefs.getStringList("favouriteVerse");
        final String newAddition = newItem.join(".");
        if ((tempFavouriteVerse.isEmpty) ||
            (tempFavouriteVerse[0] != newAddition)) {
          // avoid duplication in favourite records:
          int indexFound = tempFavouriteVerse.indexOf(newAddition);
          if (indexFound != -1) tempFavouriteVerse.removeAt(indexFound);
          tempFavouriteVerse.insert(0, newAddition);
          // set limitations for the number of history records
          if (tempFavouriteVerse.length > 20)
            tempFavouriteVerse = tempFavouriteVerse.sublist(0, 20);
          await prefs.setStringList("favouriteVerse", tempFavouriteVerse);
        }
        break;
    }
  }

  Future<void> remove(String feature, List<int> newItem) async {
    if (feature == "favouriteVerse") {
      final String newAddition = newItem.join(".");
      List<String> tempFavouriteVerse = prefs.getStringList("favouriteVerse");
      final int indexFound = tempFavouriteVerse.indexOf(newAddition);
      if (indexFound != -1) tempFavouriteVerse.removeAt(indexFound);
      await prefs.setStringList("favouriteVerse", tempFavouriteVerse);
    }
  }
}
