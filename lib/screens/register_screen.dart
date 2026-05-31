import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_user_flow_service.dart';
import '../widgets/app_widgets.dart';
import 'app_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _name.dispose();
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
      final authFlowService = AuthUserFlowService();

      await authFlowService.registerAndCreateProfile(
        email: _email.text.trim(),
        password: _password.text.trim(),
        fullName: _name.text.trim(),
        weightKg: 0.0,
        heightCm: 0.0,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'email-already-in-use' => 'See e-post on juba kasutusel',
        'invalid-email' => 'E-posti aadress ei ole korrektne',
        'weak-password' => 'Parool on liiga nõrk',
        _ => 'Registreerimine ebaõnnestus: ${error.message}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RegisterStyle.background,
      body: Stack(
        children: [
          const Positioned(
            top: -180,
            left: -160,
            child: _RegisterGlow(size: 420),
          ),
          const Positioned(
            right: -190,
            bottom: -230,
            child: _RegisterGlow(size: 470),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'RouteFit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _RegisterStyle.lime,
                            fontSize: 50,
                            height: 1,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 82),
                        const Text(
                          'Loo konto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                            shadows: [
                              Shadow(
                                color: Color(0xCC000000),
                                offset: Offset(0, 3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Loo RouteFit konto ja alusta oma teekonda juba täna',
                          style: TextStyle(
                            color: _RegisterStyle.textSoft,
                            fontSize: 20,
                            height: 1.45,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 38),
                        _RegisterGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _RegisterTextField(
                                controller: _name,
                                label: 'Nimi',
                                hintText: 'Sinu täisnimi',
                                validator: (value) =>
                                    isBlank(value) ? 'Sisesta nimi' : null,
                              ),
                              const SizedBox(height: 26),
                              _RegisterTextField(
                                controller: _email,
                                label: 'E-post',
                                hintText: 'nimi@naide.ee',
                                keyboardType: TextInputType.emailAddress,
                                validator: validateEmail,
                              ),
                              const SizedBox(height: 26),
                              _RegisterTextField(
                                controller: _password,
                                label: 'Parool',
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
                                  color: _RegisterStyle.lime,
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 34),
                              SizedBox(
                                height: 70,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _RegisterStyle.lime,
                                    disabledBackgroundColor: _RegisterStyle.lime
                                        .withValues(alpha: 0.45),
                                    foregroundColor: _RegisterStyle.buttonText,
                                    disabledForegroundColor:
                                        _RegisterStyle.buttonText.withValues(
                                      alpha: 0.7,
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: const StadiumBorder(),
                                    textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: _RegisterStyle.buttonText,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Registreeru'),
                                            SizedBox(width: 18),
                                            Icon(Icons.arrow_forward, size: 30),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 38),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            const Text(
                              'Konto on juba olemas?',
                              style: TextStyle(
                                color: _RegisterStyle.textSoft,
                                fontSize: 18,
                                letterSpacing: 0,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: _RegisterStyle.lime,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _RegisterStyle.lime,
                                  letterSpacing: 0,
                                ),
                              ),
                              child: const Text('Logi sisse'),
                            ),
                          ],
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
}

class _RegisterStyle {
  static const background = Color(0xFF0B0B0B);
  static const panel = Color(0xB8141917);
  static const field = Color(0xCC070A0A);
  static const lime = Color(0xFFC6FF00);
  static const text = Color(0xFFE9ECE8);
  static const textSoft = Color(0xFFD2D6D1);
  static const muted = Color(0x8CE9ECE8);
  static const line = Color(0x22FFFFFF);
  static const buttonText = Color(0xFF101600);

  static TextStyle labelStyle() {
    return const TextStyle(
      color: lime,
      fontSize: 17,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
    );
  }
}

class _RegisterGlassCard extends StatelessWidget {
  const _RegisterGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 34),
      decoration: BoxDecoration(
        color: _RegisterStyle.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _RegisterStyle.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 34,
            offset: Offset(0, 22),
          ),
          BoxShadow(color: Color(0x2635F46E), blurRadius: 46),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x10FFFFFF), Color(0x02000000)],
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

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
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
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(label, style: _RegisterStyle.labelStyle()),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x2435F46E), blurRadius: 24),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: _RegisterStyle.lime,
            style: const TextStyle(
              color: _RegisterStyle.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: _RegisterStyle.muted,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              suffixIcon: suffixIcon,
              suffixIconColor: _RegisterStyle.lime,
              filled: true,
              fillColor: _RegisterStyle.field,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 22,
              ),
              border: _border(_RegisterStyle.line, 1),
              enabledBorder: _border(_RegisterStyle.line, 1),
              focusedBorder: _border(_RegisterStyle.lime, 1.6),
              errorBorder: _border(const Color(0xFFFFB4AB), 1),
              focusedErrorBorder: _border(const Color(0xFFFFB4AB), 1.6),
              errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _RegisterGlow extends StatelessWidget {
  const _RegisterGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x261BEF7B), Color(0x16C6FF00), Color(0x000B0B0B)],
        ),
      ),
    );
  }
}
