import 'package:ecommerce_app/features/auth/domain/role_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/layout/layout_externo.dart';
import 'auth_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

//Este es para el perfil del empleado y admin porque tiene un appbar
class _ProfilePageState extends State<ProfilePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarExterno(title: "Mi perfil"),
      body: ProfileScreen()
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//Este es para el cliente, es lo mismo pero sin el appbar
class _ProfileScreenState extends State<ProfileScreen>{
  Future<void> _salir(AuthViewModel viewModel) async {
    final role = viewModel.session?.usuario.rol;
    final isCliente = role == RoleEnum.CLIENTE.name;
    await viewModel.cerrarSesion();
    if(!isCliente) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    return SafeArea(child:
      Padding(
        padding: .all(16),
        child: Column(
          children: [
            Text("Mi perfil wey"),
            FilledButton(onPressed: () => _salir(viewModel), child: const Text("cerrar sesión"))
          ],
        )
      )
    );
  }
}