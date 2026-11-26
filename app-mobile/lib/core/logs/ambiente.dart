import 'package:flutter/material.dart';

/// Configuración por ambiente vía `--dart-define=AMBIENTE=dev|qa|prod`.
///
/// Ejemplo:
/// ```bash
/// flutter run --dart-define=AMBIENTE=qa
/// flutter run --release --dart-define=AMBIENTE=prod
/// ```
class Ambiente {
  const Ambiente._({
    required this.nombre,
    required this.apiBase,
    required this.logsVerbosos,
    required this.mostrarBanner,
  });

  final String nombre;
  final String apiBase;
  final bool logsVerbosos;
  final bool mostrarBanner;
  static const _dev = Ambiente._(
    nombre: 'dev',
    apiBase: 'https://dev.ecommerce.utez.local/api',
    logsVerbosos: true,
    mostrarBanner: true,
  );

  static const _qa = Ambiente._(
    nombre: 'qa',
    apiBase: 'https://qa.ecommerce.utez.edu.mx/api',
    logsVerbosos: true,
    mostrarBanner: true,
  );

  static const _prod = Ambiente._(
    nombre: 'prod',
    apiBase: 'https://api.ecommerce.utez.edu.mx',
    logsVerbosos: false,
    mostrarBanner: false,
  );

  static Ambiente get actual {
    const raw = String.fromEnvironment('AMBIENTE', defaultValue: 'dev');
    switch (raw.toLowerCase()) {
      case 'qa':
        return _qa;
      case 'prod':
      case 'production':
        return _prod;
      case 'dev':
      default:
        return _dev;
    }
  }
}
