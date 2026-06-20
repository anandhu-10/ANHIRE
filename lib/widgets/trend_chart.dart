import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendChart extends StatelessWidget {
  final List<double> dataPoints;
  final String title;
  final Color lineColor;

  const TrendChart({
    super.key,
    required this.dataPoints,
    required this.title,
    this.lineColor = const Color(0xFF6366F1),
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("No trend data available")),
      );
    }

    // Map points to FlSpots
    final List<FlSpot> spots = [];
    for (int i = 0; i < dataPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPoints[i]));
    }

    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final gridLineColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.08);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: false,
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.08),
                      strokeWidth: 1.2,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            color: onSurfaceColor.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          );
                          switch (value.toInt()) {
                            case 0:
                              return Text('JAN', style: style);
                            case 1:
                              return Text('FEB', style: style);
                            case 2:
                              return Text('MAR', style: style);
                            case 3:
                              return Text('APR', style: style);
                            case 4:
                              return Text('MAY', style: style);
                            case 5:
                              return Text('JUN', style: style);
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Hide left Y-axis labels like the mockup
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isLatest = index == barData.spots.length - 1;
                          return FlDotCirclePainter(
                            radius: isLatest ? 6 : 4,
                            color: Colors.white,
                            strokeWidth: isLatest ? 4 : 2,
                            strokeColor: isLatest ? const Color(0xFF8B5CF6) : Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.24),
                            Theme.of(context).colorScheme.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
