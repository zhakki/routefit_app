import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_widgets.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: RouteFitColors.trackingBackground,
        border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: RouteFitLogo(),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
