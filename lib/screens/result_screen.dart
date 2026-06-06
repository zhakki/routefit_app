import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/distance_formatter.dart';
import '../widgets/app_widgets.dart';
import '../widgets/route_data.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.route, this.mapImage, super.key});

  final RouteSummary route;
  final Uint8List? mapImage;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: RouteFitColors.trackingBackground,
        ),
        child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _ResultHeader(),
            const SizedBox(height: 34),
            const _CompleteLabel(),
            const SizedBox(height: 12),
            Text(
              route.title.isEmpty ? 'Treeningu kokkuvõte' : route.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _formatDate(route.date),
              style: const TextStyle(
                color: RouteFitColors.trackingMuted,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            _RouteMapCard(mapImage: mapImage),
            const SizedBox(height: 24),
            _PrimaryStats(route: route),
            const SizedBox(height: 18),
            _SmallStatsGrid(route: route),
            const SizedBox(height: 18),
            const _SavedInfoCard(),
            const SizedBox(height: 34),
            _BackHomeButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
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
          child: RouteFitLogo(),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _CompleteLabel extends StatelessWidget {
  const _CompleteLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: RouteFitColors.trackingLime,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x8835F46E), blurRadius: 16)],
          ),
          child: SizedBox(width: 11, height: 11),
        ),
        const SizedBox(width: 10),
        Text(
          'MARSRUUT LÕPETATUD',
          style: TextStyle(
            color: RouteFitColors.trackingLime,
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
                    : Container(color: Colors.black26),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: RouteFitColors.trackingLime,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    const Text(
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

class _SmallStatsGrid extends StatelessWidget {
  const _SmallStatsGrid({required this.route});

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.directions_walk,
                label: 'Sammud',
                value: formatNumber(route.steps),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Kalorid',
                value: '${route.calories} kcal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.speed,
                label: 'Keskmine kiirus',
                value: '${route.averageSpeed.toStringAsFixed(1)} km/h',
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.schedule,
                label: 'Aeg',
                value:
                    '${_formatTime(route.startTime)} - ${_formatTime(route.endTime)}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RouteFitColors.trackingLime, size: 30),
          const SizedBox(height: 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: RouteFitColors.trackingMuted,
              fontSize: 15,
              fontWeight: FontWeight.w800,
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

class _SavedInfoCard extends StatelessWidget {
  const _SavedInfoCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Marsruut on salvestatud ajalukku.',
              style: TextStyle(
                color: RouteFitColors.trackingMuted,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
          Icon(icon, color: RouteFitColors.trackingLime, size: 28),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: RouteFitColors.trackingMuted,
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
              color: RouteFitColors.trackingMuted,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        backgroundColor: RouteFitColors.trackingLime,
        foregroundColor: Colors.black,
        elevation: 0,
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
        color: RouteFitColors.trackingCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: RouteFitColors.trackingLine),
        boxShadow: [
          const BoxShadow(
            color: Color(0xAA030607),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: glow ? const Color(0x5535F46E) : RouteFitColors.trackingLine,
            blurRadius: glow ? 34 : 24,
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
