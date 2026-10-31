import 'package:ecommerce_app/core/layout/app_shell.dart';
import 'package:ecommerce_app/core/layout/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_view_model.dart';

import 'login_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        switch (viewModel.status) {
          case AuthStatus.checking:
            return const SplashScreen();
          case AuthStatus.authenticated:
            //return const AuthenticatedHomeView();
            return const AppShell();
          case AuthStatus.unauthenticated:
            //return const LoginView();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            });
            return const LoginView();
        }
      },
    );
  }
}
