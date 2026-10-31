import 'dart:async';

import 'package:ecommerce_app/core/network/public_api_client.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/categorias/data/categoria_data_source.dart';
import 'package:ecommerce_app/features/categorias/data/repositories/categoria_repository_impl.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/network/authenticated_api_client.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/local/secure_auth_token_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/presentation/auth_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // En el emulador Android, 10.0.2.2 apunta al host donde corre Spring Boot.
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  final apiClient = ApiClient(baseUrl: baseUrl);
  final tokenStorage = SecureAuthTokenStorage();
  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );
  final authViewModel = AuthViewModel(authRepository: authRepository);
  final protectedApiClient = AuthenticatedApiClient(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
    authRepository: authRepository,
    onSessionExpired: authViewModel.expirarSesion,
  );
  final publicApiClient = PublicApiClient(apiClient: apiClient);
  final categoriaRepository = CategoriaRepositoryImpl(
      datasource: CategoriaDataSource(
          apiClientAuth: protectedApiClient,
          apiClientPublic: publicApiClient
      )
  );

  // La revisión inicial rota el refresh token guardado si todavía es válido.
  unawaited(authViewModel.inicializar());

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<CategoriaRepository>.value(value: categoriaRepository),
        Provider<AuthenticatedApiClient>.value(value: protectedApiClient),
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      ],
      child: const EcommerceApp(),
    ),
  );
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      theme: ECommerceAppTheme.build(),
      home: const AuthGate(),
    );
  }
}

/// Alias conservado por compatibilidad con el punto de entrada del template.
class MyApp extends EcommerceApp {
  const MyApp({super.key});
}
