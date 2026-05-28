import 'package:flutter/material.dart';

import 'settings_screen.dart';

const _background = Color(0xFF101415);
const _cardColor = Color(0xE6101415);
const _lineColor = Color(0x283BEA72);
const _lime = Color(0xFFB6FF00);
const _green = Color(0xFF35F46E);
const _textMuted = Color(0xFFD0D6C9);
const _textDim = Color(0xFF8B948B);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController(text: 'Zina');
  final _email = TextEditingController(text: 'zina@routefit.app');
  final _age = TextEditingController(text: '22');
  final _weight = TextEditingController(text: '58');
  final _height = TextEditingController(text: '168');
  final String _gender = 'Naine';
  String _distanceUnit = 'KM';
  bool _locationPermissions = true;
  bool _notifications = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 38),
            _AvatarBlock(name: _name.text, onEdit: _showProfileUpdated),
            const SizedBox(height: 34),
            _ProfileMetricGrid(
              age: _age.text,
              weight: _weight.text,
              height: _height.text,
              gender: _gender,
            ),
            const SizedBox(height: 34),
            const _SectionLabel('Eesmärgid ja eelistused'),
            const SizedBox(height: 18),
            _PreferencesCard(
              distanceUnit: _distanceUnit,
              locationPermissions: _locationPermissions,
              notifications: _notifications,
              onDistanceUnitChanged: (value) {
                setState(() => _distanceUnit = value);
              },
              onLocationPermissionsChanged: (value) {
                setState(() => _locationPermissions = value);
              },
              onNotificationsChanged: (value) {
                setState(() => _notifications = value);
              },
            ),
            const SizedBox(height: 34),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFC1B8),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Logi välja'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileUpdated() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profiil uuendatud')));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        const Expanded(
          child: Text(
            'RouteFit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lime,
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: const Icon(Icons.settings_outlined),
          color: Colors.white,
          iconSize: 28,
          tooltip: 'Seaded',
        ),
      ],
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({required this.name, required this.onEdit});

  final String name;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(colors: [_lime, _green, _lime]),
                boxShadow: const [
                  BoxShadow(color: Color(0x7735F46E), blurRadius: 34),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF172323),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: _lime, size: 82),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 8,
              child: _EditAvatarButton(onPressed: onEdit),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'ELIITJOOKSJA • TASE 42',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: onEdit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(190, 58),
            backgroundColor: _lime,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: const Text('Muuda profiili'),
        ),
      ],
    );
  }
}

class _EditAvatarButton extends StatelessWidget {
  const _EditAvatarButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _lime,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _background, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x6635F46E), blurRadius: 18),
            ],
          ),
          child: const Icon(Icons.edit, color: Colors.black, size: 22),
        ),
      ),
    );
  }
}

class _ProfileMetricGrid extends StatelessWidget {
  const _ProfileMetricGrid({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
  });

  final String age;
  final String weight;
  final String height;
  final String gender;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(label: 'Vanus', value: age, unit: 'a'),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _MetricCard(label: 'Kaal', value: weight, unit: 'kg'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MetricCard(label: 'Pikkus', value: height, unit: 'cm'),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _MetricCard(label: 'Sugu', value: gender),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, this.unit = ''});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 26),
      radius: 12,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 15,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _textMuted,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.distanceUnit,
    required this.locationPermissions,
    required this.notifications,
    required this.onDistanceUnitChanged,
    required this.onLocationPermissionsChanged,
    required this.onNotificationsChanged,
  });

  final String distanceUnit;
  final bool locationPermissions;
  final bool notifications;
  final ValueChanged<String> onDistanceUnitChanged;
  final ValueChanged<bool> onLocationPermissionsChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: Column(
        children: [
          _PreferenceRow(
            label: 'Päevane sammueesmärk',
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '10 000',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 120,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _lime,
                      inactiveTrackColor: const Color(0xFF303636),
                      thumbColor: _lime,
                      overlayColor: const Color(0x2235F46E),
                      trackHeight: 4,
                    ),
                    child: const Slider(value: 0.58, onChanged: null),
                  ),
                ),
              ],
            ),
          ),
          const _DividerLine(),
          _PreferenceRow(
            label: 'Vahemaaühikud',
            trailing: _UnitSelector(
              selected: distanceUnit,
              onChanged: onDistanceUnitChanged,
            ),
          ),
          const _DividerLine(),
          _PreferenceRow(
            label: 'Asukohaõigused',
            trailing: _NeonSwitch(
              value: locationPermissions,
              onChanged: onLocationPermissionsChanged,
            ),
          ),
          const _DividerLine(),
          _PreferenceRow(
            label: 'Teavitused',
            trailing: _NeonSwitch(
              value: notifications,
              onChanged: onNotificationsChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
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
        color: const Color(0xFF252A2B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitButton(
            label: 'KM',
            selected: selected == 'KM',
            onTap: () => onChanged('KM'),
          ),
          _UnitButton(
            label: 'MI',
            selected: selected == 'MI',
            onTap: () => onChanged('MI'),
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
        width: 56,
        height: 42,
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
