import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/route_data.dart';
import 'result_screen.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _panelColor = Color(0xE61C2B31);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);
const _stopColor = Color(0xFFFFA8A1);

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _tracking = false;

  RouteSummary get _activeRoute => RouteSummary(
    title: 'Uus marsruut',
    date: DateTime(2026, 5, 22),
    startTime: const TimeOfDay(hour: 19, minute: 12),
    endTime: const TimeOfDay(hour: 19, minute: 43),
    distanceKm: _tracking ? 2.84 : 0,
    duration: _tracking
        ? const Duration(minutes: 27, seconds: 20)
        : Duration.zero,
    steps: _tracking ? 3820 : 0,
    calories: _tracking ? 310 : 0,
    averageSpeed: _tracking ? 6.2 : 0,
  );

  void _stopRoute() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(route: _activeRoute)),
    );
    setState(() => _tracking = false);
  }

  @override
  Widget build(BuildContext context) {
    final route = _activeRoute;

    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(top: 90, child: _MapSurface()),
            Positioned.fill(
              top: 90,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _background.withValues(alpha: 0.16),
                        Colors.transparent,
                        _background.withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const _MapHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Column(
                      children: [
                        _TopStats(route: route),
                        const Spacer(),
                        _RouteControlPanel(
                          tracking: _tracking,
                          onPause: () => setState(() => _tracking = !_tracking),
                          onStop: _tracking ? _stopRoute : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            iconSize: 30,
            tooltip: 'Tagasi',
          ),
          const Expanded(
            child: Text(
              'RouteFit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
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
            iconSize: 30,
            tooltip: 'Seaded',
          ),
        ],
      ),
    );
  }
}

class _TopStats extends StatelessWidget {
  const _TopStats({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatGlassCard(
            label: 'Tempo',
            value: _formatPace(route),
            suffix: '/km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatGlassCard(
            label: 'Vahemaa',
            value: route.distanceKm.toStringAsFixed(2),
            suffix: 'km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatGlassCard(
            label: 'Aeg',
            value: formatDuration(route.duration),
          ),
        ),
      ],
    );
  }
}

class _StatGlassCard extends StatelessWidget {
  const _StatGlassCard({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99030607),
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
          BoxShadow(color: Color(0x2235F46E), blurRadius: 26),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE3293E47), Color(0xE61A2A31)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: _lime,
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: ' $suffix',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteControlPanel extends StatelessWidget {
  const _RouteControlPanel({
    required this.tracking,
    required this.onPause,
    required this.onStop,
  });

  final bool tracking;
  final VoidCallback onPause;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB0000000),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
          BoxShadow(color: Color(0x3335F46E), blurRadius: 30),
        ],
      ),
      child: Row(
        children: [
          const Expanded(child: _GpsIndicator()),
          _RoundRouteButton(
            icon: tracking ? Icons.pause : Icons.play_arrow,
            foreground: _lime,
            background: Colors.transparent,
            borderColor: _lime,
            onPressed: onPause,
            tooltip: tracking ? 'Paus' : 'Alusta',
          ),
          const SizedBox(width: 24),
          _RoundRouteButton(
            icon: Icons.stop,
            foreground: const Color(0xFF6B1212),
            background: _stopColor,
            borderColor: _stopColor,
            onPressed: onStop,
            tooltip: 'Peata',
          ),
        ],
      ),
    );
  }
}

class _GpsIndicator extends StatelessWidget {
  const _GpsIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: _lime,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x8835F46E), blurRadius: 16)],
          ),
        ),
        const SizedBox(width: 18),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GPS jälgimine',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _lime,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kõrge täpsus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 18,
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

class _RoundRouteButton extends StatelessWidget {
  const _RoundRouteButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.borderColor,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.55 : 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: foreground, size: 36),
          ),
        ),
      ),
    );
  }
}

class _MapSurface extends StatelessWidget {
  const _MapSurface();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF6D8481).withValues(alpha: 0.36),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 250,
          child: Text(
            'San Francisco',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xCC0B1111),
              fontSize: 46,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const Positioned(
          right: 22,
          top: 190,
          child: _MapToolButton(icon: Icons.layers_outlined),
        ),
        const Positioned(
          right: 22,
          top: 268,
          child: _MapToolButton(icon: Icons.my_location),
        ),
      ],
    );
  }
}

class _MapToolButton extends StatelessWidget {
  const _MapToolButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0x802B3E45),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x283BEA72)),
      ),
      child: Icon(icon, color: const Color(0xAA2D3C3D), size: 28),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF6EBCC4), Color(0xFFCAD6CE), Color(0xFF77AEB4)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, waterPaint);

    final landPaint = Paint()..color = const Color(0xFFC9D1C6);
    final parkPaint = Paint()..color = const Color(0xFF83B493);
    final roadPaint = Paint()
      ..color = const Color(0xAA788995)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final smallRoadPaint = Paint()
      ..color = const Color(0x6692A0A6)
      ..strokeWidth = 2;

    final land = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.84, size.height * 0.03)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.28,
        size.width * 0.88,
        size.height * 0.48,
      )
      ..lineTo(size.width * 0.70, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(land, landPaint);

    for (final rect in [
      Rect.fromLTWH(size.width * 0.12, size.height * 0.56, 120, 70),
      Rect.fromLTWH(size.width * 0.50, size.height * 0.48, 80, 58),
      Rect.fromLTWH(size.width * 0.22, size.height * 0.78, 160, 90),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(18)),
        parkPaint,
      );
    }

    for (var y = size.height * 0.20; y < size.height * 0.84; y += 34) {
      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.78, y - 18),
        smallRoadPaint,
      );
    }
    for (var x = size.width * 0.14; x < size.width * 0.78; x += 36) {
      canvas.drawLine(
        Offset(x, size.height * 0.18),
        Offset(x + 90, size.height * 0.86),
        smallRoadPaint,
      );
    }

    final freeway = Path()
      ..moveTo(size.width * 0.12, size.height)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.78,
        size.width * 0.48,
        size.height * 0.75,
        size.width * 0.50,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.34,
        size.width * 0.74,
        size.height * 0.36,
        size.width * 0.76,
        size.height * 0.12,
      );
    canvas.drawPath(freeway, roadPaint);

    final routePaint = Paint()
      ..color = const Color(0xCCB6FF00)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = const Color(0x5535F46E)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final route = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.64,
        size.width * 0.28,
        size.height * 0.46,
        size.width * 0.50,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.38,
        size.width * 0.64,
        size.height * 0.24,
        size.width * 0.82,
        size.height * 0.18,
      );
    canvas.drawPath(route, glowPaint);
    canvas.drawPath(route, routePaint);

    final labelPaint = Paint()..color = const Color(0x550B1111);
    for (final point in [
      Offset(size.width * 0.56, size.height * 0.62),
      Offset(size.width * 0.30, size.height * 0.84),
      Offset(size.width * 0.76, size.height * 0.72),
    ]) {
      canvas.drawCircle(point, 18, labelPaint);
      canvas.drawCircle(point, 9, Paint()..color = const Color(0xFF1E8B68));
    }

    final haze = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0x00FFFFFF),
              _background.withValues(alpha: 0.18),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.42),
              radius: math.max(size.width, size.height) * 0.65,
            ),
          );
    canvas.drawRect(Offset.zero & size, haze);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatPace(RouteSummary route) {
  if (route.distanceKm <= 0 || route.duration == Duration.zero) return "0'00";
  final totalSeconds = route.duration.inSeconds / route.distanceKm;
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).round().toString().padLeft(2, '0');
  return "$minutes'$seconds";
}
