// Packages
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:unique_bible_app_expanded/bible_parser.dart';
import 'package:pie_chart/pie_chart.dart';
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
        final List<int> bookList = lastSearchResults.keys.toList()..sort();
        Map<String, double> pieChartDataMap = {
          for (MapEntry i in lastSearchResults.entries)
            parser.standardAbbreviation[i.key.toString()]: i.value.length.toDouble()
        };
        return SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                title: Text((pieChartDataMap.isEmpty)
                    ? "No search result!"
                    : "$lastBibleSearchEntry x $lastBibleSearchHit"),
                children: [
                  (pieChartDataMap.isEmpty)
                      ? Container()
                      : PieChart(
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
                      bookList[i], lastSearchResults[bookList[i]])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookSection(int bookNo, List<List<dynamic>> data) {
    return Consumer(
      builder: (context, watch, child) {
        final BibleParser parser = watch(parserP).state;
        return ExpansionTile(
          title: Text(
              "${parser.standardBookname[bookNo.toString()]} [${data.length}]"),
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
          children: <Widget>[_buildBookResult(data)],
        );
      },
    );
  }

  Widget _buildBookResult(List<List<dynamic>> data) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: data.length,
      itemBuilder: (context, i) => _buildVerseRow(context, i, data[i]),
    );
  }

  Widget _buildVerseRow(BuildContext context, int i, List<dynamic> data) {
    return Consumer(
      builder: (context, watch, child) {
        final Map<String, TextStyle> myTextStyle = watch(myTextStyleP).state;
        final TextStyle verseStyle = myTextStyle["verseFont"];
        final String displayVersion =
            (context.read(parallelVersesP).state) ? " [${data.last}]" : "";
        String verseText = Bible.processVerseText(data[1]);
        return ListTile(
          title: Text(
            "[${data.first.last}]$displayVersion $verseText",
            style: verseStyle,
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
