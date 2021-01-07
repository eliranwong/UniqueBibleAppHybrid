// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'bible.dart';
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
        final String activeVerseReference = watch(activeVerseReferenceP).state;
        return TextField(
          //controller: ,
          autofocus: false,
          decoration: InputDecoration(
            labelText: "Exclude (separator: |)",
            //labelStyle: ,
            hintText: activeVerseReference,
            hintStyle: myTextStyle["subtitleStyle"],
            //errorText: _searchInputValid ? null : 'Invalid input!',
            //prefixIcon: Icon(Icons.search),
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
            await callBack(["loadMultipleVerses", references]);
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
          final bool multipleVersesShowVersion = watch(multipleVersesP).state["multipleVersesShowVersion"];
          //final List<List<dynamic>> multipleVersesData = watch(multipleVersesP).state["multipleVersesData"];
          final List<List<dynamic>> multipleVersesDataLazy = watch(multipleVersesP).state["multipleVersesDataLazy"];
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: multipleVersesDataLazy.length,
            itemBuilder: (context, i) => _buildVerseRow(context, i, multipleVersesDataLazy[i]),
          );
        }
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, List<dynamic> data) {
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
        final String displayVersion =
        (context.read(parallelVersesP).state) ? " [${data.last}]" : "";
        final String verseText = Bible.processVerseText(data[1]);
        final String lastBibleSearchEntry = context.read(bibleSearchDataP).state["lastBibleSearchEntry"];
        final int searchEntryOption = context.read(searchEntryOptionP).state;
        final String searchEntry = (searchEntryOption == 4) ? [for (var match in RegExp(r"%(.*?)%").allMatches(lastBibleSearchEntry)) match.group(1)].join("|") : lastBibleSearchEntry;
        return ListTile(
          title: ParsedText(
            selectable: true,
            alignment: TextAlign.start,
            text: "[${context.read(parserP).state.bcvToVerseReference([for (int i in data.first) i])}]$displayVersion $verseText",
            style: myTextStyle["verseFont"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[A-Za-z0-9]+? [0-9\-:]+?\]",
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