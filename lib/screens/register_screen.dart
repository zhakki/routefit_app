import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Loo konto',
      subtitle: 'Sea RouteFit profiil valmis ja alusta liikumist täna.',
      actionLabel: 'Registreeru',
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
