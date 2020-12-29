import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'config.dart';
import 'app_translation.dart';

class BibleSettings extends StatelessWidget {

  @override
  build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<String> interface =
            AppTranslation.interfaceBibleSettings[watch(abbreviationsP).state];
        return Theme(
          data: watch(mainThemeP).state,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: watch(myColorsP).state["background"],
              title: Text(interface[0]),
            ),
            body: _bibleSettings(context, interface),
          ),
        );
      },
    );
  }

  Widget _bibleSettings(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        return Container(
          color: Colors.blueGrey[watch(backgroundBrightnessP).state],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: <Widget>[
                _abbreviations(context, interface),
                const Divider(),
                ..._backgroundBrightness(context, interface),
                ..._fontSize(context, interface),
                const Divider(),
                _keepDrawerOpen(context, interface),
                const Divider(),
                _instantAction(context, interface),
                _favouriteAction(context, interface),
                const Divider(),
                ..._ttsOptions(context, interface),
                const Divider(),
                ..._marvelBibleOptions(context, interface),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _abbreviations(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final String abbreviations = watch(abbreviationsP).state;
        final Map<String, String> interfaceMap = {
          "English": "ENG",
          "繁體中文": "TC",
          "简体中文": "SC"
        };
        final Map<String, String> interfaceMapReverse = {
          "ENG": "English",
          "TC": "繁體中文",
          "SC": "简体中文"
        };
        return ListTile(
          title:
              Text(interface[1], style: Theme.of(context).textTheme.bodyText1),
          trailing: DropdownButton<String>(
            style: Theme.of(context).textTheme.bodyText1,
            underline: watch(dropdownUnderlineP).state,
            iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
            iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
            value: interfaceMapReverse[abbreviations],
            onChanged: (String newValue) {
              String newValueAbb = interfaceMap[newValue];
              if (newValueAbb != abbreviations) {
                context
                    .read(configProvider)
                    .state
                    .save("abbreviations", newValueAbb);
                context.refresh(abbreviationsP);
              }
            },
            items: <String>[...interfaceMap.keys.toList()]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _backgroundBrightness(
      BuildContext context, List<String> interface) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          return Text(interface[11],
              style: Theme.of(context).textTheme.bodyText1);
        },
      ),
      Consumer(builder: (context, watch, child) {
        final double backgroundBrightnessDouble =
            watch(backgroundBrightnessP).state.toDouble();
        return Slider(
          activeColor: watch(myColorsP).state["blueAccent"],
          value: backgroundBrightnessDouble,
          max: 900.0,
          divisions: 9,
          label: backgroundBrightnessDouble.round().toString(),
          onChanged: (double newValue) async {
            if (newValue != backgroundBrightnessDouble) {
              final int newValueInt = newValue.round();
              await context
                  .read(configProvider)
                  .state
                  .save("backgroundBrightness", newValueInt);
              context.refresh(backgroundBrightnessP);
              context.refresh(mainThemeP);
              context.refresh(myColorsP);
              context.refresh(myTextStyleP);
              context.refresh(dropdownUnderlineP);
            }
          },
        );
      }),
    ];
  }

  List<Widget> _fontSize(BuildContext context, List<String> interface) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          return Text(interface[6],
              style: Theme.of(context).textTheme.bodyText1);
        },
      ),
      Consumer(builder: (context, watch, child) {
        final double fontSize = watch(fontSizeP).state;
        return Slider(
          activeColor: watch(myColorsP).state["blueAccent"],
          value: fontSize,
          min: 7.0,
          max: 40.0,
          divisions: 33,
          onChanged: (double newValue) async {
            if (newValue != fontSize) {
              await context.read(configProvider).state.save("fontSize", newValue);
              context.refresh(fontSizeP);
              context.refresh(mainThemeP);
              context.refresh(myColorsP);
              context.refresh(myTextStyleP);
              context.refresh(dropdownUnderlineP);
            }
          },
        );
      }),
    ];
  }

  Widget _keepDrawerOpen(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool keepDrawerOpen = watch(keepDrawerOpenP).state;
        return ListTile(
          title:
              Text(interface[24], style: Theme.of(context).textTheme.bodyText1),
          trailing: Switch(
              value: keepDrawerOpen,
              onChanged: (bool newValue) {
                if (newValue != keepDrawerOpen) {
                  context
                      .read(configProvider)
                      .state
                      .save("keepDrawerOpen", newValue);
                  context.refresh(keepDrawerOpenP);
                }
              }),
        );
      },
    );
  }

  Widget _instantAction(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, List<String>> _instantActionMap = {
          "ENG": ["---", "Tips", "Interlinear"],
          "TC": ["---", "提示", "原文逐字翻譯"],
          "SC": ["---", "提示", "原文逐字翻译"],
        };
        final List<String> _instantActionList =
            _instantActionMap[watch(abbreviationsP).state];
        final int instantAction = watch(instantActionP).state;
        final String instantActionDescription =
            _instantActionList[instantAction];
        return ListTile(
          title:
              Text(interface[9], style: Theme.of(context).textTheme.bodyText1),
          trailing: DropdownButton<String>(
            style: Theme.of(context).textTheme.bodyText1,
            underline: watch(dropdownUnderlineP).state,
            iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
            iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
            value: instantActionDescription,
            onChanged: (String newValue) {
              if (newValue != instantActionDescription) {
                final int newInstantAction =
                    _instantActionList.indexOf(newValue);
                context
                    .read(configProvider)
                    .state
                    .save("instantAction", newInstantAction);
                context.refresh(instantActionP);
              }
            },
            items: <String>[..._instantActionList]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _favouriteAction(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final List<String> _favouriteActionList = AppTranslation
            .interfaceDialog[watch(abbreviationsP).state]
            .sublist(4);
        _favouriteActionList.insert(0, "---");
        final int favouriteAction = watch(favouriteActionP).state;
        final String favouriteActionDescription =
            _favouriteActionList[favouriteAction];
        return ListTile(
          title: Text(
            interface[8],
            style: Theme.of(context).textTheme.bodyText1,
          ),
          trailing: DropdownButton<String>(
            style: Theme.of(context).textTheme.bodyText1,
            underline: watch(dropdownUnderlineP).state,
            iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
            iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
            value: favouriteActionDescription,
            onChanged: (String newValue) {
              if (newValue != favouriteActionDescription) {
                final int newFavouriteAction =
                    _favouriteActionList.indexOf(newValue);
                context
                    .read(configProvider)
                    .state
                    .save("favouriteAction", newFavouriteAction);
                context.refresh(favouriteActionP);
              }
            },
            items: <String>[..._favouriteActionList]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _ttsOptions(BuildContext context, List<String> interface) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          return ListTile(
            title: Text(
              interface[14],
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: IconButton(
              tooltip: interface[15],
              icon: Icon(Icons.settings_backup_restore,
                  color: watch(myColorsP).state["blueAccent"]),
              onPressed: () {
                context
                    .read(configProvider)
                    .state
                    .save("speechRate", (Platform.isAndroid) ? 1.0 : 0.5);
                context.refresh(speechRateP);
              },
            ),
          );
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final double speechRate = watch(speechRateP).state;
          return Slider(
            activeColor: watch(myColorsP).state["blueAccent"],
            value: speechRate,
            min: 0.1,
            max: (Platform.isAndroid) ? 3.0 : 1.0,
            onChanged: (newValue) {
              if (newValue != speechRate) {
                context.read(configProvider).state.save("speechRate", newValue);
                context.refresh(speechRateP);
              }
            },
          );
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final String ttsEnglish = watch(ttsEnglishP).state;
          return ListTile(
            title: Text(interface[12],
                style: Theme.of(context).textTheme.bodyText1),
            trailing: DropdownButton<String>(
              style: Theme.of(context).textTheme.bodyText1,
              underline: watch(dropdownUnderlineP).state,
              iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
              iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
              value: ttsEnglish,
              onChanged: (String newValue) {
                if (newValue != ttsEnglish) {
                  context
                      .read(configProvider)
                      .state
                      .save("ttsEnglish", newValue);
                  context.refresh(ttsEnglishP);
                }
              },
              items: <String>["en-GB", "en-US"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final String ttsChinese = watch(ttsChineseP).state;
          return ListTile(
            title: Text(interface[13],
                style: Theme.of(context).textTheme.bodyText1),
            trailing: DropdownButton<String>(
              style: Theme.of(context).textTheme.bodyText1,
              underline: watch(dropdownUnderlineP).state,
              iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
              iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
              value: ttsChinese,
              onChanged: (String newValue) {
                if (newValue != ttsChinese) {
                  context
                      .read(configProvider)
                      .state
                      .save("ttsChinese", newValue);
                  context.refresh(ttsChineseP);
                }
              },
              items: <String>[
                "zh-CN",
                (Platform.isAndroid) ? "yue-HK" : "zh-HK"
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _marvelBibleOptions(
      BuildContext context, List<String> interface) {
    return <Widget>[
      Consumer(
        builder: (context, watch, child) {
          final bool alwaysOpenMarvelBibleExternallyValue =
              watch(alwaysOpenMarvelBibleExternallyP).state;
          return ListTile(
            title: Text(interface[22],
                style: Theme.of(context).textTheme.bodyText1),
            trailing: Switch(
                value: alwaysOpenMarvelBibleExternallyValue,
                onChanged: (bool newValue) {
                  if (newValue != alwaysOpenMarvelBibleExternallyValue) {
                    context
                        .read(configProvider)
                        .state
                        .save("alwaysOpenMarvelBibleExternally", newValue);
                    context.refresh(alwaysOpenMarvelBibleExternallyP);
                  }
                }),
          );
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final Map<String, String> marvelBibles = {
            "MAB": "Annotated",
            "MIB": "Interlinear",
            "MOB": "Original",
            "MPB": "Parallel",
            "MTB": "Trilingual",
          };
          final Map<String, String> marvelBiblesReverse = {
            "Annotated": "MAB",
            "Interlinear": "MIB",
            "Original": "MOB",
            "Parallel": "MPB",
            "Trilingual": "MTB",
          };
          final String marvelBible = marvelBibles[watch(marvelBibleP).state];
          return ListTile(
            title: Text(interface[19],
                style: Theme.of(context).textTheme.bodyText1),
            subtitle: Text("Marvel $marvelBible Bible",
                style: Theme.of(context).textTheme.subtitle1),
            trailing: DropdownButton<String>(
              style: Theme.of(context).textTheme.bodyText1,
              underline: watch(dropdownUnderlineP).state,
              iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
              iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
              value: marvelBible,
              onChanged: (String newValue) {
                if (newValue != marvelBible) {
                  context
                      .read(configProvider)
                      .state
                      .save("marvelBible", marvelBiblesReverse[newValue]);
                  context.refresh(marvelBibleP);
                }
              },
              items: <String>[
                "Annotated",
                "Interlinear",
                "Original",
                "Parallel",
                "Trilingual"
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        },
      ),
      Consumer(
        builder: (context, watch, child) {
          final Map<String, String> marvelCommentaries = {
            "Barnes": "Notes on the Old and New Testaments (Barnes) [26 vol.]",
            "Benson":
                "Commentary on the Old and New Testaments (Benson) [5 vol.]",
            "BI": "Biblical Illustrator (Exell) [58 vol.]",
            "Brooks": "Complete Summary of the Bible (Brooks) [2 vol.]",
            "Calvin": "John Calvin's Commentaries (Calvin) [22 vol.]",
            "Clarke": "Commentary on the Bible (Clarke) [6 vol.]",
            "CBSC":
                "Cambridge Bible for Schools and Colleges (Cambridge) [57 vol.]",
            "CECNT":
                "Critical And Exegetical Commentary on the NT (Meyer) [20 vol.]",
            "CGrk":
                "Cambridge Greek Testament for Schools and Colleges (Cambridge) [21 vol.]",
            "CHP": "Church Pulpit Commentary (Nisbet) [12 vol.]",
            "CPBST":
                "College Press Bible Study Textbook Series (College) [59 vol.]",
            "EBC": "Expositor's Bible Commentary (Nicoll) [49 vol.]",
            "ECER": "Commentary for English Readers (Ellicott) [8 vol.]",
            "EGNT": "Expositor's Greek New Testament (Nicoll) [5 vol.]",
            "GCT": "Greek Testament Commentary (Alford) [4 vol.]",
            "Gill": "Exposition of the Entire Bible (Gill) [9 vol.]",
            "Henry":
                "Exposition of the Old and New Testaments (Henry) [6 vol.]",
            "HH": "Horæ Homileticæ (Simeon) [21 vol.]",
            "ICCNT":
                "International Critical Commentary, NT (1896-1929) [16 vol.]",
            "JFB": "Jamieson, Fausset, and Brown Commentary (JFB) [6 vol.]",
            "KD":
                "Commentary on the Old Testament (Keil & Delitzsch) [10 vol.]",
            "Lange":
                "Commentary on the Holy Scriptures: Critical, Doctrinal, and Homiletical (Lange) [25 vol.]",
            "MacL": "Expositions of Holy Scripture (MacLaren) [32 vol.]",
            "PHC":
                "Preacher's Complete Homiletical Commentary (Exell) [37 vol.]",
            "Pulpit": "Pulpit Commentary (Spence) [23 vol.]",
            "Rob": "Word Pictures in the New Testament (Robertson) [6 vol.]",
            "Spur": "Spurgeon's Expositions on the Bible (Spurgeon) [3 vol.]",
            "Vincent": "Word Studies in the New Testament (Vincent) [4 vol.]",
            "Wesley":
                "John Wesley's Notes on the Whole Bible (Wesley) [3 vol.]",
            "Whedon":
                "Commentary on the Old and New Testaments (Whedon) [14 vol.]",
          };
          final List<String> commentaryAbb = marvelCommentaries.keys.toList()
            ..sort();
          final String marvelCommentary =
              watch(marvelCommentaryP).state.substring(1);
          return ListTile(
            title: Text(interface[23],
                style: Theme.of(context).textTheme.bodyText1),
            subtitle: Text(marvelCommentaries[marvelCommentary],
                style: Theme.of(context).textTheme.subtitle1),
            trailing: DropdownButton<String>(
              style: Theme.of(context).textTheme.bodyText1,
              underline: watch(dropdownUnderlineP).state,
              iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
              iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
              value: marvelCommentary,
              onChanged: (String newValue) {
                if (newValue != marvelCommentary) {
                  context
                      .read(configProvider)
                      .state
                      .save("marvelCommentary", "c$newValue");
                  context.refresh(marvelCommentaryP);
                }
              },
              items:
                  commentaryAbb.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        },
      ),
    ];
  }
}
