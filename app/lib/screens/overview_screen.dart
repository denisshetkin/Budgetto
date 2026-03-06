import 'dart:math';

import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

enum OverviewRange { day, week, month, year, period }

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  OverviewRange _range = OverviewRange.month;
  DateTimeRange? _customRange;
  TransactionType _type = TransactionType.expense;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialRange =
        _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: initialRange,
      helpText: 'Выберите период',
      saveText: 'Готово',
      cancelText: 'Отмена',
    );

    if (!mounted) {
      return;
    }

    if (picked == null) {
      if (_customRange == null) {
        setState(() {
          _range = OverviewRange.month;
        });
      }
      return;
    }

    setState(() {
      _customRange = picked;
      _range = OverviewRange.period;
    });
  }

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    switch (_range) {
      case OverviewRange.day:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: now);
      case OverviewRange.week:
        final weekday = now.weekday;
        final start = now.subtract(Duration(days: weekday - DateTime.monday));
        return DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: now,
        );
      case OverviewRange.month:
        return DateTimeRange(start: DateTime(now.year, now.month), end: now);
      case OverviewRange.year:
        return DateTimeRange(start: DateTime(now.year), end: now);
      case OverviewRange.period:
        final range = _customRange ??
            DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
        return DateTimeRange(
          start: DateTime(range.start.year, range.start.month, range.start.day),
          end: DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59, 999),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final symbol = appState.currencySymbol();
    final range = _resolveRange();
    final accent = _type == TransactionType.expense
        ? AppColors.accentExpense
        : AppColors.accentIncome;
    final slices = _buildSlices(appState.transactions, range, _type, accent);
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.amount);
    final rangeLabel = _formatRange(range);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Обзор'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SegmentedButton<OverviewRange>(
                    segments: const [
                      ButtonSegment(value: OverviewRange.day, label: Text('День')),
                      ButtonSegment(value: OverviewRange.week, label: Text('Неделя')),
                      ButtonSegment(value: OverviewRange.month, label: Text('Месяц')),
                      ButtonSegment(value: OverviewRange.year, label: Text('Год')),
                      ButtonSegment(value: OverviewRange.period, label: Text('Период')),
                    ],
                    selected: {_range},
                    onSelectionChanged: (selection) {
                      final next = selection.first;
                      setState(() {
                        _range = next;
                      });
                      if (next == OverviewRange.period) {
                        _pickCustomRange();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _range == OverviewRange.period ? _pickCustomRange : null,
                    borderRadius: BorderRadius.circular(16),
                    child: SoftCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.date_range_outlined, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rangeLabel,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (_range == OverviewRange.period)
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(value: TransactionType.expense, label: Text('Расходы')),
                      ButtonSegment(value: TransactionType.income, label: Text('Доходы')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _type = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _type == TransactionType.expense
                              ? 'Структура расходов'
                              : 'Структура доходов',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              OverviewPieChart(
                                slices: slices,
                                emptyColor: AppColors.surface2,
                                strokeColor: AppColors.stroke,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Итого',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatAmount(total, symbol),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: accent,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (slices.isEmpty)
                          Text(
                            'Нет операций за выбранный период.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          )
                        else
                          Column(
                            children: slices
                                .map(
                                  (slice) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _CategoryRow(
                                      title: slice.name,
                                      amount: _formatAmount(slice.amount, symbol),
                                      percent: slice.percent,
                                      color: slice.color,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_OverviewSlice> _buildSlices(
    List<TransactionEntry> entries,
    DateTimeRange range,
    TransactionType type,
    Color accent,
  ) {
    final totals = <String, _OverviewSlice>{};
    for (final entry in entries) {
      if (entry.type != type) {
        continue;
      }
      if (entry.date.isBefore(range.start) || entry.date.isAfter(range.end)) {
        continue;
      }
      final existing = totals[entry.categoryId];
      final baseColor = _blendWithAccent(entry.categoryColor, accent);
      if (existing == null) {
        totals[entry.categoryId] = _OverviewSlice(
          id: entry.categoryId,
          name: entry.categoryName,
          amount: entry.amount,
          color: baseColor,
        );
      } else {
        totals[entry.categoryId] = existing.copyWith(
          amount: existing.amount + entry.amount,
        );
      }
    }
    final list = totals.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final total = list.fold<double>(0, (sum, slice) => sum + slice.amount);
    if (total == 0) {
      return [];
    }
    return list
        .map((slice) => slice.copyWith(percent: slice.amount / total))
        .toList();
  }

  Color _blendWithAccent(Color base, Color accent) {
    return Color.lerp(base, accent, 0.35) ?? base;
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    final startLabel = _formatDate(start, includeYear: start.year != end.year);
    final endLabel = _formatDate(end, includeYear: true);
    return '$startLabel — $endLabel';
  }

  String _formatDate(DateTime date, {required bool includeYear}) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    if (!includeYear) {
      return '$day $month';
    }
    return '$day $month ${date.year}';
  }

  String _formatAmount(double amount, String symbol) {
    final rounded =
        amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return symbol.isEmpty ? rounded : '$rounded $symbol';
  }
}

class OverviewPieChart extends StatelessWidget {
  const OverviewPieChart({
    super.key,
    required this.slices,
    required this.emptyColor,
    required this.strokeColor,
  });

  final List<_OverviewSlice> slices;
  final Color emptyColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(220),
      painter: _PieChartPainter(
        slices: slices,
        emptyColor: emptyColor,
        strokeColor: strokeColor,
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.slices,
    required this.emptyColor,
    required this.strokeColor,
  });

  final List<_OverviewSlice> slices;
  final Color emptyColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;

    if (slices.isEmpty) {
      paint.color = emptyColor;
      canvas.drawCircle(center, radius, paint);
    } else {
      var start = -pi / 2;
      for (final slice in slices) {
        final sweep = slice.percent * 2 * pi;
        paint.color = slice.color;
        canvas.drawArc(rect, start, sweep, true, paint);
        start += sweep;
      }
    }

    paint
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, paint);

    paint
      ..color = AppColors.surface1
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.62, paint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.emptyColor != emptyColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.amount,
    required this.percent,
    required this.color,
  });

  final String title;
  final String amount;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentLabel = (percent * 100).toStringAsFixed(0);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '$percentLabel%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _OverviewSlice {
  const _OverviewSlice({
    required this.id,
    required this.name,
    required this.amount,
    required this.color,
    this.percent = 0,
  });

  final String id;
  final String name;
  final double amount;
  final Color color;
  final double percent;

  _OverviewSlice copyWith({double? amount, double? percent}) {
    return _OverviewSlice(
      id: id,
      name: name,
      amount: amount ?? this.amount,
      color: color,
      percent: percent ?? this.percent,
    );
  }
}
