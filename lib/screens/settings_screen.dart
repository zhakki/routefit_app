import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _textMuted = Color(0xFFD0D6C9);
const _textDim = Color(0xFF8B948B);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: _background),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              const _SettingsHeader(),
              const SizedBox(height: 36),
              const _SectionLabel('Rakenduse seaded'),
              const SizedBox(height: 18),
              _AppSettingsCard(
                notifications: _notifications,
                onNotificationsChanged: (value) {
                  setState(() => _notifications = value);
                },
              ),
              const SizedBox(height: 40),
              _SignOutButton(onPressed: _logout),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          iconSize: 28,
          tooltip: 'Tagasi',
        ),
        const Expanded(
          child: Text(
            'SEADED',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard({
    required this.notifications,
    required this.onNotificationsChanged,
  });

  final bool notifications;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: Column(
        children: [
          _SettingsRow(
            label: 'Teavitused',
            trailing: _NeonSwitch(
              value: notifications,
              onChanged: onNotificationsChanged,
            ),
          ),
          const _DividerLine(),
          const _SettingsRow(
            label: 'Keel: Eesti',
            trailing: Icon(Icons.translate, color: _textMuted, size: 28),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          trailing,
        ],
      ),
    );
  }
}

class _NeonSwitch extends StatelessWidget {
  const _NeonSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: _lime,
      inactiveThumbColor: _textDim,
      inactiveTrackColor: const Color(0xFF252A2B),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, size: 24),
      label: const Text('LOGI VÄLJA'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        backgroundColor: _lime,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: const Color(0x8835F46E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _lime,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 5,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x142F3A36));
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

