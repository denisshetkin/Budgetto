import 'dart:math';

import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/gradient_icon.dart';
import '../widgets/soft_card.dart';

enum OverviewRange { day, week, month, year, period }

enum OverviewChart { pie, bars }

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  OverviewRange _range = OverviewRange.month;
  DateTimeRange? _customRange;
  TransactionType _type = TransactionType.expense;
  OverviewChart _chart = OverviewChart.pie;
  DateTime _anchorDate = DateTime.now();

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialRange =
        _customRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
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

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final day = _startOfDay(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month);

  DateTime _startOfYear(DateTime date) => DateTime(date.year);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  DateTime _endOfWeek(DateTime start) =>
      DateTime(start.year, start.month, start.day + 6, 23, 59, 59, 999);

  DateTime _endOfMonth(DateTime start) =>
      DateTime(start.year, start.month + 1, 0, 23, 59, 59, 999);

  DateTime _endOfYear(DateTime start) =>
      DateTime(start.year, 12, 31, 23, 59, 59, 999);

  DateTime _periodKey(DateTime date, OverviewRange range) {
    switch (range) {
      case OverviewRange.day:
        return _startOfDay(date);
      case OverviewRange.week:
        return _startOfWeek(date);
      case OverviewRange.month:
        return _startOfMonth(date);
      case OverviewRange.year:
        return _startOfYear(date);
      case OverviewRange.period:
        final customRange = _customRange;
        if (customRange == null) {
          return _startOfDay(DateTime.now());
        }
        return _startOfDay(customRange.start);
    }
  }

  DateTime _shiftPeriodStart(DateTime date, OverviewRange range, int delta) {
    switch (range) {
      case OverviewRange.day:
        return _startOfDay(date).add(Duration(days: delta));
      case OverviewRange.week:
        return _startOfWeek(date).add(Duration(days: 7 * delta));
      case OverviewRange.month:
        final start = _startOfMonth(date);
        return DateTime(start.year, start.month + delta);
      case OverviewRange.year:
        final start = _startOfYear(date);
        return DateTime(start.year + delta);
      case OverviewRange.period:
        return date;
    }
  }

  void _movePeriod(int delta) {
    if (_range == OverviewRange.period) {
      return;
    }
    final nextAnchor = _shiftPeriodStart(_anchorDate, _range, delta);
    final currentKey = _periodKey(DateTime.now(), _range);
    final nextKey = _periodKey(nextAnchor, _range);
    if (delta > 0 && nextKey.isAfter(currentKey)) {
      return;
    }
    setState(() {
      _anchorDate = nextAnchor;
    });
  }

  bool _canMoveForward() {
    if (_range == OverviewRange.period) {
      return false;
    }
    final currentKey = _periodKey(DateTime.now(), _range);
    final selectedKey = _periodKey(_anchorDate, _range);
    return selectedKey.isBefore(currentKey);
  }

  DateTimeRange _resolveRange() {
    switch (_range) {
      case OverviewRange.day:
        final start = _startOfDay(_anchorDate);
        return DateTimeRange(start: start, end: _endOfDay(start));
      case OverviewRange.week:
        final start = _startOfWeek(_anchorDate);
        return DateTimeRange(start: start, end: _endOfWeek(start));
      case OverviewRange.month:
        final start = _startOfMonth(_anchorDate);
        return DateTimeRange(start: start, end: _endOfMonth(start));
      case OverviewRange.year:
        final start = _startOfYear(_anchorDate);
        return DateTimeRange(start: start, end: _endOfYear(start));
      case OverviewRange.period:
        final now = DateTime.now();
        final range =
            _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            );
        return DateTimeRange(
          start: DateTime(range.start.year, range.start.month, range.start.day),
          end: DateTime(
            range.end.year,
            range.end.month,
            range.end.day,
            23,
            59,
            59,
            999,
          ),
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
    const horizontalInset = 12.0;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Обзор',
              padding: const EdgeInsets.fromLTRB(
                horizontalInset,
                12,
                horizontalInset,
                8,
              ),
              leading: GradientIcon(
                icon: Icons.pie_chart,
                size: 32,
                colors: [
                  AppColors.accentIncome,
                  AppColors.accentTotal,
                  AppColors.accentExpense,
                ],
              ),
              actions: [
                SegmentedButton<TransactionType>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return accent.withValues(alpha: 0.22);
                      }
                      return AppColors.surface1;
                    }),
                    textStyle: WidgetStatePropertyAll(
                      Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    padding: WidgetStatePropertyAll(
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    minimumSize: WidgetStatePropertyAll(const Size(0, 36)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: AppColors.stroke),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Расходы'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Доходы'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  horizontalInset,
                  12,
                  horizontalInset,
                  20,
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: InkWell(
                            onTap: _range == OverviewRange.period
                                ? _pickCustomRange
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: SoftCard(
                              padding: const EdgeInsets.only(
                                left: 2,
                                right: 14,
                              ),
                              child: Row(
                                children: [
                                  _PeriodArrowButton(
                                    icon: Icons.chevron_left_rounded,
                                    onTap: _range == OverviewRange.period
                                        ? null
                                        : () => _movePeriod(-1),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      rangeLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  if (_range == OverviewRange.period)
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textSecondary,
                                      size: 22,
                                    )
                                  else
                                    _PeriodArrowButton(
                                      icon: Icons.chevron_right_rounded,
                                      offsetX: -2,
                                      onTap: _canMoveForward()
                                          ? () => _movePeriod(1)
                                          : null,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 123,
                        height: 54,
                        child: SoftCard(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<OverviewRange>(
                              value: _range,
                              isExpanded: true,
                              isDense: true,
                              icon: const Icon(
                                Icons.expand_more_rounded,
                                size: 18,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: OverviewRange.day,
                                  child: Text(
                                    'День',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: OverviewRange.week,
                                  child: Text(
                                    'Неделя',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: OverviewRange.month,
                                  child: Text(
                                    'Месяц',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: OverviewRange.year,
                                  child: Text(
                                    'Год',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: OverviewRange.period,
                                  child: Text(
                                    'Период',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (next) {
                                if (next == null) {
                                  return;
                                }
                                setState(() {
                                  _range = next;
                                  if (next != OverviewRange.period) {
                                    _anchorDate = _periodKey(_anchorDate, next);
                                  }
                                });
                                if (next == OverviewRange.period) {
                                  _pickCustomRange();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SegmentedButton<OverviewChart>(
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              padding: WidgetStatePropertyAll(
                                const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                              ),
                              minimumSize: WidgetStatePropertyAll(
                                const Size(32, 28),
                              ),
                              backgroundColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.surface2;
                                }
                                return Colors.transparent;
                              }),
                              side: WidgetStatePropertyAll(
                                BorderSide(color: AppColors.stroke, width: 1),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            segments: const [
                              ButtonSegment(
                                value: OverviewChart.pie,
                                label: Icon(Icons.pie_chart_outline, size: 16),
                              ),
                              ButtonSegment(
                                value: OverviewChart.bars,
                                label: Icon(Icons.bar_chart, size: 16),
                              ),
                            ],
                            selected: {_chart},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _chart = selection.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: _chart == OverviewChart.pie
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _OverviewPieChart(
                                      slices: slices,
                                      emptyColor: AppColors.surface2,
                                      strokeColor: AppColors.stroke,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Итого',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatAmount(total, symbol),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: accent,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : _OverviewBarChart(
                                  slices: slices,
                                  emptyColor: AppColors.surface2,
                                  strokeColor: AppColors.stroke,
                                ),
                        ),
                        const SizedBox(height: 16),
                        if (slices.isEmpty)
                          Text(
                            'Нет операций за выбранный период.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          )
                        else
                          Column(
                            children: slices
                                .map(
                                  (slice) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _CategoryRow(
                                      title: slice.name,
                                      amount: _formatAmount(
                                        slice.amount,
                                        symbol,
                                      ),
                                      percent: slice.percent,
                                      color: slice.color,
                                      icon: slice.icon,
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
          icon: entry.categoryIcon,
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
    switch (_range) {
      case OverviewRange.day:
        return _formatDate(range.start, includeYear: true);
      case OverviewRange.week:
        final startLabel = _formatDate(range.start, includeYear: false);
        final endLabel = _formatDate(range.end, includeYear: true);
        return '$startLabel - $endLabel';
      case OverviewRange.month:
        return _formatMonthYear(range.start);
      case OverviewRange.year:
        return range.start.year.toString();
      case OverviewRange.period:
        final start = range.start;
        final end = range.end;
        final startLabel = _formatDate(
          start,
          includeYear: start.year != end.year,
        );
        final endLabel = _formatDate(end, includeYear: true);
        return '$startLabel - $endLabel';
    }
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

  String _formatMonthYear(DateTime date) {
    const months = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatAmount(double amount, String symbol) {
    final rounded = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return symbol.isEmpty ? rounded : '$rounded $symbol';
  }
}

class _OverviewPieChart extends StatelessWidget {
  const _OverviewPieChart({
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

class _OverviewBarChart extends StatelessWidget {
  const _OverviewBarChart({
    required this.slices,
    required this.emptyColor,
    required this.strokeColor,
  });

  final List<_OverviewSlice> slices;
  final Color emptyColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    const height = 220.0;
    final bars = slices.isEmpty
        ? const <_OverviewSlice>[
            _OverviewSlice(
              id: 'empty_1',
              name: '',
              amount: 1,
              color: Color(0x00000000),
              icon: Icons.circle,
              percent: 0.6,
            ),
            _OverviewSlice(
              id: 'empty_2',
              name: '',
              amount: 1,
              color: Color(0x00000000),
              icon: Icons.circle,
              percent: 0.4,
            ),
            _OverviewSlice(
              id: 'empty_3',
              name: '',
              amount: 1,
              color: Color(0x00000000),
              icon: Icons.circle,
              percent: 0.8,
            ),
            _OverviewSlice(
              id: 'empty_4',
              name: '',
              amount: 1,
              color: Color(0x00000000),
              icon: Icons.circle,
              percent: 0.5,
            ),
          ]
        : slices;

    final maxPercent = bars
        .map((bar) => bar.percent)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final normalizedMax = maxPercent == 0 ? 1.0 : maxPercent;
    const horizontalPadding = 14.0;
    const spacing = 10.0;
    const minBarWidth = 28.0;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              bars.length * minBarWidth +
              (bars.length - 1) * spacing +
              horizontalPadding * 2;
          final chartWidth = max(constraints.maxWidth, contentWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: bars.length > 6
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: chartWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: strokeColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < bars.length; i++) ...[
                        SizedBox(
                          width: minBarWidth,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height:
                                  (bars[i].percent / normalizedMax) *
                                  (height - 32),
                              decoration: BoxDecoration(
                                color: slices.isEmpty
                                    ? emptyColor
                                    : bars[i].color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        if (i != bars.length - 1)
                          const SizedBox(width: spacing),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodArrowButton extends StatelessWidget {
  const _PeriodArrowButton({
    required this.icon,
    required this.onTap,
    this.offsetX = 0,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double offsetX;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? AppColors.textSecondary.withValues(alpha: 0.35)
        : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 20,
        height: 32,
        child: Center(
          child: Transform.translate(
            offset: Offset(offsetX, 0),
            child: Icon(icon, size: 34, color: color),
          ),
        ),
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
    required this.icon,
  });

  final String title;
  final String amount;
  final double percent;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final percentLabel = (percent * 100).toStringAsFixed(0);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.stroke, width: 1),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '$percentLabel%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    required this.icon,
    this.percent = 0,
  });

  final String id;
  final String name;
  final double amount;
  final Color color;
  final IconData icon;
  final double percent;

  _OverviewSlice copyWith({double? amount, double? percent}) {
    return _OverviewSlice(
      id: id,
      name: name,
      amount: amount ?? this.amount,
      color: color,
      icon: icon,
      percent: percent ?? this.percent,
    );
  }
}
