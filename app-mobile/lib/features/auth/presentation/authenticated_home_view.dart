import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_view_model.dart';

/// Destino temporal para confirmar la navegación de una sesión autenticada.
/// Se reemplazará por la pantalla principal del ecommerce.
class AuthenticatedHomeView extends StatelessWidget {
  const AuthenticatedHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final usuario = viewModel.session?.usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack Store'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: viewModel.isLoading ? null : viewModel.cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/cart_logo.png',
                width: 150,
                height: 145,
              ),
              const SizedBox(height: 18),
              Text(
                '¡Bienvenido${usuario?.nombre == null ? '' : ', ${usuario!.nombre}'}!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF303C55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(usuario?.correo ?? ''),
              const SizedBox(height: 20),
              const Text(
                'La sesión está activa y sus tokens se renovarán al recibir un 401.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
