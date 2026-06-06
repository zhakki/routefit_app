import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/route_model.dart';
import '../services/route_service.dart';
import '../utils/distance_formatter.dart';
import '../widgets/app_widgets.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({
    required this.route,
    super.key,
  });

  final RouteModel route;

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late String _title;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _title = widget.route.title.isEmpty ? 'Uus marsruut' : widget.route.title;
  }

  Future<void> _saveTitle(String newTitle) async {
    final title = newTitle.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nimi ei tohi olla tühi')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = widget.route.userId.isNotEmpty
        ? widget.route.userId
        : currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kasutaja pole sisse logitud')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await RouteService().updateRouteTitle(
        userId: userId,
        routeId: widget.route.routeId,
        title: title,
      );

      if (!mounted) return;

      setState(() {
        _title = title;
        _hasChanges = true;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marsruudi nimi uuendatud')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nime salvestamine ebaõnnestus: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showEditTitleDialog() {
    final controller = TextEditingController(text: _title);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101415),
          title: const Text(
            'Muuda marsruudi nime',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            cursorColor: _lime,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Marsruudi nimi',
              labelStyle: TextStyle(color: _textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _lineColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _lime),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Tühista'),
            ),
            FilledButton(
              onPressed: _isSaving
                  ? null
                  : () {
                _saveTitle(controller.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _lime,
                foregroundColor: Colors.black,
              ),
              child: Text(_isSaving ? 'Salvestan...' : 'Salvesta'),
            ),
          ],
        );
      },
    );
  }

  void _goBack() {
    Navigator.of(context).pop(_hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: widget.route.durationSeconds);

    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _background),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
            _DetailHeader(onBack: _goBack),
            const SizedBox(height: 34),
            const _StatusLabel(),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showEditTitleDialog,
                  icon: const Icon(Icons.edit_outlined),
                  color: _lime,
                  tooltip: 'Muuda nime',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(widget.route.startTime),
              style: const TextStyle(
                color: _textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            _MainStatsCard(
              distanceKm: widget.route.distanceKm,
              duration: duration,
            ),
            const SizedBox(height: 18),
            _StatsGrid(route: widget.route),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Tegevuse tüüp',
              value: _activityTypeLabel(widget.route.activityType),
              icon: Icons.directions_walk,
            ),
            const SizedBox(height: 34),
            FilledButton.icon(
              onPressed: _showEditTitleDialog,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(72),
                backgroundColor: _lime,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text(
                'Muuda nime',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _goBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(68),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x2EFFFFFF)),
                backgroundColor: const Color(0xFF222728),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Tagasi ajaloosse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
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

class _StatusLabel extends StatelessWidget {
  const _StatusLabel();

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
          'MARSRUUDI DETAILID',
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

class _MainStatsCard extends StatelessWidget {
  const _MainStatsCard({
    required this.distanceKm,
    required this.duration,
  });

  final double distanceKm;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      glow: true,
      child: Row(
        children: [
          Expanded(
            child: _BigMetric(
              label: 'Vahemaa',
              value: formatDistance(distanceKm),
              icon: Icons.straighten,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _BigMetric(
              label: 'Kestus',
              value: formatDuration(duration),
              icon: Icons.timer_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.route,
  });

  final RouteModel route;

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
                value: '${route.calories.round()} kcal',
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
          Icon(icon, color: _lime, size: 28),
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
          Icon(icon, color: _lime, size: 30),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Row(
        children: [
          Icon(icon, color: _lime, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
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

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day.$month.$year • $hour:$minute';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _activityTypeLabel(String value) {
  final type = value.toLowerCase();

  if (type.contains('run') || type.contains('jooks')) {
    return 'Jooksmine';
  }

  if (type.contains('bike') || type.contains('ratas')) {
    return 'Jalgratas';
  }

  return 'Kõndimine';
}
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
  );
}
