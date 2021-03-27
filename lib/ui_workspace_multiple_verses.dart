// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'text_transformer.dart';

class MultipleVerses extends StatelessWidget{

  final Function callBack;
  MultipleVerses(this.callBack);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(3),
      children: <Widget>[
        Container(height: 5),
        _buildVerseReferenceField(context),
        _buildVerseList(context),
      ],
    );
  }

  Widget _buildVerseReferenceField(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String multipleVersesReferences = watch(multipleVersesP).state["multipleVersesReferences"];
        return TextField(
          controller: TextEditingController(text: multipleVersesReferences),
          autofocus: false,
          decoration: InputDecoration(
            labelText: "Multiple references",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: multipleVersesReferences,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["blueAccent"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: watch(myColorsP).state["grey"]),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            /*disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),*/
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onSubmitted: (String value) async {
            // Convert full-width punctuations
            value = TextTransformer.removeFullWidthPunctuation(value);
            // Parse the entered reference(s)
            final List<List<dynamic>> references =
            context.read(parserP).state.extractAllReferences(value);
            if (references.isNotEmpty) await callBack(["loadMultipleVerses", references]);
          },
          //onChanged: ,
          //onTap: ,
          //onEditingComplete: ,
        );
      },
    );
  }

  Widget _buildVerseList(BuildContext context) {
    return Consumer(
        builder: (context, watch, child) {
          final Map<String, dynamic> multipleVerses = watch(multipleVersesP).state;
          final List<List<dynamic>> multipleVersesDataLazy = multipleVerses["multipleVersesDataLazy"];
          final List<List<dynamic>> multipleVersesDataParallel = (watch(parallelVersesP).state) ? multipleVerses["multipleVersesDataParallel"] : [];
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: multipleVersesDataLazy.length,
            itemBuilder: (context, i) => _buildVerseRow(context, i, multipleVersesDataLazy[i], (multipleVersesDataParallel.isNotEmpty) ? multipleVersesDataParallel[i] : multipleVersesDataParallel),
          );
        }
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, List<dynamic> data, List<dynamic> dataParallel) {
    if (data.isEmpty)
      return ListTile(
        title: Center(
          child: Text(
            "[Read more ...]",
          ),
        ),
        onTap: () {
          context.read(configProvider).state.updateMultipleVersesDataLazy();
          context.refresh(multipleVersesP);
        },
        onLongPress: () {
          print("long press");
        },
      );
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String verseText = TextTransformer.processBibleVerseText(data[1]);
        final String verseTextParallel = (dataParallel.isEmpty) ? "" : TextTransformer.processBibleVerseText(dataParallel[1]);
        return ListTile(
          subtitle: (dataParallel.isEmpty) ? null : ParsedText(
            selectable: true,
            alignment: TextAlign.start,
            text: "[${dataParallel.last}] $verseTextParallel",
            style: myTextStyle["subtitleStyle"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[A-Za-z0-9]+? [0-9\-:]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]|\[[^A-Za-z]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async => await callBack(["newVersionVerseSelected", dataParallel]),
              ),
              MatchText(
                pattern: r"\[[0-9]+?:[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async {
                  List<String> cvList = url.substring(1, url.length - 1).split(":");
                  List<dynamic> newData = [[dataParallel.first.first, int.parse(cvList.first), int.parse(cvList.last)], ...dataParallel.sublist(1, 3)];
                  await callBack(["newVersionVerseSelected", newData]);
                },
              ),
              MatchText(
                pattern: r"\[[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async {
                  int v = int.parse(url.substring(1, url.length - 1));
                  List<dynamic> newData = [[...dataParallel.first.sublist(0, 2), v], ...dataParallel.sublist(1, 3)];
                  await callBack(["newVersionVerseSelected", newData]);
                },
              ),
              /*MatchText(
                pattern: searchEntry,
                regexOptions: RegexOptions(
                  caseSensitive : false,
                  unicode : true,
                ),
                style: TextStyle(backgroundColor: Colors.red[300]),
              ),*/
            ],
          ),
          title: ParsedText(
            selectable: true,
            alignment: TextAlign.start,
            text: "[${context.read(parserP).state.bcvToVerseReference([for (int i in data.first) i])}] ${(context.read(parallelVersesP).state) ? '\n[${data.last}]' : ''} $verseText",
            style: myTextStyle["verseFont"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[A-Za-z0-9]+? [0-9\-:]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]|\[[^A-Za-z]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async => await callBack(["newVersionVerseSelected", data]),
              ),
              MatchText(
                pattern: r"\[[0-9]+?:[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async {
                  List<String> cvList = url.substring(1, url.length - 1).split(":");
                  List<dynamic> newData = [[data.first.first, int.parse(cvList.first), int.parse(cvList.last)], ...data.sublist(1, 3)];
                  await callBack(["newVersionVerseSelected", newData]);
                },
              ),
              MatchText(
                pattern: r"\[[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async {
                  int v = int.parse(url.substring(1, url.length - 1));
                  List<dynamic> newData = [[...data.first.sublist(0, 2), v], ...data.sublist(1, 3)];
                  await callBack(["newVersionVerseSelected", newData]);
                },
              ),
              /*MatchText(
                pattern: searchEntry,
                regexOptions: RegexOptions(
                  caseSensitive : false,
                  unicode : true,
                ),
                style: TextStyle(backgroundColor: Colors.red[300]),
              ),*/
            ],
          ),
          onTap: () async {
            await callBack(["newVersionVerseSelected", data]);
          },
          onLongPress: () {
            print("long press");
          },
        );
      },
    );
  }

}