import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_repository.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';

class PedidoViewModel extends ChangeNotifier {
  PedidoViewModel({required PedidoRepository pedidoRepository})
      : _repository = pedidoRepository;

  final PedidoRepository _repository;
  List<PedidoPublic> _pedidos = [];
  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;
  String? _successMessage;
  PedidoEstado? _estado;
  StreamSubscription<String>? _suscripcionPersonal;
  Timer? _reconexionPersonal;
  bool _suscripcionSolicitada = false;

  List<PedidoPublic> get pedidos => List.unmodifiable(_pedidos);
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  PedidoEstado? get estado => _estado;

  void iniciarSuscripcionPersonal() {
    _suscripcionSolicitada = true;
    _conectarStreamPersonal();
  }

  void cerrarSuscripcionPersonal() {
    _suscripcionSolicitada = false;
    _reconexionPersonal?.cancel();
    _reconexionPersonal = null;
    final suscripcion = _suscripcionPersonal;
    _suscripcionPersonal = null;
    suscripcion?.cancel();
  }

  void _conectarStreamPersonal() {
    if (!_suscripcionSolicitada || _suscripcionPersonal != null) return;
    _reconexionPersonal?.cancel();
    _reconexionPersonal = null;
    _suscripcionPersonal = _repository.escucharCambiosPersonal().listen(
      (_) => cargarPedidosPersonal(estado: _estado),
      onError: (Object error) {
        _errorMessage = error.toString();
        notifyListeners();
        _programarReconexionPersonal();
      },
      onDone: _programarReconexionPersonal,
      cancelOnError: true,
    );
  }

  void _programarReconexionPersonal() {
    _suscripcionPersonal = null;
    if (!_suscripcionSolicitada) return;
    _reconexionPersonal?.cancel();
    _reconexionPersonal = Timer(
      const Duration(seconds: 3),
      _conectarStreamPersonal,
    );
  }

  Future<void> cargarMisPedidos({PedidoEstado? estado}) async {
    _estado = estado;
    await _cargar(() => _repository.misPedidos(estado));
  }

  Future<void> cargarPedidosPersonal({PedidoEstado? estado}) async {
    _estado = estado;
    await _cargar(() => _repository.listaPersonal(estado));
  }

  Future<PedidoPublic?> crear(Carrito carrito) => _operar(
    () => _repository.crear(carrito: carrito),
    'Pedido registrado correctamente',
  );

  Future<void> cancelar(int id) =>
      _hacer(() => _repository.cancelar(id), 'Pedido cancelado correctamente');

  Future<PedidoPublic?> confirmar(int id) =>
      _operar(() => _repository.confirmar(id), 'Pedido confirmado');

  Future<PedidoPublic?> rechazar(int id, String motivo) =>
      _operar(() => _repository.rechazar(id, motivo), 'Pedido rechazado');

  Future<PedidoPublic?> marcarListo(int id) =>
      _operar(() => _repository.listo(id), 'Pedido listo para recoger');

  Future<PedidoPublic?> entregarPorQr(String codigoQr, String metodoPago) =>
      _operar(() => _repository.entregarPorQr(codigoQr, metodoPago), 'Pedido entregado');

  Future<PedidoPublic?> buscarQr(String qr) =>
      _operar(() => _repository.getPedidoByQR(qr), null);

  Future<void> _cargar(Future<List<PedidoPublic>> Function() action) async {
    _isFetching = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _pedidos = await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<PedidoPublic?> _operar(
    Future<PedidoPublic> Function() action,
    String? success,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final pedido = await action();
      _successMessage = success;
      return pedido;
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _hacer(Future<void> Function() action, String success) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await action();
      _successMessage = success;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarMensajes() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    cerrarSuscripcionPersonal();
    super.dispose();
  }
}
