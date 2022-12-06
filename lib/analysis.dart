/// Example of a time series chart using a bar renderer.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class TimeSeriesBar extends StatelessWidget {
  final List<charts.Series<TimeSeriesSales, DateTime>> seriesList;
  final bool animate;

  TimeSeriesBar(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: new charts.TimeSeriesChart(
          seriesList,
          animate: animate,
          // Set the default renderer to a bar renderer.
          // This can also be one of the custom renderers of the time series chart.
          defaultRenderer: new charts.BarRendererConfig<DateTime>(),
          // It is recommended that default interactions be turned off if using bar
          // renderer, because the line point highlighter is the default for time
          // series chart.
          defaultInteractions: false,
          // If default interactions were removed, optionally add select nearest
          // and the domain highlighter that are typical for bar charts.
          behaviors: [
            new charts.SelectNearest(),
            new charts.DomainHighlighter()
          ],
        ),
      ),
    );
  }

  /// Create one series with sample hard coded data.

}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
