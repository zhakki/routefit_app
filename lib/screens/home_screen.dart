import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/daily_step_summary.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import '../services/statistics_service.dart';
import '../utils/distance_formatter.dart';
import '../widgets/app_widgets.dart';
import 'route_detail_screen.dart';

const _background = Color(0xFF0B0F10);
const _cardColor = Color(0xFF101415);
const _cardGlass = Color(0xE6101415);
const _lineColor = Color(0x243BEA72);
const _lime = Color(0xFFB6FF00);
const _green = Color(0xFF35F46E);
const _ringTrack = Color(0xFF26322C);
const _textMuted = Color(0xFFC8D0C5);

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onStartRoute, super.key});

  final VoidCallback onStartRoute;

  Future<_HomeDashboardData> _loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _HomeDashboardData(
        todaySteps: 0,
        dailyGoal: 10000,
        weekSteps: 0,
        weekGoal: 70000,
        weeklySummaries: [],
        lastRoute: null,
      );
    }

    final statisticsService = StatisticsService();
    final routeService = RouteService();

    final today = DateTime.now();

    final dailySummary = await statisticsService.calculateDailySummary(
      userId: user.uid,
      date: today,
    );

    final weeklySummaries = await statisticsService.calculateWeeklySummary(
      userId: user.uid,
      selectedDate: today,
    );

    final routes = await routeService.getUserRoutes(user.uid);

    final weekSteps = statisticsService.calculateTotalWeeklySteps(
      weeklySummaries,
    );

    final weekGoal = dailySummary.stepGoal * 7;

    return _HomeDashboardData(
      todaySteps: dailySummary.totalSteps,
      dailyGoal: dailySummary.stepGoal,
      weekSteps: weekSteps,
      weekGoal: weekGoal,
      weeklySummaries: weeklySummaries,
      lastRoute: routes.isNotEmpty ? routes.first : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeDashboardData>(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DecoratedBox(
            decoration: BoxDecoration(color: _background),
            child: Center(child: CircularProgressIndicator(color: _lime)),
          );
        }

        if (snapshot.hasError) {
          return DecoratedBox(
            decoration: const BoxDecoration(color: _background),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Andmeid ei saanud laadida',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }

        final data =
            snapshot.data ??
            const _HomeDashboardData(
              todaySteps: 0,
              dailyGoal: 10000,
              weekSteps: 0,
              weekGoal: 70000,
              weeklySummaries: [],
              lastRoute: null,
            );

        final todaySteps = data.todaySteps;
        final dailyGoal = data.dailyGoal;
        final weekSteps = data.weekSteps;
        final weekGoal = data.weekGoal;

        final progress = dailyGoal == 0 ? 0.0 : todaySteps / dailyGoal;
        final dailyRemaining = math.max(0, dailyGoal - todaySteps);
        final weekRemaining = math.max(0, weekGoal - weekSteps);

        return DecoratedBox(
          decoration: const BoxDecoration(color: _background),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                const _HomeHeader(),
                const SizedBox(height: 28),
                _GlassCard(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    children: [
                      GradientStepRing(
                        progress: progress,
                        size: 232,
                        steps: todaySteps,
                        goal: dailyGoal,
                      ),
                      const SizedBox(height: 26),
                      Text(
                        '${(progress * 100).round()}% valmis',
                        style: const TextStyle(
                          color: _lime,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_formatCompact(dailyRemaining)} sammu jäänud',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _DailyGoalCard(goal: dailyGoal, remaining: dailyRemaining),
                const SizedBox(height: 18),
                _WeeklyProgressCard(
                  steps: weekSteps,
                  goal: weekGoal,
                  remaining: weekRemaining,
                  weeklySummaries: data.weeklySummaries,
                ),
                const SizedBox(height: 18),
                if (data.lastRoute != null)
                  _LastRouteCard(route: data.lastRoute!)
                else
                  const _EmptyLastRouteCard(),
                const SizedBox(height: 14),
                _NewRouteButton(onPressed: onStartRoute),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeDashboardData {
  const _HomeDashboardData({
    required this.todaySteps,
    required this.dailyGoal,
    required this.weekSteps,
    required this.weekGoal,
    required this.weeklySummaries,
    required this.lastRoute,
  });

  final int todaySteps;
  final int dailyGoal;
  final int weekSteps;
  final int weekGoal;
  final List<DailyStepSummary> weeklySummaries;
  final RouteModel? lastRoute;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: RouteFitLogo(),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.goal, required this.remaining});

  final int goal;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Expanded(
            child: _SmallMetric(
              label: 'PÄEVA EESMÄRK',
              value: _formatCompact(goal),
              suffix: ' sammu',
            ),
          ),
          _SmallMetric(
            label: 'JÄÄNUD',
            value: _formatCompact(remaining),
            valueColor: _lime,
            alignEnd: true,
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({
    required this.steps,
    required this.goal,
    required this.remaining,
    required this.weeklySummaries,
  });

  final int steps;
  final int goal;
  final int remaining;
  final List<DailyStepSummary> weeklySummaries;

  @override
  Widget build(BuildContext context) {
    const days = ['E', 'T', 'K', 'N', 'R', 'L', 'P'];
    final values = _weeklyChartValues(weeklySummaries);
    final todayIndex = DateTime.now().weekday - 1;
    final passedDays = DateTime.now().weekday;
    final averageSteps = passedDays > 0 ? (steps / passedDays).round() : 0;

    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nädala progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatCompact(steps)} / ${_formatCompact(goal)}\nsammu',
            style: const TextStyle(
              color: _textMuted,
              fontSize: 19,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _InsetStatCard(
                  label: 'VEEL VAJA',
                  value: _formatCompact(remaining),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _InsetStatCard(
                  label: 'PÄEVA KESKMINE',
                  value: _formatCompact(averageSteps),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 102,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (index) {
                final active = values[index] > 0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 44,
                        height: 68 * values[index],
                        decoration: BoxDecoration(
                          color: active
                              ? (index == todayIndex
                                    ? _lime
                                    : const Color(0xFF3C5518))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        days[index],
                        style: TextStyle(
                          color: index == todayIndex ? _lime : _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

List<double> _weeklyChartValues(List<DailyStepSummary> summaries) {
  return List.generate(7, (index) {
    if (index >= summaries.length) {
      return 0.0;
    }

    final summary = summaries[index];
    if (summary.stepGoal <= 0) {
      return 0.0;
    }

    return (summary.totalSteps / summary.stepGoal).clamp(0.0, 1.0).toDouble();
  });
}

class _LastRouteCard extends StatelessWidget {
  const _LastRouteCard({required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RouteDetailScreen(route: route),
            ),
          );
        },
        child: SizedBox(
          height: 190,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: CustomPaint(painter: _RouteGlowPainter()),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0xCC06100C)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x99101415),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x223BEA72)),
                          ),
                          child: const Text(
                            'VIIMANE MARSRUUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _routeTitle(route.title),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _RouteMetric(
                          label: 'MAA',
                          value: formatDistance(route.distanceKm),
                        ),
                        const SizedBox(width: 24),
                        _RouteMetric(
                          label: 'AEG',
                          value: '${route.durationSeconds ~/ 60} min',
                        ),
                        const SizedBox(width: 24),
                        _RouteMetric(
                          label: 'KAL',
                          value: '${route.calories.round()} kcal',
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: _lime, size: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLastRouteCard extends StatelessWidget {
  const _EmptyLastRouteCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'VIIMANE MARSRUUT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Marsruute pole veel salvestatud',
            style: TextStyle(
              color: _textMuted,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewRouteButton extends StatelessWidget {
  const _NewRouteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(76),
        backgroundColor: _lime,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 26),
          SizedBox(width: 14),
          Text(
            'UUS MARSRUUT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class GradientStepRing extends StatelessWidget {
  const GradientStepRing({
    required this.progress,
    required this.size,
    required this.steps,
    required this.goal,
    super.key,
  });

  final double progress;
  final double size;
  final int steps;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _GradientRingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatCompact(steps),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '/ ${_formatCompact(goal)} sammu',
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.085;
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * progress.clamp(0, 1);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = _ringTrack;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.9
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..color = const Color(0x4435F46E);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [_lime, Color(0xFF8EFF19), _green, _lime],
        stops: [0, 0.18, 0.72, 1],
      ).createShader(rect);

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _cardGlass,
        borderRadius: BorderRadius.circular(26),
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
            offset: Offset(0, 0),
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

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({
    required this.label,
    required this.value,
    this.suffix = '',
    this.valueColor = Colors.white,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final String suffix;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: suffix,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsetStatCard extends StatelessWidget {
  const _InsetStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xA30B0F10),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RouteGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF102125), Color(0xFF07100D)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x161D3C36);

    for (var y = 18.0; y < size.height; y += 24) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 44) {
        path.lineTo(x, y + math.sin((x + y) / 30) * 8);
      }
      canvas.drawPath(path, gridPaint);
    }

    final routePath = Path()
      ..moveTo(size.width * 0.14, size.height * 0.58)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.42,
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.50,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.29,
        size.width * 0.64,
        size.height * 0.70,
        size.width * 0.86,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.86,
        size.width * 0.42,
        size.height * 0.74,
        size.width * 0.27,
        size.height * 0.78,
      );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = const Color(0x77B6FF00);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xCCB6FF00);

    canvas.drawPath(routePath, glow);
    canvas.drawPath(routePath, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatCompact(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String _routeTitle(String sourceTitle) {
  if (sourceTitle.contains('jalutus')) return 'Õhtune jalutuskäik';
  return sourceTitle;
}
