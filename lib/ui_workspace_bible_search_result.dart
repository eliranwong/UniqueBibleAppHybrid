// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:unique_bible_app_expanded/bible_parser.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
// My libraries
import 'config.dart';
import 'bible.dart';

class BibleSearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        final int lastBibleSearchHit = watch(lastBibleSearchHitP).state;
        final String lastBibleSearchEntry = watch(lastBibleSearchEntryP).state;
        final Map<int, List<List<dynamic>>> lastSearchResults =
            watch(lastBibleSearchResultsP).state;
        final Map<int, List<List<dynamic>>> lastSearchResultsLazy =
            watch(lastBibleSearchResultsLazyP).state;
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
        title: Text(
          "[Read more ...]",
        ),
        onTap: () {
          context.read(configProvider).state.bibleDB1.updateLastBibleSearchResultsLazy(bookNo);
          context.refresh(lastBibleSearchResultsLazyP);
        },
        onLongPress: () {
          print("long press");
        },
      );
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final TextStyle verseStyle = myTextStyle["verseFont"];
        final String displayVersion =
            (context.read(parallelVersesP).state) ? " [${data.last}]" : "";
        String verseText = Bible.processVerseText(data[1]);
        return ListTile(
          title: DynamicTextHighlighting(
            text: "[${data.first.last}]$displayVersion $verseText",
            highlights: context.read(lastBibleSearchEntryP).state.split("|"),
            color: Colors.redAccent,
            style: verseStyle,
            caseSensitive: false,
          ),
          onTap: () async {
            print("tap action");
          },
          onLongPress: () {
            print("long press");
          },
        );
      },
    );
  }

}
