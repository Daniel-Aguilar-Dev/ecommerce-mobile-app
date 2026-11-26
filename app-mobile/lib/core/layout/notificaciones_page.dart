import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_view_model.dart';
import 'layout_externo.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage>{

  @override
  Widget build(BuildContext context) {
    late final status = context.select<AuthViewModel, AuthStatus>((a) => a.status);
    return Scaffold(
      appBar: AppBarExterno(title: "Notificaciones"),
      body: SafeArea(child:
        Padding(
          padding: .all(16),
          child: Text("Notificaciones wey $status"),
        )
      ),
    );
  }
}