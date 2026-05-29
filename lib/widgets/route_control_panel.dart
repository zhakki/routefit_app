import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RouteControlPanel extends StatelessWidget {
  const RouteControlPanel({
    super.key,
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: RouteFitColors.trackingPanel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RouteFitColors.trackingLine),
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
          const Expanded(child: GpsIndicator()),
          RoundRouteButton(
            icon: tracking ? Icons.pause : Icons.play_arrow,
            foreground: RouteFitColors.trackingLime,
            background: Colors.transparent,
            borderColor: RouteFitColors.trackingLime,
            onPressed: onPause,
            tooltip: tracking ? 'Paus' : 'Alusta',
          ),
          const SizedBox(width: 14),
          RoundRouteButton(
            icon: Icons.stop,
            foreground: const Color(0xFF6B1212),
            background: RouteFitColors.trackingStop,
            borderColor: RouteFitColors.trackingStop,
            onPressed: onStop,
            tooltip: 'Peata',
          ),
        ],
      ),
    );
  }
}

class GpsIndicator extends StatelessWidget {
  const GpsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: RouteFitColors.trackingLime,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x8835F46E), blurRadius: 16)],
          ),
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GPS jälgimine',
                maxLines: 1,
                style: TextStyle(
                  color: RouteFitColors.trackingLime,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kõrge täpsus',
                maxLines: 1,
                style: TextStyle(
                  color: RouteFitColors.trackingMuted,
                  fontSize: 13,
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

class RoundRouteButton extends StatelessWidget {
  const RoundRouteButton({
    super.key,
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
            width: 64,
            height: 64,
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
            child: Icon(icon, color: foreground, size: 30),
          ),
        ),
      ),
    );
  }
}
