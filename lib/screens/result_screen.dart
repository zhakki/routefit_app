import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/distance_formatter.dart';
import '../widgets/route_data.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _green = Color(0xFF35F46E);
const _textMuted = Color(0xFFD0D6C9);

class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.route, this.mapImage, super.key});

  final RouteSummary route;
  final Uint8List? mapImage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _ResultHeader(),
            const SizedBox(height: 34),
            const _CompleteLabel(),
            const SizedBox(height: 12),
            const Text(
              'Treeningu kokkuvõte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 28),
            _RouteMapCard(mapImage: mapImage),
            const SizedBox(height: 24),
            _PrimaryStats(route: route),
            const SizedBox(height: 18),
            _SecondaryStats(route: route),
            const SizedBox(height: 18),
            _AverageSpeedCard(route: route),
            const SizedBox(height: 34),
            _SaveRouteButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marsruut salvestati ajalukku')),
              ),
            ),
            const SizedBox(height: 16),
            _BackHomeButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          iconSize: 28,
          tooltip: 'Tagasi',
        ),
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

class _CompleteLabel extends StatelessWidget {
  const _CompleteLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: _lime,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x8835F46E), blurRadius: 16)],
          ),
          child: SizedBox(width: 11, height: 11),
        ),
        SizedBox(width: 10),
        Text(
          'TREENING LÕPETATUD',
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

class _RouteMapCard extends StatelessWidget {
  const _RouteMapCard({this.mapImage});

  final Uint8List? mapImage;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 18,
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: mapImage != null
                    ? Image.memory(mapImage!, fit: BoxFit.cover)
                    : CustomPaint(painter: _RouteMapPainter()),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0x99080D0E), Color(0x22080D0E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 22,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xDD060A0B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x223BEA72)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, color: _lime, size: 18),
                    SizedBox(width: 9),
                    Text(
                      'Marsruudi ülevaade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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

class _PrimaryStats extends StatelessWidget {
  const _PrimaryStats({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.straighten,
            title: 'Vahemaa',
            value: formatDistance(route.distanceKm),
            subtitle: 'Kogu vahemaa',
            highlighted: true,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            title: 'Kestus',
            value: formatDuration(route.duration),
            subtitle: 'Koguaeg',
          ),
        ),
      ],
    );
  }
}

class _SecondaryStats extends StatelessWidget {
  const _SecondaryStats({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.directions_walk,
            title: 'Sammud',
            value: formatNumber(route.steps),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _CompactMetricCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Kalorid',
            value: '${route.calories}',
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
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(26, 28, 22, 26),
      glow: highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _lime, size: 28),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  const _CompactMetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF283A18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _lime, size: 30),
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
                    color: _textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageSpeedCard extends StatelessWidget {
  const _AverageSpeedCard({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(26, 26, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Keskmine kiirus',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: route.averageSpeed.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          const TextSpan(
                            text: ' km/h',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          const SizedBox(width: 190, height: 104, child: _SpeedBars()),
        ],
      ),
    );
  }
}

class _SpeedBars extends StatelessWidget {
  const _SpeedBars();

  @override
  Widget build(BuildContext context) {
    const values = [0.48, 0.64, 0.48, 0.72, 0.80, 0.96];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              height: 92 * values[index],
              decoration: BoxDecoration(
                color: const Color(0xFF526915),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                boxShadow: index == values.length - 1
                    ? const [
                        BoxShadow(color: Color(0x6635F46E), blurRadius: 16),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SaveRouteButton extends StatelessWidget {
  const _SaveRouteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(76),
        backgroundColor: _lime,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: const Icon(Icons.save_outlined, size: 26),
      label: const Text(
        'Salvesta marsruut',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0x2EFFFFFF)),
        backgroundColor: const Color(0xFF222728),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: const Text(
        'Tagasi avalehele',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _lineColor),
        boxShadow: [
          const BoxShadow(
            color: Color(0xAA030607),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: glow ? const Color(0x5535F46E) : const Color(0x223BEA72),
            blurRadius: glow ? 34 : 24,
            offset: const Offset(0, 0),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE61A2021), Color(0xE60F1415)],
        ),
      ),
      child: child,
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF122126), Color(0xFF071011)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final gridPaint = Paint()
      ..color = const Color(0x183BEA72)
      ..strokeWidth = 1;
    for (var x = -size.width; x < size.width * 1.5; x += 28) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.9, size.height),
        gridPaint,
      );
    }
    for (var y = 18.0; y < size.height; y += 30) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 44) {
        path.lineTo(x, y + math.sin((x + y) / 34) * 7);
      }
      canvas.drawPath(path, gridPaint);
    }

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x445C6B6B);
    canvas.drawLine(
      Offset(size.width * 0.18, size.height),
      Offset(size.width * 0.78, 0),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.0, size.height * 0.66),
      Offset(size.width, size.height * 0.15),
      roadPaint,
    );

    final routePath = Path()
      ..moveTo(size.width * 0.42, size.height)
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.80,
        size.width * 0.74,
        size.height * 0.66,
        size.width * 0.59,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.28,
        size.width * 0.58,
        size.height * 0.16,
        size.width * 0.52,
        0,
      );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = const Color(0x6635F46E);
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_green, _lime, _green],
      ).createShader(Offset.zero & size);

    canvas.drawPath(routePath, glowPaint);
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
