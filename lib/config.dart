import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'module_description.dart';

class Config {

  Config() {
    compareBibleList = ModuleDescription().compareBibleList;
  }

  SharedPreferences prefs;
  ThemeData mainTheme;
  Map myColors, verseTextStyle;
  List<String> compareBibleList;

  // Default values are assigned to some variables.

  bool bigScreen = false, showNotes = false, showFlags = false, showPinyin = false, showTransliteration = false, showDrawer = true, showHeadingVerseNo = false, alwaysOpenMarvelBibleExternally = false;
  String abbreviations = "ENG", bible1 = "KJV", bible2 = "NET", iBible = "OHGBi", marvelBible = "MAB", marvelCommentary = "cCBSC", ttsChinese = "zh-CN", ttsEnglish = "en-GB", ttsGreek = "modern";
  List<List<int>> historyActiveVerse = [[43, 3, 16]], favouriteVerse = [[43, 3, 16]];
  double fontSize = 20.0, morphologyVersion = 0.0, lexiconVersion = 0.0, toolsVersion = 0.0, speechRate = (Platform.isAndroid) ? 1.0 : 0.5;
  int instantAction = 0, favouriteAction = 1, backgroundColor = 0;

  // Functions to work with "settings" or preferences

  void updateThemeData() {
    if (myColors != null) {
      mainTheme = ThemeData(
        //primaryColor: myColors["appBarColor"],
        appBarTheme: AppBarTheme(color: myColors["appBarColor"]),
        scaffoldBackgroundColor: Colors.blueGrey[backgroundColor],
        unselectedWidgetColor: myColors["blue"],
        accentColor: myColors["blueAccent"],
        dividerColor: myColors["grey"],
        cardColor: (backgroundColor >= 500)
            ? myColors["appBarColor"]
            : Colors.grey[300],
      );
    }
  }

  List<List<int>> convertVerseStringToIntList(List<String> verseStringList) => verseStringList.map((i) => i.split(".").map((i) => int.parse(i)).toList()).toList();

  Future setDefault() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("bigScreen") == null) {
      prefs.setBool("bigScreen", bigScreen);
    } else {
      bigScreen = prefs.getBool("bigScreen");
    }
    if (prefs.getBool("showNotes") == null) {
      prefs.setBool("showNotes", showNotes);
    } else {
      showNotes = prefs.getBool("showNotes");
    }
    if (prefs.getBool("showPinyin") == null) {
      prefs.setBool("showPinyin", showPinyin);
    } else {
      showPinyin = prefs.getBool("showPinyin");
    }
    if (prefs.getBool("showTransliteration") == null) {
      prefs.setBool("showTransliteration", showTransliteration);
    } else {
      showTransliteration = prefs.getBool("showTransliteration");
    }
    if (prefs.getBool("showFlags") == null) {
      prefs.setBool("showFlags", showFlags);
    } else {
      showFlags = prefs.getBool("showFlags");
    }
    if (prefs.getBool("showDrawer") == null) {
      prefs.setBool("showDrawer", showDrawer);
    } else {
      showDrawer = prefs.getBool("showDrawer");
    }
    if (prefs.getBool("showHeadingVerseNo") == null) {
      prefs.setBool("showHeadingVerseNo", showHeadingVerseNo);
    } else {
      showHeadingVerseNo = prefs.getBool("showHeadingVerseNo");
    }
    if (prefs.getBool("alwaysOpenMarvelBibleExternally") == null) {
      prefs.setBool("alwaysOpenMarvelBibleExternally", alwaysOpenMarvelBibleExternally);
    } else {
      alwaysOpenMarvelBibleExternally = prefs.getBool("alwaysOpenMarvelBibleExternally");
    }
    if (prefs.getDouble("fontSize") == null) {
      prefs.setDouble("fontSize", fontSize);
    } else {
      fontSize = prefs.getDouble("fontSize");
    }
    if (prefs.getString("abbreviations") == null) {
      prefs.setString("abbreviations", abbreviations);
    } else {
      abbreviations = prefs.getString("abbreviations");
    }
    if (prefs.getString("bible1") == null) {
      prefs.setString("bible1", bible1);
    } else {
      bible1 = prefs.getString("bible1");
    }
    if (prefs.getString("bible2") == null) {
      prefs.setString("bible2", bible2);
    } else {
      bible2 = prefs.getString("bible2");
    }
    if (prefs.getString("marvelBible") == null) {
      prefs.setString("marvelBible", marvelBible);
    } else {
      marvelBible = prefs.getString("marvelBible");
    }
    if (prefs.getString("marvelCommentary") == null) {
      prefs.setString("marvelCommentary", marvelCommentary);
    } else {
      marvelCommentary = prefs.getString("marvelCommentary");
    }
    if (prefs.getString("iBible") == null) {
      prefs.setString("iBible", iBible);
    } else {
      iBible = prefs.getString("iBible");
    }
    if (prefs.getString("ttsChinese") == null) {
      prefs.setString("ttsChinese", ttsChinese);
    } else {
      ttsChinese = prefs.getString("ttsChinese");
    }
    if (prefs.getString("ttsEnglish") == null) {
      prefs.setString("ttsEnglish", ttsEnglish);
    } else {
      ttsEnglish = prefs.getString("ttsEnglish");
    }
    if (prefs.getString("ttsGreek") == null) {
      prefs.setString("ttsGreek", ttsGreek);
    } else {
      ttsGreek = prefs.getString("ttsGreek");
    }
    if (prefs.getStringList("historyActiveVerse") == null) {
      prefs.setStringList("historyActiveVerse", ["43.3.16"]);
    } else {
      historyActiveVerse = convertVerseStringToIntList(prefs.getStringList("historyActiveVerse"));
    }
    if (prefs.getStringList("favouriteVerse") == null) {
      prefs.setStringList("favouriteVerse", ["43.3.16"]);
    } else {
      favouriteVerse = convertVerseStringToIntList(prefs.getStringList("favouriteVerse"));
    }
    if (prefs.getDouble("morphologyVersion") == null) {
      prefs.setDouble("morphologyVersion", morphologyVersion);
    } else {
      morphologyVersion = prefs.getDouble("morphologyVersion");
    }
    if (prefs.getDouble("lexiconVersion") == null) {
      prefs.setDouble("lexiconVersion", lexiconVersion);
    } else {
      lexiconVersion = prefs.getDouble("lexiconVersion");
    }
    if (prefs.getDouble("toolsVersion") == null) {
      prefs.setDouble("toolsVersion", toolsVersion);
    } else {
      toolsVersion = prefs.getDouble("toolsVersion");
    }
    if (prefs.getDouble("speechRate") == null) {
      prefs.setDouble("speechRate", speechRate);
    } else {
      speechRate = prefs.getDouble("speechRate");
    }
    if (prefs.getStringList("compareBibleList") == null) {
      prefs.setStringList("compareBibleList", compareBibleList);
    } else {
      compareBibleList = prefs.getStringList("compareBibleList");
    }
    if (prefs.getInt("favouriteAction") == null) {
      prefs.setInt("favouriteAction", favouriteAction);
    } else {
      favouriteAction = prefs.getInt("favouriteAction");
    }
    if (prefs.getInt("instantAction") == null) {
      prefs.setInt("instantAction", instantAction);
    } else {
      instantAction = prefs.getInt("instantAction");
    }
    if (prefs.getInt("backgroundColor") == null) {
      prefs.setInt("backgroundColor", backgroundColor);
    } else {
      backgroundColor = prefs.getInt("backgroundColor");
    }

    return true;
  }

  Future save(String feature, dynamic newSetting) async {
    switch (feature) {
      case "bigScreen":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showNotes":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showPinyin":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showTransliteration":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showFlags":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showDrawer":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "showHeadingVerseNo":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "alwaysOpenMarvelBibleExternally":
        await prefs.setBool(feature, newSetting as bool);
        break;
      case "fontSize":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "abbreviations":
        await prefs.setString(feature, newSetting as String);
        break;
      case "bible1":
        await prefs.setString(feature, newSetting as String);
        break;
      case "bible2":
        await prefs.setString(feature, newSetting as String);
        break;
      case "marvelBible":
        await prefs.setString(feature, newSetting as String);
        break;
      case "marvelCommentary":
        await prefs.setString(feature, newSetting as String);
        break;
      case "iBible":
        await prefs.setString(feature, newSetting as String);
        break;
      case "ttsChinese":
        await prefs.setString(feature, newSetting as String);
        break;
      case "ttsEnglish":
        await prefs.setString(feature, newSetting as String);
        break;
      case "ttsGreek":
        await prefs.setString(feature, newSetting as String);
        break;
      case "morphologyVersion":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "lexiconVersion":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "toolsVersion":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "speechRate":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "compareBibleList":
        await prefs.setStringList(feature, newSetting as List<String>);
        break;
      case "favouriteAction":
        await prefs.setInt(feature, newSetting as int);
        break;
      case "instantAction":
        await prefs.setInt(feature, newSetting as int);
        break;
      case "backgroundColor":
        await prefs.setInt(feature, newSetting as int);
        break;
    }

    return true;
  }

  Future<void> add(String feature, List<int> newItem) async {
    switch (feature) {
      case "historyActiveVerse":
        List<String> tempHistoryActiveVerse = prefs.getStringList("historyActiveVerse");
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
