// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:unique_bible_app_expanded/bible_parser.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'bible.dart';
import 'ui_bar_chart.dart';

class BibleSearchResults extends StatelessWidget {
  final Function callBack;
  BibleSearchResults(this.callBack);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        final bibleSearchData = watch(bibleSearchDataP).state;
        final List<String> searchOptionDescription =
            watch(searchEntryOptionsP).state;
        final String lastBibleSearchEntryOption = searchOptionDescription[
            bibleSearchData["lastBibleSearchEntryOption"]];
        final String lastBibleSearchExclusionEntry =
            bibleSearchData["lastBibleSearchExclusionEntry"];
        final String lastBibleSearchModule =
            bibleSearchData["lastBibleSearchModule"];
        final int lastBibleSearchHit = bibleSearchData["lastBibleSearchHit"];
        final String lastBibleSearchEntry =
            bibleSearchData["lastBibleSearchEntry"];
        final Map<int, List<List<dynamic>>> lastSearchResults =
            bibleSearchData["lastBibleSearchResults"];
        final Map<int, List<List<dynamic>>> lastSearchResultsLazy =
            bibleSearchData["lastBibleSearchResultsLazy"];
        final List<int> bookList = lastSearchResults.keys.toList()..sort();
        List<ChartsFlutterDatum> bookBarChartData = [];
        Map<String, double> pieChartDataMap = {};
        for (MapEntry i in lastSearchResults.entries) {
          final String bookAbb = parser.standardAbbreviation[i.key.toString()];
          final int eachBookHit = i.value.length;
          pieChartDataMap[bookAbb] = eachBookHit.toDouble();
          bookBarChartData.add(ChartsFlutterDatum(x: i.key, y: eachBookHit));
        }
        final String searchOverview =
            "$lastBibleSearchModule [$lastBibleSearchHit]";
        return (lastSearchResultsLazy.isEmpty)
            ? Center(
                child: Text("No search result!"),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Center(
                          child: Text(
                        (lastBibleSearchExclusionEntry.isEmpty)
                            ? lastBibleSearchEntry
                            : "$lastBibleSearchEntry (${context.read(interfaceAppP).state[37]}$lastBibleSearchExclusionEntry)",
                        style: context.read(myTextStyleP).state["verseFont"],
                      )),
                      subtitle: Center(
                          child: Text(
                        "${context.read(interfaceAppP).state[36]}$lastBibleSearchEntryOption",
                        style:
                            context.read(myTextStyleP).state["subtitleStyle"],
                      )),
                    ),
                    ExpansionTile(
                      leading: IconButton(
                        tooltip: "Bar chart",
                        icon: const Icon(Icons.add_chart),
                        onPressed: () async {
                          Configurations.goTo(
                              context,
                              BookBarChart(
                                  "$searchOverview: $lastBibleSearchEntry",
                                  bookBarChartData));
                        },
                      ),
                      title: Text(searchOverview),
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
                            bookList[i],
                            lastBibleSearchEntry,
                            lastSearchResults[bookList[i]].length,
                            lastSearchResults[bookList[i]],
                            lastSearchResultsLazy[bookList[i]])),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildBookSection(int bookNo, String lastBibleSearchEntry, int allHits,
      List<List<dynamic>> data, List<List<dynamic>> dataLazy) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        final String bookName = parser.standardBookname[bookNo.toString()];
        final String chapterOverview = "$bookName [$allHits]";
        return ExpansionTile(
          leading: IconButton(
            tooltip: "Bar chart",
            icon: const Icon(Icons.add_chart),
            onPressed: () async {
              Map<double, double> barChartData = {};
              data.forEach((i) {
                double chapter = i.first[1].toDouble();
                barChartData[chapter] = (barChartData.containsKey(chapter))
                    ? barChartData[chapter] + 1
                    : 1;
              });
              Configurations.goTo(
                  context,
                  ChapterBarChart(
                    barChartData,
                    topTitle: "$chapterOverview: $lastBibleSearchEntry",
                    bottomTitle: context.read(interfaceAppP).state[9],
                  ));
            },
          ),
          title: Text(chapterOverview),
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
          children: <Widget>[_buildBookResult(dataLazy, bookNo)],
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

  Widget _buildVerseRow(
      BuildContext context, int i, List<dynamic> data, int bookNo) {
    if (data.isEmpty)
      return ListTile(
        title: Center(
          child: Text(
            "[Read more ...]",
          ),
        ),
        onTap: () {
          context
              .read(configProvider)
              .state
              .bibleDB1
              .updateLastBibleSearchResultsLazy(bookNo);
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
        final String lastBibleSearchEntry =
            context.read(bibleSearchDataP).state["lastBibleSearchEntry"];
        final int searchEntryOption = context.read(searchEntryOptionP).state;
        final String searchEntry = (searchEntryOption == 4)
            ? [
                for (var match
                    in RegExp(r"%(.*?)%").allMatches(lastBibleSearchEntry))
                  match.group(1)
              ].join("|")
            : lastBibleSearchEntry;
        return ListTile(
          title: ParsedText(
            selectable: true,
            alignment: TextAlign.start,
            text:
                "[${data.first[1]}:${data.first.last}]$displayVersion $verseText",
            style: myTextStyle["verseFont"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[0-9]+?:[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async =>
                    await callBack(["newVersionVerseSelected", data]),
              ),
              MatchText(
                pattern: searchEntry,
                regexOptions: RegexOptions(
                  caseSensitive: false,
                  unicode: true,
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
