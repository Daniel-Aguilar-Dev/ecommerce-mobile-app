import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_view_model.dart';
import 'register_view.dart';
import 'widgets/auth_form_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<AuthViewModel>();
    await viewModel.iniciarSesion(
      correo: _emailController.text,
      contrasena: _passwordController.text,
    );
  }

  Future<void> _abrirRegistro() async {
    context.read<AuthViewModel>().limpiarMensajes();
    final cuentaCreada = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const RegisterView()));
    if (!mounted || cuentaCreada != true) return;
    context.read<AuthViewModel>().limpiarMensajes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada. Ahora puedes iniciar sesión.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/cart_logo.png',
                        width: 170,
                        height: 165,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Color(0xFF303C55),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Inicia sesión para hacer tu pedido.',
                      style: TextStyle(color: Color(0xFF536078), fontSize: 14),
                    ),
                    const SizedBox(height: 25),
                    AuthFormField(
                      controller: _emailController,
                      label: 'Correo electrónico:',
                      hint: 'example@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu correo electrónico';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    AuthFormField(
                      controller: _passwordController,
                      label: 'Contraseña:',
                      hint: 'Ingresa tu contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 19,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa tu contraseña'
                          : null,
                    ),
                    if (viewModel.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _AuthMessage(
                        text: viewModel.errorMessage!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 19),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _submit,
                        style: _buttonStyle,
                        child: viewModel.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta? ',
                          style: TextStyle(fontSize: 13),
                        ),
                        TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : _abrirRegistro,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF6C22),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Regístrate'),
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

const _buttonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(Color(0xFFFF8438)),
  foregroundColor: WidgetStatePropertyAll(Colors.white),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFB3261E) : const Color(0xFF236B42);
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}
