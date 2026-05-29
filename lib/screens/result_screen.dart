import 'package:flutter/material.dart';

import '../utils/distance_formatter.dart';
import '../widgets/route_data.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.route,
    super.key,
  });

  final RouteSummary route;

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
            const SizedBox(height: 16),
            Text(
              route.title.isEmpty ? 'Marsruudi kokkuvõte' : route.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _formatDate(route.date),
              style: const TextStyle(
                color: _textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),
            _MainSummaryCard(route: route),
            const SizedBox(height: 18),
            _SmallStatsGrid(route: route),
            const SizedBox(height: 18),
            _SavedInfoCard(),
            const SizedBox(height: 34),
            _BackHomeButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
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
            ),
          ),
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
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: _lime,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x8835F46E),
                blurRadius: 16,
              ),
            ],
          ),
          child: SizedBox(width: 11, height: 11),
        ),
        SizedBox(width: 10),
        Text(
          'MARSRUUT LÕPETATUD',
          style: TextStyle(
            color: _lime,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MainSummaryCard extends StatelessWidget {
  const _MainSummaryCard({
    required this.route,
  });

  final RouteSummary route;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KOKKUVÕTE',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BigMetric(
                  label: 'Vahemaa',
                  value: formatDistance(route.distanceKm),
                  icon: Icons.straighten,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _BigMetric(
                  label: 'Aeg',
                  value: formatDuration(route.duration),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0x990A0F10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x143BEA72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _lime,
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatsGrid extends StatelessWidget {
  const _SmallStatsGrid({
    required this.route,
  });

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
                value: '${_formatTime(route.startTime)} - ${_formatTime(route.endTime)}',
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
          Icon(
            icon,
            color: _lime,
            size: 30,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textMuted,
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
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: _lime,
            size: 30,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Marsruut on salvestatud ajalukku.',
              style: TextStyle(
                color: _textMuted,
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

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        backgroundColor: _lime,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: const Text(
        'Tagasi avalehele',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
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
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE61A2021),
            Color(0xE60F1415),
          ],
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