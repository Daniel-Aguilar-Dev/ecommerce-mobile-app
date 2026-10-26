import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_view_model.dart';
import 'widgets/auth_form_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<AuthViewModel>();
    final creado = await viewModel.registrar(
      nombre: _nameController.text,
      apellidos: _surnameController.text,
      correo: _emailController.text,
      telefono: _phoneController.text,
      contrasena: _passwordController.text,
    );
    if (creado && mounted) Navigator.of(context).pop(true);
  }

  String? _validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
    if (!value.contains('@')) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validarContrasena(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 8) return 'Usa al menos 8 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filledTonal(
                        tooltip: 'Volver al inicio de sesión',
                        onPressed: viewModel.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.chevron_left_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: const Color(0xFFF2783A),
                          backgroundColor: const Color(0xFFFFF0E8),
                          fixedSize: const Size(38, 38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        color: Color(0xFF303C55),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Regístrate para pedir y recoger en tienda.',
                      style: TextStyle(
                        color: Color(0xFF536078),
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AuthFormField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Ingresa tu nombre',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Ingresa tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      controller: _surnameController,
                      label: 'Apellidos',
                      hint: 'Ingresa tus apellidos',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Ingresa tus apellidos'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      controller: _emailController,
                      label: 'Correo electrónico:',
                      hint: 'example@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validarCorreo,
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      controller: _phoneController,
                      label: 'Teléfono de contacto:',
                      hint: 'Ingresa tu número',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
                          return 'Usa de 10 a 15 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      controller: _passwordController,
                      label: 'Contraseña:',
                      hint: 'Ingresa tu contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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
                      validator: _validarContrasena,
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      controller: _confirmationController,
                      label: 'Confirma tu contraseña:',
                      hint: 'Repite tu contraseña',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      suffix: IconButton(
                        tooltip: _obscureConfirmation
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                        icon: Icon(
                          _obscureConfirmation
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 19,
                        ),
                      ),
                      validator: (value) {
                        final error = _validarContrasena(value);
                        if (error != null) return error;
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    if (viewModel.errorMessage != null) ...[
                      const SizedBox(height: 13),
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 17),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _submit,
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Color(0xFFFF8438),
                          ),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Crear cuenta'),
                      ),
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
