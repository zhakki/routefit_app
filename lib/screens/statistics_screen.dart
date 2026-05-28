import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: const [
            _StatisticsHeader(),
            SizedBox(height: 34),
            _TitleRow(),
            SizedBox(height: 18),
            _WeeklyActivityCard(),
            SizedBox(height: 18),
            _MetricGrid(),
            SizedBox(height: 34),
            _SectionTitle('Eesmärgid ja märgid'),
            SizedBox(height: 18),
            _BadgesStrip(),
            SizedBox(height: 34),
            _DailyBreakdownHeader(),
            SizedBox(height: 18),
            _ActivityTile(
              day: '12',
              month: 'OKT',
              title: 'Hommikune rajajooks',
              details: '8.2 km • 45 min',
              kcal: '642 kcal',
            ),
            SizedBox(height: 14),
            _ActivityTile(
              day: '11',
              month: 'OKT',
              title: 'Linnasõit',
              details: '4.5 km • 22 min',
              kcal: '215 kcal',
            ),
          ],
        ),
      ),
    );
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
              letterSpacing: 0,
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
                'AKTIIVSUSE\nNÄITAJAD',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        _GlassCard(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                'REAALAJAS\nSÜNKROONIMINE',
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
  const _WeeklyActivityCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keskmised sammud päevas',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '12 482',
                      style: TextStyle(
                        color: _lime,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+12%',
                    style: TextStyle(
                      color: _lime,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'võrreldes\neelmise nädalaga',
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
          const Text(
            'Selle nädala tempo on ühtlane ja neljapäev on seni tugevaim päev.',
            style: TextStyle(
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
              painter: _ActivityChartPainter(),
              child: const _ChartLabels(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLabels extends StatelessWidget {
  const _ChartLabels();

  @override
  Widget build(BuildContext context) {
    const days = ['E', 'T', 'K', 'N', 'R', 'L', 'P'];

    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: List.generate(days.length, (index) {
          return Expanded(
            child: Text(
              days[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: index == 3 ? _lime : _textMuted,
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
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Kalorid',
            value: '2 840',
            subtitle: 'kcal põletatud',
            progress: 0.74,
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: _MetricCard(
            icon: Icons.location_on_outlined,
            title: 'Vahemaa',
            value: '42.5',
            subtitle: 'km jälgitud',
            progress: 0.62,
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
                    letterSpacing: 0,
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
                letterSpacing: 0,
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
  const _BadgesStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 166,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _BadgeCard(
            active: true,
            icon: Icons.workspace_premium_outlined,
            title: 'Mäekuningas',
            subtitle: '5k tõusumeetrit',
          ),
          SizedBox(width: 18),
          _BadgeCard(
            icon: Icons.speed_outlined,
            title: 'Kiire hoog',
            subtitle: '20 km/h keskmine',
          ),
          SizedBox(width: 18),
          _BadgeCard(
            icon: Icons.flag_outlined,
            title: 'Nädala eesmärk',
            subtitle: '70k sammu',
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
              child: Icon(icon, color: active ? _lime : _textDim, size: 34),
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
        Expanded(child: _SectionTitle('Päeva ülevaade')),
        Text(
          'VAATA KÕIKI ›',
          style: TextStyle(
            color: _lime,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.day,
    required this.month,
    required this.title,
    required this.details,
    required this.kcal,
  });

  final String day;
  final String month;
  final String title;
  final String details;
  final String kcal;

  @override
  Widget build(BuildContext context) {
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
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  month,
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
                  title,
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
                  details,
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
                kcal,
                style: const TextStyle(
                  color: _lime,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.analytics_outlined, color: _textMuted, size: 19),
            ],
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

class _ActivityChartPainter extends CustomPainter {
  const _ActivityChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const values = [0.52, 0.68, 0.61, 0.94, 0.73, 0.58, 0.79];
    final chartHeight = size.height - 28;
    final stepX = size.width / (values.length - 1);

    final gridPaint = Paint()
      ..color = const Color(0x163BEA72)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chartHeight * (i + 1) / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(i * stepX, chartHeight - chartHeight * values[i] + 10),
    ];

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
      final active = i == 3;
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

    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0x5535F46E), Color(0xCCB6FF00)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    for (var i = 0; i < values.length; i++) {
      final barHeight = math.max(26.0, chartHeight * values[i] * 0.46);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(i * stepX, chartHeight - barHeight / 2),
          width: 18,
          height: barHeight,
        ),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
