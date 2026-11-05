import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/carrito/data/carrito_datasource.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:flutter/foundation.dart';

class CarritoViewModel extends ChangeNotifier {
  CarritoViewModel({ required ProductoRepository productoRepository, required this.carritoDatasource })
      : _repository = productoRepository;

  final ProductoRepository _repository;
  final CarritoLocalDatasource carritoDatasource;

  List<ProductoPublic> _productos = [];

  ProductoParamsPublic _productoParams = ProductoParamsPublic();

  bool _isFetching = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int _checkingStockId = 0;

  ApiException? errorObj;
  ApiException? errorObjList;

  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<ProductoPublic> get productos => _productos;
  ProductoParamsPublic get productoParams => _productoParams;
  int get checkingStockId => _checkingStockId;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> agregarUnoAlCarrito(ProductoPublic prod) async{
    _checkingStockId = prod.id;
    await checarStock(prod, 1);
    if(_errorMessage != ""){
      carritoDatasource.agregarAlCarrito(prod, 1);
    }
    _checkingStockId = 0;
  }

  Future<void> cargar() async {
     _comenzarFetch();
     _limpiarErrorObjList();
    try {
      final list = await _repository.listaPublica(_productoParams);
      _productos = list;
    } catch (error) {
      _errorMessage = _mensaje(error);
      _setErrorObjList(error);
    } finally {
      _terminarFetching();
    }
  }

  void cargarCarrito(){
    carritoDatasource.inicializarCarrito();
  }

  Future<ProductoPublic?> obtenerUnoPorId(int id) async{
    late final ProductoPublic prod;
    _comenzarOperacion();
    _limpiarErrorObj();
    try{
      prod = await _repository.unoPublicoPorId(id);
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<int> checarStock(ProductoPublic prod, int cantidad) async{
    int stockActual = prod.stock;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      stockActual = await _repository.validarStock(prod.id, cantidad);
      return stockActual;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
    } finally{
      _terminarOperacion();
    }
    return stockActual;
  }

  Future<List<StockLineaResponseDto>> checarStockCarrito(Carrito carrtio) async{
    _comenzarOperacion();
    _limpiarErrorObj();
    try{
      return await _repository.validarCarrito(carrtio);
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return [];
    } finally{
      _terminarOperacion();
    }
  }

  Future<List<ProductoPublic>> getProudctosSimilares(int categoria) async{
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      return await _repository.listaPublica(ProductoParamsPublic(categoria: categoria));
    } catch (_){
      return [];
    } finally{
      _terminarOperacion();
    }
  }

  Future<void> setParams(ProductoParamsPublic params) async {
    if (params == _productoParams) return;
    _productoParams = params;
    await cargar();
  }

  Future<void> limpiarCarrito()async{
    await carritoDatasource.limpiarCarrito();
  }

  void resetParams(String tag) {
    _productoParams = ProductoParamsPublic();
    notifyListeners();
  }

  void limpiarMensajes() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _comenzarFetch() {
    _isFetching = true;
    notifyListeners();
  }

  void _comenzarOperacion() {
    _isLoading = true;
    notifyListeners();
  }
  
  void _terminarFetching() {
    _isFetching = false;
    notifyListeners();
  }

  void _terminarOperacion() {
    _isLoading = false;
    notifyListeners();
  }

  void _limpiarErrorObjList() => errorObjList = null;

  void _limpiarErrorObj() => errorObj = null;

  void _setErrorObj(Object error){
    if(error is ApiException){
      errorObj = error;
    }
  }

  void _setErrorObjList(Object error){
    if(error is ApiException){
      errorObjList = error;
    }
  }

  String _mensaje(Object error) {
    if (error is ApiException) return error.message;
    if (error is String) return error;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}