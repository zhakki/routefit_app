import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MapToolButton extends StatelessWidget {
  const MapToolButton({
    super.key,
    required this.icon,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active
              ? RouteFitColors.trackingLime.withValues(alpha: 0.2)
              : RouteFitColors.trackingCard,
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? RouteFitColors.trackingLime
                : RouteFitColors.trackingLine,
          ),
          boxShadow: [
            if (active)
              const BoxShadow(color: Color(0x3335F46E), blurRadius: 12),
          ],
        ),
        child: Icon(
          icon,
          color: active
              ? RouteFitColors.trackingLime
              : RouteFitColors.trackingMuted,
          size: 28,
        ),
      ),
    );
  }
}
