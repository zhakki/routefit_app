import 'package:flutter/material.dart';

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
  bool _saveRoutes = true;
  bool _geo = true;
  bool _notifications = true;
  String _distanceUnit = 'km';
  double _stepGoal = 10000;
  double _weeklyStepGoal = 70000;

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
              const _SectionLabel('Eesmärgid'),
              const SizedBox(height: 18),
              _GoalsCard(
                stepGoal: _stepGoal,
                weeklyStepGoal: _weeklyStepGoal,
                onStepGoalChanged: (value) =>
                    setState(() => _stepGoal = value),
                onWeeklyStepGoalChanged: (value) {
                  setState(() => _weeklyStepGoal = value);
                },
              ),
              const SizedBox(height: 34),
              const _SectionLabel('Marsruudi seaded'),
              const SizedBox(height: 18),
              _RouteSettingsCard(
                distanceUnit: _distanceUnit,
                saveRoutes: _saveRoutes,
                geo: _geo,
                onDistanceUnitChanged: (value) {
                  setState(() => _distanceUnit = value);
                },
                onSaveRoutesChanged: (value) {
                  setState(() => _saveRoutes = value);
                },
                onGeoChanged: (value) => setState(() => _geo = value),
              ),
              const SizedBox(height: 34),
              const _SectionLabel('Rakenduse seaded'),
              const SizedBox(height: 18),
              _AppSettingsCard(
                notifications: _notifications,
                onNotificationsChanged: (value) {
                  setState(() => _notifications = value);
                },
              ),
              const SizedBox(height: 34),
              const _SectionLabel('Konto'),
              const SizedBox(height: 18),
              const _AccountCard(),
              const SizedBox(height: 40),
              const _SignOutButton(),
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

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({
    required this.stepGoal,
    required this.weeklyStepGoal,
    required this.onStepGoalChanged,
    required this.onWeeklyStepGoalChanged,
  });

  final double stepGoal;
  final double weeklyStepGoal;
  final ValueChanged<double> onStepGoalChanged;
  final ValueChanged<double> onWeeklyStepGoalChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: Column(
        children: [
          _GoalSliderRow(
            label: 'Päevane sammueesmärk',
            value: stepGoal,
            min: 4000,
            max: 120000,
            divisions: 116,
            onChanged: onStepGoalChanged,
          ),
          const _DividerLine(),
          _GoalSliderRow(
            label: 'Nädala sammueesmärk',
            value: weeklyStepGoal,
            min: 28000,
            max: 400000,
            divisions: 372,
            onChanged: onWeeklyStepGoalChanged,
          ),
        ],
      ),
    );
  }
}

class _GoalSliderRow extends StatelessWidget {
  const _GoalSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Text(
                _formatNumber(value.round()),
                style: const TextStyle(
                  color: _lime,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _lime,
              inactiveTrackColor: const Color(0xFF303636),
              thumbColor: _lime,
              overlayColor: const Color(0x2235F46E),
              valueIndicatorColor: _lime,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: _formatNumber(value.round()),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSettingsCard extends StatelessWidget {
  const _RouteSettingsCard({
    required this.distanceUnit,
    required this.saveRoutes,
    required this.geo,
    required this.onDistanceUnitChanged,
    required this.onSaveRoutesChanged,
    required this.onGeoChanged,
  });

  final String distanceUnit;
  final bool saveRoutes;
  final bool geo;
  final ValueChanged<String> onDistanceUnitChanged;
  final ValueChanged<bool> onSaveRoutesChanged;
  final ValueChanged<bool> onGeoChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: Column(
        children: [
          _SettingsRow(
            label: 'Vahemaaühik',
            trailing: _UnitSelector(
              selected: distanceUnit,
              onChanged: onDistanceUnitChanged,
            ),
          ),
          const _DividerLine(),
          _SettingsRow(
            label: 'Salvesta marsruudid',
            trailing: _NeonSwitch(
              value: saveRoutes,
              onChanged: onSaveRoutesChanged,
            ),
          ),
          const _DividerLine(),
          _SettingsRow(
            label: 'Kasuta asukohta',
            trailing: _NeonSwitch(value: geo, onChanged: onGeoChanged),
          ),
        ],
      ),
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

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: InkWell(
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: const _SettingsRow(
          label: 'Muuda profiili',
          trailing: Icon(Icons.chevron_right, color: _textMuted, size: 30),
        ),
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

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F30),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitButton(
            label: 'km',
            selected: selected == 'km',
            onTap: () => onChanged('km'),
          ),
          _UnitButton(
            label: 'mi',
            selected: selected == 'mi',
            onTap: () => onChanged('mi'),
          ),
        ],
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _lime : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x5535F46E), blurRadius: 14)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : _textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
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
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, size: 28),
      label: const Text('LOGI VÄLJA'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(74),
        backgroundColor: _lime,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: const Color(0x8835F46E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 30,
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

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}
