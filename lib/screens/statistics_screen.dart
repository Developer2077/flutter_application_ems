import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/savings_model.dart';
import '../services/history_service.dart';

/// Schermata Statistiche (punto 4): storico produzione + calcolo risparmio.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final HistoryService _history = HistoryService();
  List<DailyRecord> _weekRecords = [];
  List<DailyRecord> _monthRecords = [];
  SavingsModel _weekSavings = SavingsModel.zero;
  SavingsModel _monthSavings = SavingsModel.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final week = await _history.getHistory(days: 7);
    final month = await _history.getHistory(days: 30);
    final weekSav = await _history.getCumulativeSavings(days: 7);
    final monthSav = await _history.getCumulativeSavings(days: 30);
    if (!mounted) return;
    setState(() {
      _weekRecords = week;
      _monthRecords = month;
      _weekSavings = weekSav;
      _monthSavings = monthSav;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        _HeaderBanner(strings: strings, theme: theme),
        const SizedBox(height: 16),

        // Risparmio settimanale
        _SavingsCard(
          strings: strings,
          title: strings.weeklySavings,
          savings: _weekSavings,
        ),
        const SizedBox(height: 12),

        // Risparmio mensile
        _SavingsCard(
          strings: strings,
          title: strings.monthlySavings,
          savings: _monthSavings,
        ),
        const SizedBox(height: 16),

        // Grafico settimanale
        _ChartCard(
          title: strings.weeklyChart,
          records: _weekRecords,
          strings: strings,
        ),
        const SizedBox(height: 16),

        // Grafico mensile
        if (_monthRecords.length > 7)
          _ChartCard(
            title: strings.monthlyChart,
            records: _monthRecords,
            strings: strings,
          ),

        if (_weekRecords.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _EmptyCard(strings: strings),
          ),
      ],
    );
  }
}

// ── Header ──
class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.strings, required this.theme});
  final AppStrings strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: strings.statisticsTitle,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.primaryContainer,
          border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
        ),
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.statisticsTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(strings.statisticsSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.bar_chart_outlined,
                size: 46, color: theme.colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}

// ── Card risparmio ──
class _SavingsCard extends StatelessWidget {
  const _SavingsCard({
    required this.strings,
    required this.title,
    required this.savings,
  });
  final AppStrings strings;
  final String title;
  final SavingsModel savings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: ${savings.savedEuros.toStringAsFixed(2)} euro, ${savings.avoidedCo2Kg.toStringAsFixed(1)} kg CO2',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SavingsTile(
                    icon: Icons.bolt_outlined,
                    label: 'kWh',
                    value: savings.selfConsumedKwh.toStringAsFixed(1),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _SavingsTile(
                    icon: Icons.euro_outlined,
                    label: strings.savedLabel,
                    value: '€${savings.savedEuros.toStringAsFixed(2)}',
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 12),
                  _SavingsTile(
                    icon: Icons.eco_outlined,
                    label: 'CO₂',
                    value: '${savings.avoidedCo2Kg.toStringAsFixed(1)} kg',
                    color: const Color(0xFF00695C),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingsTile extends StatelessWidget {
  const _SavingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Grafico a barre ──
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.records,
    required this.strings,
  });
  final String title;
  final List<DailyRecord> records;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (records.isEmpty) return const SizedBox.shrink();

    final maxY = records
            .map((r) => r.averageRadiation)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY == 0 ? 100 : maxY,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gi, rod, ri) {
                        final rec = records[group.x];
                        return BarTooltipItem(
                          '${rec.date.substring(5)}\n${rec.averageRadiation.toStringAsFixed(0)} W/m²',
                          TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= records.length) {
                            return const SizedBox.shrink();
                          }
                          final day = records[idx].date.substring(8);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(day,
                                style: theme.textTheme.bodySmall),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(records.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: records[i].averageRadiation,
                          width: records.length > 14 ? 8 : 18,
                          borderRadius: BorderRadius.circular(6),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(strings.chartUnit,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

// ── Card vuota ──
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(strings.noHistoryYet,
                  style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
