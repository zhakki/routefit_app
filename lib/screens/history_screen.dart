import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/route_model.dart';
import '../services/route_service.dart';
import '../utils/distance_formatter.dart';
import 'route_detail_screen.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<List<RouteModel>> _loadRoutes() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    return RouteService().getUserRoutes(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RouteModel>>(
      future: _loadRoutes(),
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
          return DecoratedBox(
            decoration: const BoxDecoration(color: _background),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ajalugu ei saanud laadida',
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

        final routes = snapshot.data ?? [];
        final totalDistanceKm = routes.fold<double>(
          0,
              (total, route) => total + route.distanceKm,
        );

        return DecoratedBox(
          decoration: const BoxDecoration(color: _background),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                const _HistoryHeader(),
                const SizedBox(height: 34),
                const _TitleFilterRow(),
                const SizedBox(height: 18),
                _TotalDistanceCard(totalDistanceKm: totalDistanceKm),
                const SizedBox(height: 26),

                if (routes.isEmpty)
                  const _EmptyHistoryCard()
                else
                  for (var index = 0; index < routes.length; index++) ...[
                    _RouteHistoryGlassCard(
                      route: routes[index],
                      index: index,
                    ),
                    if (index != routes.length - 1)
                      const SizedBox(height: 18),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

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
        const SizedBox(width: 48),
      ],
    );
  }
}

class _TitleFilterRow extends StatelessWidget {
  const _TitleFilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Ajalugu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF252A2B),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1FFFFFFF)),
          ),
          child: const Text(
            'Viimased 30 päeva',
            style: TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalDistanceCard extends StatelessWidget {
  const _TotalDistanceCard({required this.totalDistanceKm});

  final double totalDistanceKm;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(26, 24, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KOGU VAHEMAA',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalDistanceKm.toStringAsFixed(1),
                      style: const TextStyle(
                        color: _lime,
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'km',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _lime, width: 2.4),
                  boxShadow: const [
                    BoxShadow(color: Color(0x7735F46E), blurRadius: 22),
                  ],
                ),
              ),
              const Icon(Icons.trending_up, color: _lime, size: 28),
              const Positioned(
                right: -22,
                top: -18,
                child: Icon(
                  Icons.north_east,
                  color: Color(0x182F3736),
                  size: 86,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteHistoryGlassCard extends StatelessWidget {
  const _RouteHistoryGlassCard({
    required this.route,
    required this.index,
  });

  final RouteModel route;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isRunning = route.activityType.toLowerCase().contains('run') ||
        route.activityType.toLowerCase().contains('jooks');

    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 14,
      child: InkWell(
        onTap: () async {
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => RouteDetailScreen(route: route),
            ),
          );

          if (updated == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marsruudi andmed uuendatud'),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _RouteIcon(active: isRunning),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.title.isEmpty ? 'Minu marsruut' : route.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRouteDate(route.startTime),
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _textMuted, size: 28),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  color: const Color(0x990A0F10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _RouteStat(
                            label: 'Vahemaa',
                            value: formatDistanceValue(route.distanceKm),
                            suffix: formatDistanceUnit(route.distanceKm),
                            accent: true,
                          ),
                        ),
                        Expanded(
                          child: _RouteStat(
                            label: 'Kestus',
                            value: '${route.durationSeconds ~/ 60}',
                            suffix: 'min',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: _RouteStat(
                            label: 'Sammud',
                            value: _formatInt(route.steps),
                          ),
                        ),
                        Expanded(
                          child: _RouteStat(
                            label: 'Kalorid',
                            value: '${route.calories.round()}',
                            suffix: 'kcal',
                          ),
                        ),
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

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      child: Column(
        children: const [
          Icon(
            Icons.route_outlined,
            color: _lime,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Marsruute pole veel salvestatud',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Alusta uut marsruuti ja pärast lõpetamist ilmub see siia.',
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

class _RouteIcon extends StatelessWidget {
  const _RouteIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF344D12) : const Color(0xFF242B32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        active ? Icons.directions_run : Icons.directions_walk,
        color: active ? _lime : _textMuted,
        size: 28,
      ),
    );
  }
}

class _RouteStat extends StatelessWidget {
  const _RouteStat({
    required this.label,
    required this.value,
    this.suffix = '',
    this.accent = false,
  });

  final String label;
  final String value;
  final String suffix;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: accent ? _lime : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              if (suffix.isNotEmpty)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
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
        color: _cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA030607),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(color: Color(0x223BEA72), blurRadius: 26),
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

String _formatRouteDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day.$month • $hour:$minute';
}

String _formatInt(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
  );
}
