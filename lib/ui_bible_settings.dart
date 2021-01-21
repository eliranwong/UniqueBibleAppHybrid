import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'config.dart';
import 'html_elements.dart';

class BibleSettings extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<String> interface = watch(interfaceBibleSettingsP).state;
        final Map<String, Color> myColors = watch(myColorsP).state;
        return Theme(
          data: watch(mainThemeP).state,
          child: Scaffold(
            // Reference about appbar back button:
            // https://stackoverflow.com/questions/51508257/how-to-change-the-appbar-back-button-color
            appBar: AppBar(
              backgroundColor: myColors["appBarColor"],
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
                _language(context, interface),
                const Divider(),
                ..._backgroundBrightness(context, interface),
                ..._fontSize(context, interface),
                const Divider(),
                _instantHighlightColor(context, interface),
                _bookmarkHighlightColor1(context, interface),
                _bookmarkHighlightColor2(context, interface),
                const Divider(),
                _keepDrawerOpen(context, interface),
                _autoFocusVerseReferenceField(context, interface),
                _openBookWithoutChapterSelection(context, interface),
                _openChapterWithoutVerseSelection(context, interface),
                const Divider(),
                _enableParallelSearchResults(context, interface),
                _enableParallelMultipleVerses(context, interface),
                const Divider(),
                _interlinearTitle(context, interface),
                _interlinearClauseBoundaries(context, interface),
                _interlinear0(context, interface),
                _interlinear1(context, interface),
                _interlinear2(context, interface),
                _interlinear3(context, interface),
                _interlinear4(context, interface),
                _interlinear5(context, interface),
                _interlinear6(context, interface),
                _interlinear7(context, interface),
                _interlinear8(context, interface),
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

  Widget _interlinearTitle(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        return ListTile(
          title: Text(interface[39],
              style: watch(myTextStyleP).state["verseFont"]),
        );
      },
    );
  }

  Widget _language(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final String language = watch(languageP).state;
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
              Text(interface[1], style: watch(myTextStyleP).state["verseFont"]),
          trailing: DropdownButton<String>(
            style: watch(myTextStyleP).state["verseFont"],
            underline: watch(dropdownUnderlineP).state,
            iconDisabledColor: watch(myColorsP).state["dropdownDisabled"],
            iconEnabledColor: watch(myColorsP).state["dropdownEnabled"],
            value: interfaceMapReverse[language],
            onChanged: (String newValue) {
              String newValueAbb = interfaceMap[newValue];
              if (newValueAbb != language) {
                context
                    .read(configProvider)
                    .state
                    .save("language", newValueAbb);
                context.refresh(languageP);
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
              style: watch(myTextStyleP).state["verseFont"]);
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
              context.refresh(bibleTextStylesP);
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
              style: watch(myTextStyleP).state["verseFont"]);
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
              await context
                  .read(configProvider)
                  .state
                  .save("fontSize", newValue);
              context.refresh(fontSizeP);
              context.refresh(mainThemeP);
              context.refresh(myColorsP);
              context.refresh(myTextStyleP);
              context.refresh(bibleTextStylesP);
              context.refresh(dropdownUnderlineP);
            }
          },
        );
      }),
    ];
  }

  Widget _instantHighlightColor(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final Color instantHighlightColor = watch(myColorsP).state["instantHighlight"];
        final String instantHighlightColorCode = watch(instantHighlightColorCodeP).state;
        return ListTile(
          title: Text(
            interface[42],
            style: watch(myTextStyleP).state["verseFont"],
          ),
          subtitle: Text(
            instantHighlightColorCode,
            style: watch(myTextStyleP).state["subtitleStyle"],
          ),
          trailing: IconButton(
            tooltip: interface[41],
            icon: Icon(
              Icons.color_lens,
              color: instantHighlightColor,
            ),
            onPressed: () async {
              context.read(pickerSelectedColorP).state = instantHighlightColor;
              if (await showColorDialog(context)) {
                final String newColorCode = context.read(pickerSelectedColorP).state.toHex();
                context.read(configProvider).state.updateSingleColor("instantHighlight", newColorCode);
                context.refresh(myColorsP);
                context.refresh(myTextStyleP);
              }
            },
          ),
        );
      },
    );
  }

  Widget _bookmarkHighlightColor1(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final Color bookmarkHighlight1Color = watch(myColorsP).state["bookmarkHighlight1"];
        final String bookmarkHighlight1ColorCode = watch(bookmarkHighlight1ColorCodeP).state;
        return ListTile(
          title: Text(
            interface[43],
            style: watch(myTextStyleP).state["verseFont"],
          ),
          subtitle: Text(
            bookmarkHighlight1ColorCode,
            style: watch(myTextStyleP).state["subtitleStyle"],
          ),
          trailing: IconButton(
            tooltip: interface[41],
            icon: Icon(
              Icons.color_lens,
              color: bookmarkHighlight1Color,
            ),
            onPressed: () async {
              context.read(pickerSelectedColorP).state = bookmarkHighlight1Color;
              if (await showColorDialog(context)) {
                final String newColorCode = context.read(pickerSelectedColorP).state.toHex();
                context.read(configProvider).state.updateSingleColor("bookmarkHighlight1", newColorCode);
                context.refresh(myColorsP);
                context.refresh(myTextStyleP);
              }
            },
          ),
        );
      },
    );
  }

  Widget _bookmarkHighlightColor2(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final Color bookmarkHighlight2Color = watch(myColorsP).state["bookmarkHighlight2"];
        final String bookmarkHighlight2ColorCode = watch(bookmarkHighlight2ColorCodeP).state;
        return ListTile(
          title: Text(
            interface[44],
            style: watch(myTextStyleP).state["verseFont"],
          ),
          subtitle: Text(
            bookmarkHighlight2ColorCode,
            style: watch(myTextStyleP).state["subtitleStyle"],
          ),
          trailing: IconButton(
            tooltip: interface[41],
            icon: Icon(
              Icons.color_lens,
              color: bookmarkHighlight2Color,
            ),
            onPressed: () async {
              context.read(pickerSelectedColorP).state = bookmarkHighlight2Color;
              if (await showColorDialog(context)) {
                final String newColorCode = context.read(pickerSelectedColorP).state.toHex();
                context.read(configProvider).state.updateSingleColor("bookmarkHighlight2", newColorCode);
                context.refresh(myColorsP);
                context.refresh(myTextStyleP);
              }
            },
          ),
        );
      },
    );
  }

  Future<bool> showColorDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, watch, child) {
          final pickerSelectedColor = watch(pickerSelectedColorP).state;
          final Map<String, List<String>> colorDialogWords = {
            "ENG": ["Select a color", "Cancel", "Change"],
            "TC": ["選擇您喜歡的顔色", "取消", "變更"],
            "SC": ["选择您喜欢的颜色", "取消", "变更"],
          };
          final List<String> words = colorDialogWords[watch(languageP).state];
          return AlertDialog(
            title: Text(words.first),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerSelectedColor,
                onColorChanged: (Color color) => context.read(pickerSelectedColorP).state = color,
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(words[1]),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(words.last),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _keepDrawerOpen(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool keepDrawerOpen = watch(keepDrawerOpenP).state;
        return ListTile(
          title: Text(interface[24],
              style: watch(myTextStyleP).state["verseFont"]),
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

  Widget _interlinearClauseBoundaries(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["clauseBoundaries"];
        return ListTile(
          title: Text(interface[40],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("clauseBoundaries", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear0(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearWord"];
        return ListTile(
          title: Text(interface[30],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearWord", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear1(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearTransliteration"];
        return ListTile(
          title: Text(interface[31],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearTransliteration", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear2(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearPronunciation"];
        return ListTile(
          title: Text(interface[32],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearPronunciation", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear3(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearLexeme"];
        return ListTile(
          title: Text(interface[33],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearLexeme", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear4(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearLexicon"];
        return ListTile(
          title: Text(interface[34],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearLexicon", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear5(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearGloss"];
        return ListTile(
          title: Text(interface[35],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearGloss", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear6(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearMorphology"];
        return ListTile(
          title: Text(interface[36],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearMorphology", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear7(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearLiteral"];
        return ListTile(
          title: Text(interface[37],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearLiteral", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _interlinear8(BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool customInterlinearOption =
            watch(customInterlinearP).state["interlinearSmooth"];
        return ListTile(
          title: Text(interface[38],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: customInterlinearOption,
              onChanged: (bool newValue) {
                if (newValue != customInterlinearOption) {
                  context
                      .read(configProvider)
                      .state
                      .save("interlinearSmooth", newValue);
                  context.refresh(customInterlinearP);
                }
              }),
        );
      },
    );
  }

  Widget _autoFocusVerseReferenceField(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool currentValue = watch(autoFocusVerseReferenceFieldP).state;
        return ListTile(
          title: Text(interface[25],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: currentValue,
              onChanged: (bool newValue) {
                if (newValue != currentValue) {
                  context
                      .read(configProvider)
                      .state
                      .save("autoFocusVerseReferenceField", newValue);
                  context.refresh(autoFocusVerseReferenceFieldP);
                }
              }),
        );
      },
    );
  }

  Widget _openBookWithoutChapterSelection(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool currentValue = watch(openBookWithoutChapterSelectionP).state;
        return ListTile(
          title: Text(interface[26],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: currentValue,
              onChanged: (bool newValue) {
                if (newValue != currentValue) {
                  context
                      .read(configProvider)
                      .state
                      .save("openBookWithoutChapterSelection", newValue);
                  context.refresh(openBookWithoutChapterSelectionP);
                }
              }),
        );
      },
    );
  }

  Widget _openChapterWithoutVerseSelection(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool currentValue =
            watch(openChapterWithoutVerseSelectionP).state;
        return ListTile(
          title: Text(interface[27],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: currentValue,
              onChanged: (bool newValue) {
                if (newValue != currentValue) {
                  context
                      .read(configProvider)
                      .state
                      .save("openChapterWithoutVerseSelection", newValue);
                  context.refresh(openChapterWithoutVerseSelectionP);
                }
              }),
        );
      },
    );
  }

  Widget _enableParallelSearchResults(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool currentValue = watch(enableParallelSearchResultsP).state;
        return ListTile(
          title: Text(interface[28],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: currentValue,
              onChanged: (bool newValue) {
                if (newValue != currentValue) {
                  context
                      .read(configProvider)
                      .state
                      .save("enableParallelSearchResults", newValue);
                  context.refresh(enableParallelSearchResultsP);
                }
              }),
        );
      },
    );
  }

  Widget _enableParallelMultipleVerses(
      BuildContext context, List<String> interface) {
    return Consumer(
      builder: (context, watch, child) {
        final bool currentValue = watch(enableParallelMultipleVersesP).state;
        return ListTile(
          title: Text(interface[29],
              style: watch(myTextStyleP).state["verseFont"]),
          trailing: Switch(
              value: currentValue,
              onChanged: (bool newValue) {
                if (newValue != currentValue) {
                  context
                      .read(configProvider)
                      .state
                      .save("enableParallelMultipleVerses", newValue);
                  context.refresh(enableParallelMultipleVersesP);
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
            _instantActionMap[watch(languageP).state];
        final int instantAction = watch(instantActionP).state;
        final String instantActionDescription =
            _instantActionList[instantAction];
        return ListTile(
          title:
              Text(interface[9], style: watch(myTextStyleP).state["verseFont"]),
          trailing: DropdownButton<String>(
            style: watch(myTextStyleP).state["verseFont"],
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
        final List<String> _favouriteActionList =
            watch(interfaceDialogP).state.sublist(4);
        _favouriteActionList.insert(0, "---");
        final int favouriteAction = watch(favouriteActionP).state;
        final String favouriteActionDescription =
            _favouriteActionList[favouriteAction];
        return ListTile(
          title: Text(
            interface[8],
            style: watch(myTextStyleP).state["verseFont"],
          ),
          trailing: DropdownButton<String>(
            style: watch(myTextStyleP).state["verseFont"],
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
              style: watch(myTextStyleP).state["verseFont"],
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
                style: watch(myTextStyleP).state["verseFont"]),
            trailing: DropdownButton<String>(
              style: watch(myTextStyleP).state["verseFont"],
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
                style: watch(myTextStyleP).state["verseFont"]),
            trailing: DropdownButton<String>(
              style: watch(myTextStyleP).state["verseFont"],
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
                style: watch(myTextStyleP).state["verseFont"]),
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
                style: watch(myTextStyleP).state["verseFont"]),
            subtitle: Text("Marvel $marvelBible Bible",
                style: watch(myTextStyleP).state["subtitleStyle"]),
            trailing: DropdownButton<String>(
              style: watch(myTextStyleP).state["verseFont"],
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
                style: watch(myTextStyleP).state["verseFont"]),
            subtitle: Text(marvelCommentaries[marvelCommentary],
                style: watch(myTextStyleP).state["subtitleStyle"]),
            trailing: DropdownButton<String>(
              style: watch(myTextStyleP).state["verseFont"],
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
