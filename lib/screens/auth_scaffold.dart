import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_widgets.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.footerText,
    required this.footerAction,
    required this.onFooterTap,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    super.key,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final String footerText;
  final String footerAction;
  final VoidCallback onFooterTap;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RouteFitLogo(),
                    const SizedBox(height: 36),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(color: RouteFitColors.muted),
                    ),
                    const SizedBox(height: 28),
                    ...children,
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onSubmit,
                      style: appButtonStyle(),
                      child: Text(actionLabel),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          footerText,
                          style: const TextStyle(color: RouteFitColors.muted),
                        ),
                        TextButton(
                          onPressed: onFooterTap,
                          child: Text(footerAction),
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
    );
  }
}
