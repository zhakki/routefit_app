import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_user_flow_service.dart';
import '../widgets/app_widgets.dart';
import 'app_shell.dart';
import 'auth_scaffold.dart';

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
        weightKg: 70.0,
        heightCm: 170.0,
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
    return AuthScaffold(
      title: 'Loo konto',
      subtitle: 'Sea RouteFit profiil valmis ja alusta liikumist täna.',
      actionLabel: _isLoading ? 'Palun oota...' : 'Registreeru',
      footerText: 'Konto on juba olemas?',
      footerAction: 'Logi sisse',
      onFooterTap: () => Navigator.of(context).pop(),
      formKey: _formKey,
      onSubmit: _submit,
      children: [
        AppTextField(
          controller: _name,
          label: 'Nimi',
          icon: Icons.person_outline,
          validator: (value) => isBlank(value) ? 'Sisesta nimi' : null,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _email,
          label: 'E-post',
          icon: Icons.mail_outline,
          validator: validateEmail,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _password,
          label: 'Parool',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: validatePassword,
        ),
      ],
    );
  }
}
