import 'package:flutter/material.dart';

import '../utils/distance_formatter.dart';
import 'route_data.dart';

const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);

class TopStats extends StatelessWidget {
  const TopStats({super.key, required this.distanceKm, required this.duration});

  final double distanceKm;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatGlassCard(
            label: 'Tempo',
            value: _formatPace(distanceKm, duration),
            suffix: '/km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatGlassCard(
            label: 'Vahemaa',
            value: formatDistanceValue(distanceKm),
            suffix: formatDistanceUnit(distanceKm),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatGlassCard(label: 'Aeg', value: formatDuration(duration)),
        ),
      ],
    );
  }
}

class StatGlassCard extends StatelessWidget {
  const StatGlassCard({
    super.key,
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
      height: 88,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: _lime,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: ' $suffix',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 14,
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

String _formatPace(double distanceKm, Duration duration) {
  if (distanceKm <= 0 || duration == Duration.zero) return "0'00";
  final totalSeconds = duration.inSeconds / distanceKm;
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).round().toString().padLeft(2, '0');
  return "$minutes'$seconds";
}
