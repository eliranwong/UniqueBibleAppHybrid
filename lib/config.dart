// Packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Library
import 'module_description.dart';

final configProvider = StateNotifierProvider((ref) => Config());

class Config extends StateNotifier<Configurations> {

  Config() : super(Configurations());

  void updateThemeData() => state.updateThemeData();
  //Future<void> setDefault() async => await state.setDefault();
  Future<void> save(String feature, dynamic newSetting) async => state.save(feature, newSetting);
  Future<void> add(String feature, List<int> newItem) async => state.add(feature, newItem);
  Future<void> remove(String feature, List<int> newItem) async => state.remove(feature, newItem);

}

class Configurations {

  Configurations() {
    setDefault();
  }

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
      [for (List<int> i in listListInt) i.join(".")];
  // same as listListInt.map((i) => i.join(".")).toList()

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
        prefs.setStringList(key, convertListListIntToListString(listListIntValues[key]));
      } else {
        listListIntValues[key] = convertListStringToListListInt(storedValue);
      }
    }

    print("Settings are ready!");
  }

  Future<void> save(String feature, dynamic newSetting) async {
    if (stringValues.containsKey(feature)) {
      stringValues[feature] = newSetting;
      await prefs.setString(feature, newSetting as String);
    } else if (boolValues.containsKey(feature)) {
      boolValues[feature] = newSetting;
      await prefs.setBool(feature, newSetting as bool);
    } else if (doubleValues.containsKey(feature)) {
      doubleValues[feature] = newSetting;
      await prefs.setDouble(feature, newSetting as double);
    } else if (intValues.containsKey(feature)) {
      intValues[feature] = newSetting;
      await prefs.setInt(feature, newSetting as int);
    } else if (listStringValues.containsKey(feature)) {
      listStringValues[feature] = newSetting;
      await prefs.setStringList(feature, newSetting as List<String>);
    } else if (listListIntValues.containsKey(feature)) {
      listListIntValues[feature] = newSetting;
      await prefs.setStringList(feature, convertListListIntToListString(newSetting));
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

}
