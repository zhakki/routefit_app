import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
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
  final UserService _userService = UserService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  String _gender = 'female';
  String _distanceUnit = 'KM';
  bool _locationPermissions = true;
  bool _saveRoutes = true;
  int _dailyStepGoal = 10000;

  bool _isLoading = true;
  bool _isSaving = false;

  String get _genderLabel {
    return switch (_gender) {
      'male' => 'Mees',
      'female' => 'Naine',
      'other' => 'Muu',
      _ => _gender.isEmpty ? '-' : _gender,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var profile = await _userService.getUserProfile(user.uid);

      if (profile == null) {
        await _userService.createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.email?.split('@').first ?? 'RouteFit user',
        );

        profile = await _userService.getUserProfile(user.uid);
      }

      final settings = await _userService.getUserSettings(user.uid);

      if (!mounted) return;

      setState(() {
        _name.text = profile?.fullName ?? '';
        _email.text = profile?.email ?? user.email ?? '';
        _age.text = profile?.age == 0 ? '' : profile!.age.toString();
        _weight.text = profile?.weightKg == 0
            ? ''
            : profile!.weightKg.toStringAsFixed(1);
        _height.text = profile?.heightCm == 0
            ? ''
            : profile!.heightCm.toStringAsFixed(1);
        _gender = profile?.gender.isNotEmpty == true
            ? profile!.gender
            : 'female';

        _distanceUnit = (settings?.distanceUnit ?? 'km').toUpperCase();
        _locationPermissions = settings?.allowLocation ?? true;
        _saveRoutes = settings?.saveRoutes ?? true;
        _dailyStepGoal = settings?.dailyStepGoal ?? 10000;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profiili laadimine ebaõnnestus: $error')),
      );
    }
  }

  Future<bool> _saveProfile({
    required String fullName,
    required String ageText,
    required String weightText,
    required String heightText,
    required String gender,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final age = int.tryParse(ageText.trim()) ?? 0;
    final weight = double.tryParse(weightText.trim().replaceAll(',', '.')) ?? 0;
    final height = double.tryParse(heightText.trim().replaceAll(',', '.')) ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.updateUserProfile(
        uid: user.uid,
        fullName: fullName.trim(),
        age: age,
        weightKg: weight,
        heightCm: height,
        gender: gender,
      );

      if (!mounted) return false;

      setState(() {
        _name.text = fullName.trim();
        _age.text = age == 0 ? '' : age.toString();
        _weight.text = weight == 0 ? '' : weight.toStringAsFixed(1);
        _height.text = height == 0 ? '' : height.toStringAsFixed(1);
        _gender = gender;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profiil uuendatud')),
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profiili salvestamine ebaõnnestus: $error')),
      );

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateSettings({
    String? distanceUnit,
    bool? saveRoutes,
    bool? allowLocation,
    int? dailyStepGoal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      if (distanceUnit != null) {
        _distanceUnit = distanceUnit;
      }

      if (saveRoutes != null) {
        _saveRoutes = saveRoutes;
      }

      if (allowLocation != null) {
        _locationPermissions = allowLocation;
      }

      if (dailyStepGoal != null) {
        _dailyStepGoal = dailyStepGoal;
      }
    });

    try {
      await _userService.updateUserSettings(
        uid: user.uid,
        distanceUnit: distanceUnit?.toLowerCase(),
        saveRoutes: saveRoutes,
        allowLocation: allowLocation,
        dailyStepGoal: dailyStepGoal,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seadete salvestamine ebaõnnestus: $error')),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oled välja logitud')),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name.text);
    final ageController = TextEditingController(text: _age.text);
    final weightController = TextEditingController(text: _weight.text);
    final heightController = TextEditingController(text: _height.text);
    String selectedGender = _gender;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF101415),
              title: const Text(
                'Muuda profiili',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EditTextField(
                      controller: nameController,
                      label: 'Nimi',
                    ),
                    const SizedBox(height: 12),
                    _EditTextField(
                      controller: ageController,
                      label: 'Vanus',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _EditTextField(
                      controller: weightController,
                      label: 'Kaal kg',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EditTextField(
                      controller: heightController,
                      label: 'Pikkus cm',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      dropdownColor: const Color(0xFF191C1E),
                      decoration: const InputDecoration(
                        labelText: 'Sugu',
                        labelStyle: TextStyle(color: _textMuted),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _lineColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _lime),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Naine'),
                        ),
                        DropdownMenuItem(
                          value: 'male',
                          child: Text('Mees'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Muu'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ],
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
                      : () async {
                    final success = await _saveProfile(
                      fullName: nameController.text,
                      ageText: ageController.text,
                      weightText: weightController.text,
                      heightText: heightController.text,
                      gender: selectedGender,
                    );

                    if (!mounted || !success) return;

                    Navigator.of(dialogContext).pop();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: _background),
        child: Center(
          child: CircularProgressIndicator(color: _lime),
        ),
      );
    }

    if (user == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: _background),
        child: Center(
          child: Text(
            'Kasutaja pole sisse logitud',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 38),
            _AvatarBlock(
              name: _name.text.isEmpty ? 'RouteFit kasutaja' : _name.text,
              onEdit: _showEditProfileDialog,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _email.text,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 34),
            _ProfileMetricGrid(
              age: _age.text.isEmpty ? '-' : _age.text,
              weight: _weight.text.isEmpty ? '-' : _weight.text,
              height: _height.text.isEmpty ? '-' : _height.text,
              gender: _genderLabel,
            ),
            const SizedBox(height: 34),
            const _SectionLabel('Eesmärgid ja eelistused'),
            const SizedBox(height: 18),
            _PreferencesCard(
              dailyStepGoal: _dailyStepGoal,
              distanceUnit: _distanceUnit,
              locationPermissions: _locationPermissions,
              saveRoutes: _saveRoutes,
              onDailyStepGoalChanged: (value) {
                _updateSettings(dailyStepGoal: value);
              },
              onDistanceUnitChanged: (value) {
                _updateSettings(distanceUnit: value);
              },
              onLocationPermissionsChanged: (value) {
                _updateSettings(allowLocation: value);
              },
              onSaveRoutesChanged: (value) {
                _updateSettings(saveRoutes: value);
              },
            ),
            const SizedBox(height: 34),
            TextButton(
              onPressed: _logout,
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
}

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: _lime,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _lineColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _lime),
        ),
      ),
    );
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
          'ROUTEFIT KASUTAJA',
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
    required this.dailyStepGoal,
    required this.distanceUnit,
    required this.locationPermissions,
    required this.saveRoutes,
    required this.onDailyStepGoalChanged,
    required this.onDistanceUnitChanged,
    required this.onLocationPermissionsChanged,
    required this.onSaveRoutesChanged,
  });

  final int dailyStepGoal;
  final String distanceUnit;
  final bool locationPermissions;
  final bool saveRoutes;
  final ValueChanged<int> onDailyStepGoalChanged;
  final ValueChanged<String> onDistanceUnitChanged;
  final ValueChanged<bool> onLocationPermissionsChanged;
  final ValueChanged<bool> onSaveRoutesChanged;

  @override
  Widget build(BuildContext context) {
    final sliderValue = dailyStepGoal.toDouble().clamp(1000.0, 30000.0).toDouble();

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
                Text(
                  _formatStepGoal(dailyStepGoal),
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 140,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _lime,
                      inactiveTrackColor: const Color(0xFF303636),
                      thumbColor: _lime,
                      overlayColor: const Color(0x2235F46E),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      min: 1000,
                      max: 30000,
                      divisions: 29,
                      value: sliderValue,
                      onChanged: (value) {
                        onDailyStepGoalChanged(value.round());
                      },
                    ),
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
            label: 'Salvesta marsruudid',
            trailing: _NeonSwitch(
              value: saveRoutes,
              onChanged: onSaveRoutesChanged,
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

String _formatStepGoal(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
  );
}