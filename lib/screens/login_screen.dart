import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_user_flow_service.dart';
import '../widgets/app_widgets.dart';
import 'app_shell.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _background = Color(0xFF101415);
  static const _surfaceLow = Color(0xFF191C1E);
  static const _surface = Color(0xB81D2022);
  static const _surfaceHigh = Color(0xFF323537);
  static const _lime = Color(0xFFC3F400);
  static const _text = Color(0xFFE0E3E5);
  static const _muted = Color(0xFFC4C9AC);
  static const _inputBorder = Color(0x1AFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();

      await authService.login(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'invalid-email' => 'E-posti aadress ei ole korrektne',
        'user-disabled' => 'See kasutaja on blokeeritud',
        'user-not-found' => 'Sellist kasutajat ei leitud',
        'wrong-password' => 'Vale parool',
        'invalid-credential' => 'Vale e-post või parool',
        _ => 'Sisselogimine ebaõnnestus: ${error.message}',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Viga: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthUserFlowService().signInWithGoogleAndCreateProfile();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'google-sign-in-cancelled' => 'Google sisselogimine katkestati',
        'network-request-failed' => 'Võrguühendus puudub',
        _ => 'Google sisselogimine ebaõnnestus: ${error.message}',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viga: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAppleNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple sisselogimine lisatakse hiljem'),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const Positioned(top: -180, left: -160, child: _GlowOrb(size: 420)),
          const Positioned(
            right: -190,
            bottom: -210,
            child: _GlowOrb(size: 460),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 36),
                        _GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Tere tagasi!',
                                style: _headlineStyle(context),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Jälgi oma aktiivsust ja tulemusi.',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 18,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 30),
                              _KineticTextField(
                                controller: _email,
                                label: 'E-POST',
                                hintText: 'name@athlete.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: validateEmail,
                              ),
                              const SizedBox(height: 20),
                              _KineticTextField(
                                controller: _password,
                                label: 'PAROOL',
                                hintText: '••••••••',
                                obscureText: !_showPassword,
                                validator: validatePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                  splashRadius: 24,
                                  color: _lime,
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: _lime,
                                    textStyle: _monoStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Unustasid parooli?'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 72,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _lime,
                                    foregroundColor: const Color(0xFF161E00),
                                    shape: const StadiumBorder(),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Color(0xFF161E00),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Logi sisse'),
                                            SizedBox(width: 14),
                                            Icon(Icons.trending_flat, size: 28),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  const Text(
                                    'Uus RouteFitis?',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 17,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: _lime,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    child: const Text('Loo konto'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const _DividerLabel(),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialButton(
                                      icon: Icons.g_mobiledata,
                                      label: 'Google',
                                      onPressed: _isLoading ? null : _signInWithGoogle,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _SocialButton(
                                      icon: Icons.apple,
                                      label: 'Apple',
                                      onPressed: _isLoading ? null : _showAppleNotAvailable,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle _headlineStyle(BuildContext context) {
    return const TextStyle(
      color: Colors.white,
      fontSize: 34,
      height: 1.1,
      fontWeight: FontWeight.w800,
      fontFamily: 'Montserrat',
      shadows: [
        Shadow(color: Color(0x99000000), offset: Offset(0, 2), blurRadius: 4),
      ],
    );
  }

  static TextStyle _monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = _muted,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'JetBrains Mono',
      letterSpacing: 2.8,
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        RouteFitLogo(),
        SizedBox(height: 18),
        SizedBox(
          width: 300,
          child: Text(
            'Precision-engineered for the modern athlete.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _LoginScreenState._muted,
              fontSize: 18,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
      decoration: BoxDecoration(
        color: _LoginScreenState._surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x14FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 34,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0DFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _KineticTextField extends StatelessWidget {
  const _KineticTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(label, style: _LoginScreenState._monoStyle()),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: _LoginScreenState._lime,
          style: const TextStyle(
            color: _LoginScreenState._text,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0x4DE0E3E5), fontSize: 17),
            suffixIcon: suffixIcon,
            suffixIconColor: _LoginScreenState._lime,
            filled: true,
            fillColor: _LoginScreenState._surfaceLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            border: _fieldBorder(_LoginScreenState._inputBorder, 1),
            enabledBorder: _fieldBorder(_LoginScreenState._inputBorder, 1),
            focusedBorder: _fieldBorder(_LoginScreenState._lime, 2),
            errorBorder: _fieldBorder(const Color(0xFFFFB4AB), 1),
            focusedErrorBorder: _fieldBorder(const Color(0xFFFFB4AB), 2),
            errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0x14FFFFFF))),
        Container(
          color: _LoginScreenState._surfaceLow,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
            'VÕI JÄTKA',
            style: _LoginScreenState._monoStyle(fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Color(0x14FFFFFF))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: _LoginScreenState._surfaceHigh,
        foregroundColor: _LoginScreenState._text,
        side: const BorderSide(color: Color(0x14FFFFFF)),
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'JetBrains Mono',
        ),
      ),
      icon: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: _LoginScreenState._text,
          size: 22,
        ),
      ),
      label: Text(label),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x331BEF7B), Color(0x1AABD600), Color(0x00101415)],
        ),
      ),
    );
  }
}
