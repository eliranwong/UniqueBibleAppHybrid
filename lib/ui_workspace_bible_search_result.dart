// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:unique_bible_app_expanded/bible_parser.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'bible.dart';

class BibleSearchResults extends StatelessWidget {

  final Function callBack;
  BibleSearchResults(this.callBack);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        final int lastBibleSearchHit = watch(bibleSearchDataP).state["lastBibleSearchHit"];
        final String lastBibleSearchEntry = watch(bibleSearchDataP).state["lastBibleSearchEntry"];
        final Map<int, List<List<dynamic>>> lastSearchResults =
            watch(bibleSearchDataP).state["lastBibleSearchResults"];
        final Map<int, List<List<dynamic>>> lastSearchResultsLazy =
            watch(bibleSearchDataP).state["lastBibleSearchResultsLazy"];
        final List<int> bookList = lastSearchResults.keys.toList()..sort();
        Map<String, double> pieChartDataMap = {
          for (MapEntry i in lastSearchResults.entries)
            parser.standardAbbreviation[i.key.toString()]:
                i.value.length.toDouble()
        };
        return (lastSearchResultsLazy.isEmpty) ? Center(
          child: Text("No search result!"),
        ) : SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: Text("$lastBibleSearchEntry x $lastBibleSearchHit"),
                children: [
                  PieChart(
                    dataMap: pieChartDataMap,
                    centerText: "$lastBibleSearchEntry",
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                    ),
                  ),
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: bookList.length,
                  itemBuilder: (context, i) => _buildBookSection(
                      bookList[i], lastSearchResults[bookList[i]].length, lastSearchResultsLazy[bookList[i]])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookSection(int bookNo, int allHits, List<List<dynamic>> data) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        return ExpansionTile(
          title: Text(
              "${parser.standardBookname[bookNo.toString()]} [$allHits]"),
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
          children: <Widget>[_buildBookResult(data, bookNo)],
        );
      },
    );
  }

  Widget _buildBookResult(List<List<dynamic>> data, int bookNo) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: data.length,
      itemBuilder: (context, i) => _buildVerseRow(context, i, data[i], bookNo),
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, List<dynamic> data, int bookNo) {
    if (data.isEmpty)
      return ListTile(
        title: Center(
          child: Text(
            "[Read more ...]",
          ),
        ),
        onTap: () {
          context.read(configProvider).state.bibleDB1.updateLastBibleSearchResultsLazy(bookNo);
          context.refresh(bibleSearchDataP);
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
            text: "[${data.first[1]}:${data.first.last}]$displayVersion $verseText",
            style: myTextStyle["verseFont"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[0-9]+?:[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async => await callBack(["newVersionVerseSelected", data]),
              ),
              MatchText(
                pattern: searchEntry,
                regexOptions: RegexOptions(
                    caseSensitive : false,
                    unicode : true,
                ),
                style: TextStyle(backgroundColor: Colors.red[300]),
              ),
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
