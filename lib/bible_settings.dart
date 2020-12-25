import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//import 'dart:io';
import 'config.dart';
import 'app_translation.dart';

class BibleSettings extends StatelessWidget {

  final List<String> fontSizeList = [for (int i = 7; i <= 40; i++) i.toString()];
  final Map<String, String> interfaceMap = {"English": "ENG", "繁體中文": "TC", "简体中文": "SC"};
  final Map<String, String> interfaceMapReverse = {"ENG": "English", "TC": "繁體中文", "SC": "简体中文"};
  final Map<String, List<String>> _instantActionMap = {
    "ENG": ["Tips", "Interlinear"],
    "TC": ["提示", "原文逐字翻譯"],
    "SC": ["提示", "原文逐字翻译"],
  };
  final Map<String, String> marvelBibles = {
    "MAB": "Annotated",
    "MIB": "Interlinear",
    "MOB": "Original",
    "MPB": "Parallel",
    "MTB": "Trilingual",
  };

  @override
  build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final List<String> _interface = AppTranslation.interfaceBibleSettings[watch(abbreviationsP).state];
        return Theme(
          data: watch(mainThemeP).state,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: watch(myColorsP).state["background"],
              title: Text(_interface[0]),
              /*actions: <Widget>[
                IconButton(
                  tooltip: _interface[10],
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Navigator.pop(
                        context);
                  },
                ),
              ],*/
            ),
            body: _bibleSettings(context),
          ),
        );
      },
    );
  }

  Widget _bibleSettings(BuildContext context) {

    /*List<String> commentaryAbb = _config.marvelCommentaries.keys.toList()..sort();

    List moduleList = Bibles(this.abbreviations).getALLBibleList();
    List<Widget> versionRowList = moduleList
        .map((i) => _buildVersionRow(context, i, dropdownBackground))
        .toList();*/

    return Consumer(
      builder: (context, watch, child) {
        final List<String> _interface = AppTranslation.interfaceBibleSettings[watch(abbreviationsP).state];
        final backgroundBrightness = watch(backgroundBrightnessP).state;

        final TextStyle style = (backgroundBrightness >= 500)
            ? TextStyle(color: Colors.grey[300])
            : TextStyle(color: Colors.black);

        //final TextStyle subtitleStyle = TextStyle(color: (backgroundBrightness >= 700) ? Colors.grey[400] : _config.myColors["grey"],);

        final Color dropdownBackground = (backgroundBrightness >= 500)
            ? Colors.blueGrey[backgroundBrightness - 200]
            : Colors.blueGrey[backgroundBrightness];
        final Color dropdownBorder = (backgroundBrightness >= 500)
            ? Colors.grey[400]
            : Colors.grey[700];
        final Color dropdownDisabled = (backgroundBrightness >= 500)
            ? Colors.blueAccent[100]
            : Colors.blueAccent[700];
        final Color dropdownEnabled = (backgroundBrightness >= 500)
            ? Colors.blueAccent[100]
            : Colors.blueAccent[700];

        final Widget dropdownUnderline = Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dropdownBorder))),
        );

        return Container(
          color: Colors.blueGrey[watch(backgroundBrightnessP).state],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: <Widget>[
                ListTile(
              title: Text(_interface[1], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: interfaceMapReverse[watch(abbreviationsP).state],
                onChanged: (String newValue) {
                  String newValueAbb = interfaceMap[newValue];
                  if (context.read(abbreviationsP).state != newValueAbb) {
                    context.read(configProvider).state.save("abbreviations", newValueAbb);
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
            ),
            /*ListTile(
              title: Text(_interface[11], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _colorDegreeValue,
                onChanged: (String newValue) {
                  if (_colorDegreeValue != newValue) {
                    setState(() {
                      _colorDegreeValue = newValue;
                    });
                  }
                },
                items: <String>[...colorDegree]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[6], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _fontSizeValue,
                onChanged: (String newValue) {
                  if (_verseValue != newValue) {
                    setState(() {
                      _fontSizeValue = newValue;
                    });
                  }
                },
                items: <String>[...fontSizeList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[2], style: style),
              subtitle: Text(_config.allBibleMap[_moduleValue], style: subtitleStyle),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _moduleValue,
                onChanged: (String newValue) {
                  if (_moduleValue != newValue) {
                    onModuleChanged(newValue);
                  }
                },
                items: <String>[...moduleList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[18], style: style),
              subtitle: Text(_config.allBibleMap[_moduleValue2], style: subtitleStyle),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _moduleValue2,
                onChanged: (String newValue) {
                  if (_moduleValue2 != newValue) {
                    setState(() {
                      _moduleValue2 = newValue;
                    });
                  }
                },
                items: <String>[...moduleList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ExpansionTile(
              title: Text(_interface[7], style: style),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
              children: versionRowList,
            ),
            ListTile(
              title: Text(_interface[21], style: style),
              trailing: Switch(
                  value: _showHeadingVerseNoValue,
                  onChanged: (bool value) {
                    setState(() {
                      _showHeadingVerseNoValue = value;
                    });
                  }
              ),
            ),
            ListTile(
              title: Text(_interface[20], style: style),
              subtitle: Text(_config.allBibleMap[_iBible], style: subtitleStyle),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _iBible,
                onChanged: (String newValue) {
                  if (_iBible != newValue) {
                    setState(() {
                      _iBible = newValue;
                    });
                  }
                },
                items: _config.interlinearBibles
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[9], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _instantActionList[_instantAction],
                onChanged: (String newValue) {
                  if (_instantActionList[_instantAction] != newValue) {
                    setState(() {
                      _instantAction = _instantActionList.indexOf(newValue);
                    });
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
            ),
            ListTile(
              title: Text(
                _interface[8],
                style: style,
              ),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _favouriteActionList[_favouriteAction],
                onChanged: (String newValue) {
                  if (_favouriteActionList[_favouriteAction] != newValue) {
                    setState(() {
                      _favouriteAction = _favouriteActionList.indexOf(newValue);
                    });
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
            ),
            ListTile(
              title: Text(
                _interface[14],
                style: style,
              ),
              trailing: IconButton(
                tooltip: _interface[15],
                icon: Icon(Icons.settings_backup_restore,
                    color: (backgroundBrightness >= 500)
                        ? Colors.blueAccent[100]
                        : Colors.blueAccent[700]),
                onPressed: () {
                  setState(() {
                    _speechRateValue = (Platform.isAndroid) ? 1.0 : 0.5;
                  });
                },
              ),
            ),
            Slider(
              activeColor: (backgroundBrightness >= 500)
                  ? Colors.blueAccent[100]
                  : Colors.blueAccent[700],
              min: 0.1,
              max: (Platform.isAndroid) ? 3.0 : 1.0,
              onChanged: (newValue) {
                setState(() {
                  _speechRateValue = num.parse(newValue.toStringAsFixed(1));
                });
              },
              value: _speechRateValue,
            ),
            ListTile(
              title: Text(_interface[12], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _ttsEnglishValue,
                onChanged: (String newValue) {
                  if (_ttsEnglishValue != newValue) {
                    setState(() {
                      _ttsEnglishValue = newValue;
                    });
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
            ),
            ListTile(
              title: Text(_interface[13], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _ttsChineseValue,
                onChanged: (String newValue) {
                  if (_ttsChineseValue != newValue) {
                    setState(() {
                      _ttsChineseValue = newValue;
                    });
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
            ),
            /*ListTile(
              title: Text(_interface[16], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _ttsGreekValue,
                onChanged: (String newValue) {
                  if (_ttsGreekValue != newValue) {
                    setState(() {
                      _ttsGreekValue = newValue;
                    });
                  }
                },
                items: <String>["modern", "Erasmian"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),*/
            ListTile(
              title: Text(_interface[19], style: style),
              subtitle: Text("Marvel $_marvelBible Bible", style: subtitleStyle),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _marvelBible,
                onChanged: (String newValue) {
                  if (_marvelBible != newValue) {
                    setState(() {
                      _marvelBible = newValue;
                    });
                  }
                },
                items: <String>["Annotated", "Interlinear", "Original", "Parallel", "Trilingual"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[23], style: style),
              subtitle: Text(_config.marvelCommentaries[_marvelCommentary], style: subtitleStyle),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _marvelCommentary,
                onChanged: (String newValue) {
                  if (_marvelCommentary != newValue) {
                    setState(() {
                      _marvelCommentary = newValue;
                    });
                  }
                },
                items: commentaryAbb.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(_interface[22], style: style),
              trailing: Switch(
                  value: _alwaysOpenMarvelBibleExternallyValue,
                  onChanged: (!_config.plus)
                      ? null
                      : (bool value) {
                    setState(() {
                      _alwaysOpenMarvelBibleExternallyValue = value;
                    });
                  }
              ),
            ),*/
              ],
            ),
          ),
        );
      },
    );
  }

  /*Widget _buildVersionRow(
      BuildContext context, String version, Color dropdownBackground) {
    return Container(
      color: dropdownBackground,
      child: CheckboxListTile(
        title: Text(
          _config.allBibleMap[version],
          style: TextStyle(
              color: (backgroundBrightness >= 700)
                  ? Colors.blue[300]
                  : Colors.blue[700]),
        ),
        subtitle: Text(
          version,
          style: TextStyle(
            color: (backgroundBrightness >= 700)
                ? Colors.grey[400]
                : _config.myColors["grey"],
          ),
        ),
        value: (_compareBibleList.contains(version)),
        onChanged: (bool value) {
          setState(() {
            if (value) {
              _compareBibleList.add(version);
            } else {
              var versionIndex = _compareBibleList.indexOf(version);
              _compareBibleList.removeAt(versionIndex);
            }
          });
        },
      ),
    );
  }*/

}

