import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/daily_step_summary.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import '../services/statistics_service.dart';

const _background = Color(0xFF0B0F10);
const _cardColor = Color(0xFF101415);
const _cardGlass = Color(0xE6101415);
const _lineColor = Color(0x243BEA72);
const _lime = Color(0xFFB6FF00);
const _green = Color(0xFF35F46E);
const _cyan = Color(0xFF39F6D2);
const _textMuted = Color(0xFFC8D0C5);
const _textDim = Color(0xFF7F8A82);

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<_StatisticsData> _loadStatistics() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _StatisticsData.empty();
    }

    final statisticsService = StatisticsService();
    final routeService = RouteService();

    final today = DateTime.now();

    final weeklySummaries = await statisticsService.calculateWeeklySummary(
      userId: user.uid,
      selectedDate: today,
    );

    final routes = await routeService.getUserRoutes(user.uid);

    final totalSteps = weeklySummaries.fold<int>(
      0,
          (total, item) => total + item.totalSteps,
    );

    final totalCalories = weeklySummaries.fold<double>(
      0,
          (total, item) => total + item.calories,
    );

    final totalDistanceKm = weeklySummaries.fold<double>(
      0,
          (total, item) => total + item.distanceKm,
    );

    final totalDurationSeconds = weeklySummaries.fold<int>(
      0,
          (total, item) => total + item.durationSeconds,
    );

    final totalGoal = weeklySummaries.fold<int>(
      0,
          (total, item) => total + item.stepGoal,
    );

    final completedGoalDays = weeklySummaries
        .where((item) => item.totalSteps >= item.stepGoal && item.stepGoal > 0)
        .length;

    final averageSteps = weeklySummaries.isEmpty
        ? 0
        : (totalSteps / weeklySummaries.length).round();

    return _StatisticsData(
      weeklySummaries: weeklySummaries,
      recentRoutes: routes.take(5).toList(),
      totalSteps: totalSteps,
      averageDailySteps: averageSteps,
      totalCalories: totalCalories,
      totalDistanceKm: totalDistanceKm,
      totalDurationSeconds: totalDurationSeconds,
      totalGoal: totalGoal,
      completedGoalDays: completedGoalDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StatisticsData>(
      future: _loadStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DecoratedBox(
            decoration: BoxDecoration(color: _background),
            child: Center(
              child: CircularProgressIndicator(color: _lime),
            ),
          );
        }

        if (snapshot.hasError) {
          return const DecoratedBox(
            decoration: BoxDecoration(color: _background),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Statistikat ei saanud laadida',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data ?? _StatisticsData.empty();

        return DecoratedBox(
          decoration: const BoxDecoration(color: _background),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const _StatisticsHeader(),
                const SizedBox(height: 34),
                const _TitleRow(),
                const SizedBox(height: 18),
                _WeeklyActivityCard(data: data),
                const SizedBox(height: 18),
                _MetricGrid(data: data),
                const SizedBox(height: 34),
                const _SectionTitle('Eesmärgid ja tulemused'),
                const SizedBox(height: 18),
                _BadgesStrip(data: data),
                const SizedBox(height: 34),
                const _DailyBreakdownHeader(),
                const SizedBox(height: 18),
                if (data.recentRoutes.isEmpty)
                  const _EmptyActivitiesCard()
                else
                  for (final route in data.recentRoutes) ...[
                    _ActivityTile(route: route),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatisticsData {
  const _StatisticsData({
    required this.weeklySummaries,
    required this.recentRoutes,
    required this.totalSteps,
    required this.averageDailySteps,
    required this.totalCalories,
    required this.totalDistanceKm,
    required this.totalDurationSeconds,
    required this.totalGoal,
    required this.completedGoalDays,
  });

  factory _StatisticsData.empty() {
    return const _StatisticsData(
      weeklySummaries: [],
      recentRoutes: [],
      totalSteps: 0,
      averageDailySteps: 0,
      totalCalories: 0,
      totalDistanceKm: 0,
      totalDurationSeconds: 0,
      totalGoal: 0,
      completedGoalDays: 0,
    );
  }

  final List<DailyStepSummary> weeklySummaries;
  final List<RouteModel> recentRoutes;
  final int totalSteps;
  final int averageDailySteps;
  final double totalCalories;
  final double totalDistanceKm;
  final int totalDurationSeconds;
  final int totalGoal;
  final int completedGoalDays;

  double get stepProgress {
    if (totalGoal <= 0) {
      return 0;
    }

    return (totalSteps / totalGoal).clamp(0.0, 1.0).toDouble();
  }

  bool get hasAnyActivity {
    return totalSteps > 0 || totalDistanceKm > 0 || recentRoutes.isNotEmpty;
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        const Expanded(
          child: Text(
            'RouteFit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lime,
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          color: Colors.white,
          iconSize: 28,
          tooltip: 'Seaded',
        ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nädala\naktiivsus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'SINU TEGELIKUD\nANDMED',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          radius: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _lime,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x8835F46E), blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'FIREBASE\nSÜNKROON',
                style: TextStyle(
                  color: _lime,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({
    required this.data,
  });

  final _StatisticsData data;

  @override
  Widget build(BuildContext context) {
    final chartValues = _chartValues(data.weeklySummaries);
    final days = _chartDays(data.weeklySummaries);

    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keskmised sammud päevas',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(data.averageDailySteps),
                      style: const TextStyle(
                        color: _lime,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data.completedGoalDays}/7',
                    style: const TextStyle(
                      color: _lime,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'päeva eesmärk\ntäidetud',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.hasAnyActivity
                ? 'Selle nädala andmed on arvutatud salvestatud marsruutide põhjal.'
                : 'Selle nädala kohta pole veel salvestatud marsruute.',
            style: const TextStyle(
              color: _textDim,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _ActivityChartPainter(values: chartValues),
              child: _ChartLabels(days: days),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLabels extends StatelessWidget {
  const _ChartLabels({
    required this.days,
  });

  final List<String> days;

  @override
  Widget build(BuildContext context) {
    final labels = days.isEmpty ? const ['E', 'T', 'K', 'N', 'R', 'L', 'P'] : days;
    final todayIndex = DateTime.now().weekday - 1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: List.generate(labels.length, (index) {
          return Expanded(
            child: Text(
              labels[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: index == todayIndex ? _lime : _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.data,
  });

  final _StatisticsData data;

  @override
  Widget build(BuildContext context) {
    final calorieProgress = (data.totalCalories / 3000).clamp(0.0, 1.0).toDouble();
    final distanceProgress = (data.totalDistanceKm / 20).clamp(0.0, 1.0).toDouble();

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Kalorid',
            value: _formatNumber(data.totalCalories.round()),
            subtitle: 'kcal põletatud',
            progress: calorieProgress,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _MetricCard(
            icon: Icons.location_on_outlined,
            title: 'Vahemaa',
            value: data.totalDistanceKm.toStringAsFixed(1),
            subtitle: 'km jälgitud',
            progress: distanceProgress,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(26),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _lime, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: _lime,
              backgroundColor: const Color(0xFF27322C),
            ),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress * 0.8,
              minHeight: 3,
              color: _cyan,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _BadgesStrip extends StatelessWidget {
  const _BadgesStrip({
    required this.data,
  });

  final _StatisticsData data;

  @override
  Widget build(BuildContext context) {
    final hasDistance = data.totalDistanceKm >= 1;
    final hasCalories = data.totalCalories >= 100;
    final hasGoal = data.completedGoalDays > 0;

    return SizedBox(
      height: 166,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _BadgeCard(
            active: hasDistance,
            icon: Icons.route_outlined,
            title: 'Esimene marsruut',
            subtitle: '1 km nädalas',
          ),
          const SizedBox(width: 18),
          _BadgeCard(
            active: hasCalories,
            icon: Icons.local_fire_department_outlined,
            title: 'Kalorid',
            subtitle: '100 kcal',
          ),
          const SizedBox(width: 18),
          _BadgeCard(
            active: hasGoal,
            icon: Icons.flag_outlined,
            title: 'Päeva eesmärk',
            subtitle: 'eesmärk täidetud',
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: _GlassCard(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
        radius: 14,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF2F4C13)
                    : const Color(0x44101415),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? const Color(0x668EFF19)
                      : const Color(0x1FFFFFFF),
                ),
                boxShadow: active
                    ? const [
                  BoxShadow(
                    color: Color(0x3335F46E),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ]
                    : const [],
              ),
              child: Icon(
                icon,
                color: active ? _lime : _textDim,
                size: 34,
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? Colors.white : _textDim,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? _textMuted : _textDim,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBreakdownHeader extends StatelessWidget {
  const _DailyBreakdownHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SectionTitle('Viimased marsruudid')),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.route,
  });

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    final date = route.startTime;
    final duration = Duration(seconds: route.durationSeconds);

    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
      radius: 12,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0x66101415),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0x1FFFFFFF)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.day.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _monthShort(date.month),
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.title.isEmpty ? 'Uus marsruut' : route.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatDistance(route.distanceKm)} • ${_formatDurationShort(duration)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${route.calories.round()} kcal',
                style: const TextStyle(
                  color: _lime,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.analytics_outlined,
                color: _textMuted,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyActivitiesCard extends StatelessWidget {
  const _EmptyActivitiesCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      child: Column(
        children: const [
          Icon(
            Icons.query_stats,
            color: _lime,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Statistikat pole veel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Salvesta esimene marsruut ja näitajad ilmuvad siia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textMuted,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _cardGlass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA030607),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x223BEA72),
            blurRadius: 30,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardColor, Color(0xE60D1213)],
        ),
      ),
      child: child,
    );
  }
}

class _ActivityChartPainter extends CustomPainter {
  const _ActivityChartPainter({
    required this.values,
  });

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final safeValues = values.isEmpty
        ? const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        : values;

    final chartHeight = size.height - 28;
    final stepX = safeValues.length <= 1 ? size.width : size.width / (safeValues.length - 1);

    final gridPaint = Paint()
      ..color = const Color(0x163BEA72)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chartHeight * (i + 1) / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0x5535F46E), Color(0xCCB6FF00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    for (var i = 0; i < safeValues.length; i++) {
      final value = safeValues[i].clamp(0.0, 1.0);
      final barHeight = value <= 0 ? 6.0 : math.max(18.0, chartHeight * value * 0.82);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(i * stepX, chartHeight - barHeight / 2),
          width: 20,
          height: barHeight,
        ),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, barPaint);
    }

    final points = <Offset>[
      for (var i = 0; i < safeValues.length; i++)
        Offset(
          i * stepX,
          chartHeight - chartHeight * safeValues[i].clamp(0.0, 1.0) + 10,
        ),
    ];

    if (points.isEmpty) {
      return;
    }

    final fillPath = Path()..moveTo(points.first.dx, chartHeight);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x5535F46E), Color(0x0035F46E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = previous.dx + (current.dx - previous.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..color = const Color(0x6635F46E);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [_lime, _green, _cyan],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    canvas.drawPath(linePath, glowPaint);
    canvas.drawPath(linePath, linePaint);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final active = i == DateTime.now().weekday - 1;

      canvas.drawCircle(
        point,
        active ? 7 : 4,
        Paint()
          ..color = active ? _lime : _green
          ..style = PaintingStyle.fill,
      );

      if (active) {
        canvas.drawCircle(
          point,
          15,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0x66B6FF00),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

List<double> _chartValues(List<DailyStepSummary> summaries) {
  if (summaries.isEmpty) {
    return const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  }

  return summaries.map((summary) {
    if (summary.stepGoal <= 0) {
      return 0.0;
    }

    return (summary.totalSteps / summary.stepGoal).clamp(0.0, 1.0).toDouble();
  }).toList();
}

List<String> _chartDays(List<DailyStepSummary> summaries) {
  if (summaries.isEmpty) {
    return const ['E', 'T', 'K', 'N', 'R', 'L', 'P'];
  }

  return summaries.map((summary) {
    return _weekdayShort(summary.date.weekday);
  }).toList();
}

String _weekdayShort(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'E',
    DateTime.tuesday => 'T',
    DateTime.wednesday => 'K',
    DateTime.thursday => 'N',
    DateTime.friday => 'R',
    DateTime.saturday => 'L',
    DateTime.sunday => 'P',
    _ => '',
  };
}

String _monthShort(int month) {
  return switch (month) {
    1 => 'JAAN',
    2 => 'VEE',
    3 => 'MÄR',
    4 => 'APR',
    5 => 'MAI',
    6 => 'JUN',
    7 => 'JUL',
    8 => 'AUG',
    9 => 'SEP',
    10 => 'OKT',
    11 => 'NOV',
    12 => 'DET',
    _ => '',
  };
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
  );
}

String _formatDistance(double distanceKm) {
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m';
  }

  return '${distanceKm.toStringAsFixed(1)} km';
}

String _formatDurationShort(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours} h ${duration.inMinutes.remainder(60)} min';
  }

  return '${duration.inMinutes} min';
}