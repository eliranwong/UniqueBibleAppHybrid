// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
// My libraries
import 'config.dart';
import 'bible.dart';
import 'bible_parser.dart';
import 'text_transformer.dart';
// ui
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
        final Map<int, List<List<dynamic>>> lastBibleSearchResultsParallel =
        (watch(parallelVersesP).state) ? bibleSearchData["lastBibleSearchResultsParallel"] : {};
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
                child: Consumer(builder: (context, watch, child) {
                  return Text("Search result is displayed here!", style: watch(myTextStyleP).state["subtitleStyle"],);
                }),
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
                          lastSearchResultsLazy[bookList[i]],
                          (lastBibleSearchResultsParallel.isNotEmpty) ? lastBibleSearchResultsParallel[bookList[i]] : [],
                        )
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildBookSection(int bookNo, String lastBibleSearchEntry, int allHits,
      List<List<dynamic>> data, List<List<dynamic>> dataLazy, List<List<dynamic>> dataParallel) {
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
          children: <Widget>[_buildBookResult(dataLazy, dataParallel, bookNo)],
        );
      },
    );
  }

  Widget _buildBookResult(List<List<dynamic>> data, List<List<dynamic>> dataParallel, int bookNo) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: data.length,
      itemBuilder: (context, i) => _buildVerseRow(context, i, data[i], (dataParallel.isNotEmpty) ? dataParallel[i] : [], bookNo),
    );
  }

  Widget _buildVerseRow(
      BuildContext context, int i, List<dynamic> data, List<dynamic> dataParallel, int bookNo) {
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
            (context.read(parallelVersesP).state) ? "\n[${data.last}]" : "";
        final String verseText = TextTransformer.processBibleVerseText(data[1]);
        final String verseTextParallel = (dataParallel.isEmpty) ? "" : TextTransformer.processBibleVerseText(dataParallel[1]);
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
              MatchText(
                pattern: searchEntry,
                regexOptions: RegexOptions(
                  caseSensitive: false,
                  unicode: true,
                ),
                style: TextStyle(backgroundColor: Colors.red[300]),
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
            text:
                "[${data.first[1]}:${data.first.last}]$displayVersion $verseText",
            style: myTextStyle["verseFont"],
            parse: <MatchText>[
              MatchText(
                pattern: r"\[[A-Za-z0-9]+? [0-9\-:]+?\]|\[[A-Z][A-Z]+?[a-z]*?[0-9]*?\]|\[[^A-Za-z]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async => await callBack(["newVersionVerseSelected", data]),
              ),
              /*MatchText(
                pattern: r"\[[0-9]+?:[0-9]+?\]",
                style: myTextStyle["verseNoFont"],
                onTap: (url) async =>
                    await callBack(["newVersionVerseSelected", data]),
              ),*/
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
