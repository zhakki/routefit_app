import 'package:flutter/material.dart';

const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);

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
          color: active ? _lime.withValues(alpha: 0.2) : _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: active ? _lime : _lineColor),
          boxShadow: [
            if (active)
              const BoxShadow(color: Color(0x3335F46E), blurRadius: 12),
          ],
        ),
        child: Icon(icon, color: active ? _lime : _textMuted, size: 28),
      ),
    );
  }
}
