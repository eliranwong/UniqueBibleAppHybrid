import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:charts_flutter/flutter.dart' as charts;
//import 'package:graphic/graphic.dart' as graphic;
import 'config.dart';

class ChartsFlutterDatum {
  final int x;
  final int y;
  charts.Color barColor;
  ChartsFlutterDatum({
    @required this.x,
    @required this.y,
  }) {
    if (x < 40) {
      barColor = charts.ColorUtil.fromDartColor(Colors.lightBlue);
    } else if ((x >= 40) && (x <= 66)) {
      barColor = charts.ColorUtil.fromDartColor(Colors.purple);
    } else {
      barColor = charts.ColorUtil.fromDartColor(Colors.yellow);
    }
  }
}

class BookBarChart extends StatelessWidget {
  // reference: https://medium.com/flutter-community/flutter-charts-and-graphs-demystified-72b1282e6882

  final String chartTitle;
  final List<ChartsFlutterDatum> bookBarChartData;

  BookBarChart(this.chartTitle, this.bookBarChartData);

  List<charts.Series<ChartsFlutterDatum, String>> _getSeriesData(
      Map<String, String> standardAbbreviation) {
    List<charts.Series<ChartsFlutterDatum, String>> series = [
      charts.Series(
          id: "Search Result Distribution",
          data: bookBarChartData,
          domainFn: (ChartsFlutterDatum series, _) =>
              standardAbbreviation[series.x.toString()],
          measureFn: (ChartsFlutterDatum series, _) => series.y,
          colorFn: (ChartsFlutterDatum series, _) => series.barColor)
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.read(mainThemeP).state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.read(interfaceAppP).state[35]),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            height: 400,
            padding: EdgeInsets.all(10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      chartTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.read(myColorsP).state["black"]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: charts.BarChart(
                        _getSeriesData(
                            context.read(parserP).state.standardAbbreviation),
                        animate: true,
                        domainAxis: charts.OrdinalAxisSpec(
                            renderSpec:
                            charts.SmallTickRendererSpec(labelRotation: 60)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChapterBarChart extends StatelessWidget {
  final Map<double, double> data;
  final String topTitle, leftTitle, bottomTitle;
  final int increment;

  ChapterBarChart(this.data,
      {this.topTitle = "",
      this.leftTitle = "",
      this.bottomTitle = "",
      this.increment = 1});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.read(mainThemeP).state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.read(interfaceAppP).state[35]),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            height: 400,
            padding: EdgeInsets.all(10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      topTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.read(myColorsP).state["black"]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: _buildBarChart(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final barGroups = <BarChartGroupData>[
      for (final entry in data.entries)
        BarChartGroupData(
          x: entry.key.toInt(),
          barRods: [
            BarChartRodData(y: entry.value, colors: [Colors.blue]),
            //BarChartRodData(y: data2[entry.key], colors: [Colors.red]),
          ],
        ),
    ];

    final barChartData = BarChartData(
      //maxY: 25,
      // ! The data to show
      barGroups: barGroups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.indigoAccent,
        ),
      ),
      // ! Borders:
      borderData: FlBorderData(
          show: true,
          border: Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide.none,
              bottom: BorderSide())),
      // ! Grid behavior:
      gridData: FlGridData(show: true),
      // ! Axis title
      axisTitleData: FlAxisTitleData(
        show: true,
        topTitle:
            AxisTitle(titleText: topTitle, showTitle: false),
        leftTitle:
            AxisTitle(titleText: leftTitle, showTitle: (leftTitle.isNotEmpty)),
        bottomTitle: AxisTitle(
            titleText: bottomTitle, showTitle: (bottomTitle.isNotEmpty)),
      ),
      // ! Ticks in the axis
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true, // this is false by-default.
          // ! Decides how to show bottom titles,
          // here we convert double to month names
          getTitles: (double val) => val.toInt().toString(),
        ),
        leftTitles: SideTitles(
          showTitles: true,
          // ! Decides how to show left titles,
          // here we skip some values by returning ''.
          getTitles: (double val) {
            if (val.toInt() % increment != 0) return '';
            return '${val.toInt()}';
          },
        ),
      ),
    );
    return Center(
      child: BarChart(barChartData),
    );
  }
}

/*
class TestGraphic extends StatelessWidget {

  final List<Map<String, dynamic>> data;
  TestGraphic(this.data);

  @override
  Widget build(BuildContext context) {
    return graphic.Chart(
      data: data,
      scales: {
        "x": graphic.CatScale(
          accessor: (map) => map["x"] as String,
        ),
        "y": graphic.LinearScale(
          accessor: (map) => map["y"] as num,
          nice: true,
        )
      },
      geoms: [graphic.IntervalGeom(
        position: graphic.PositionAttr(field: 'x*y'),
      )],
      axes: {
        "x": graphic.Defaults.horizontalAxis,
        "y": graphic.Defaults.verticalAxis,
      },
    );
  }

}*/
