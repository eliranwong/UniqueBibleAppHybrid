// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'bible.dart';
import 'text_transformer.dart';

class MultipleVersions extends StatelessWidget {

  final Function callBack;
  MultipleVersions(this.callBack);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(3),
      children: <Widget>[
        //Container(height: 5),
        ListTile(
          title: _buildVerseReferenceField(context),
          trailing: Consumer(builder: (context, watch, child) {
            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: watch(myColorsP).state["blueAccent"],),
              itemBuilder: (BuildContext context) {
                final Map<String, List<String>> allBibles = context.read(configProvider).state.allBibles;
                final List<String> allBiblesList = allBibles.keys.toList()..sort();
                return allBiblesList.map((i) => PopupMenuItem(value: i, child: Text(i))).toList();
              },
              onSelected: (String value) async {
                print("hello");
              },
            );
          }),
        ),
        _buildCardList(context),
      ],
    );
    //return _buildCardList(context);
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
            labelText: "Multiple references",
            labelStyle: TextStyle(color: watch(myColorsP).state["blueAccent"]),
            hintText: activeVerseReference,
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

  Widget _buildCardList(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final Map<String, dynamic> multipleVersions = watch(multipleVersionsP).state;
      final List<List<dynamic>> multipleVersionsEntries = multipleVersions["multipleVersionsEntries"];
      final List<List<dynamic>> multipleVersionsData = multipleVersions["multipleVersionsData"];
      return ListView.builder(
          padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: multipleVersionsData.length,
          itemBuilder: (context, i) => _buildCard(context, i, multipleVersionsData[i]),
      );
    });
  }

  Widget _buildCard(BuildContext context, int i, List<dynamic> data) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildVerseRow(context, i, data),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, List<dynamic> data) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final String verseText = Bible.processVerseText(data[1]);
        //final String lastBibleSearchEntry = context.read(bibleSearchDataP).state["lastBibleSearchEntry"];
        //final int searchEntryOption = context.read(searchEntryOptionP).state;
        //final String searchEntry = (searchEntryOption == 4) ? [for (var match in RegExp(r"%(.*?)%").allMatches(lastBibleSearchEntry)) match.group(1)].join("|") : lastBibleSearchEntry;
        return ListTile(
          title: ParsedText(
            selectable: true,
            alignment: TextAlign.start,
            text: "[${data.last}] $verseText",
            //text: "[${context.read(parserP).state.bcvToVerseReference([for (int i in data.first) i])}]$displayVersion $verseText",
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