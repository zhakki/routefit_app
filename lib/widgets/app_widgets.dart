import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientHeaderScaffold extends StatelessWidget {
  const GradientHeaderScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 270,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [RouteFitColors.primaryDark, RouteFitColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: RouteFitColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.title,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: actions,
        centerTitle: false,
        backgroundColor: RouteFitColors.background,
        foregroundColor: RouteFitColors.ink,
        elevation: 0,
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.outlined = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: outlined ? RouteFitColors.line : Colors.transparent,
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D280049),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: content,
    );
  }
}

class RingProgress extends StatelessWidget {
  const RingProgress({required this.value, required this.size, super.key});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 7,
            color: RouteFitColors.primary,
            backgroundColor: RouteFitColors.soft,
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: RouteFitColors.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: RouteFitColors.primary, size: 22),
    );
  }
}

class GoalText extends StatelessWidget {
  const GoalText({
    required this.title,
    required this.value,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RouteFitColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
        Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: RouteFitColors.primary),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class StatRow extends StatelessWidget {
  const StatRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: RouteFitColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class PrimaryRouteButton extends StatelessWidget {
  const PrimaryRouteButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: RouteFitColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(Icons.play_arrow, color: RouteFitColors.primary),
          ),
        ],
      ),
    );
  }
}

class RouteFitLogo extends StatelessWidget {
  const RouteFitLogo({this.textAlign = TextAlign.center, super.key});

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      'RouteFit',
      textAlign: textAlign,
      style: const TextStyle(
        color: RouteFitColors.trackingLime,
        fontSize: 28,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.none,
        letterSpacing: 0,
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: inputDecoration(label, icon),
    );
  }
}

InputDecoration inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: RouteFitColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: RouteFitColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: RouteFitColors.primary, width: 1.6),
    ),
  );
}

ButtonStyle appButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    backgroundColor: RouteFitColors.primary,
    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
  );
}

bool isBlank(String? value) => value == null || value.trim().isEmpty;

String? validateEmail(String? value) {
  if (isBlank(value)) return 'Sisesta e-post';
  if (!value!.contains('@') || !value.contains('.')) {
    return 'Sisesta korrektne e-post';
  }
  return null;
}

String? validatePassword(String? value) {
  if (isBlank(value)) return 'Sisesta parool';
  if (value!.length < 6) return 'Kasuta vähemalt 6 märki';
  return null;
}
