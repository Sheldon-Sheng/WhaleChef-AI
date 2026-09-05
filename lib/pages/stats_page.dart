// lib/pages/stats_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../l10n/app_localizations.dart';

/// 「统计」页：每周累积卡路里柱状图（X=周起始(周一)~周止(周日)，Y=该周卡路里合计）。
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<({int weekStart, double total})> _weekly = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await LocalDB().getWeeklyCalories();
    if (!mounted) return;
    setState(() => _weekly = rows);
  }

  String _labelForWeek(int index) {
    if (index < 0 || index >= _weekly.length) return '';
    final start = DateTime.fromMillisecondsSinceEpoch(_weekly[index].weekStart);
    // 周一 = 起点，本周结束 = 起点 + 6 天
    final end = DateTime(start.year, start.month, start.day + 6);
    final fmt = DateFormat('yyyy/M/d');
    return '${fmt.format(start)}~${fmt.format(end)}';
  }

  /// 图表宽度：数据多时超出屏宽，允许横向滚动
  double _chartWidth(BuildContext context) {
    final screenW =
        MediaQuery.of(context).size.width - 32; // ListView 左右 padding
    final neededW = _weekly.length * 48.0;
    return neededW > screenW ? neededW : screenW;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxTotal = _weekly.fold<double>(
      0,
      (m, e) => e.total > m ? e.total : m,
    );
    // fl_chart 要求 maxY > 0；保留一点顶部留白
    final maxY = (maxTotal * 1.15).clamp(1.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _weekly.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(child: Text(l10n.statsEmpty)),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l10n.statsTitle} (${l10n.statsCaloriesUnit})',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 340,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _chartWidth(context),
                        child: BarChart(
                          BarChartData(
                            maxY: maxY,
                            alignment: BarChartAlignment.spaceAround,
                            gridData: const FlGridData(drawVerticalLine: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) => Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _labelForWeek(value.toInt()),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 44,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            barGroups: [
                              for (var i = 0; i < _weekly.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _weekly[i].total,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
