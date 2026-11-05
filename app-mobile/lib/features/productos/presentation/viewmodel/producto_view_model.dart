import 'dart:io';

import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:flutter/material.dart';

class ProductoViewModel extends ChangeNotifier{
  ProductoViewModel({required ProductoRepository productoRepository})
      : _repository = productoRepository;

  final ProductoRepository _repository;

  List<Producto> _productos = [];
  List<String> _marcas = [];

  ProductoParams _productoParams = ProductoParams();

  bool _isFetching = false;
  bool _isLoading = false;
  bool _isLoadingMarcas = false;
  String? _errorMessage;
  String? _successMessage;

  ApiException? errorObj;
  ApiException? errorObjList;

  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  bool get isLoadingMarcas => _isLoadingMarcas;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Producto> get productos => _productos;
  List<String> get marcas => _marcas;
  ProductoParams get productoParams => _productoParams;

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

  Future<void> cargar([bool silencioso = false]) async {
    if(!silencioso) _comenzarFetch();
    _limpiarErrorObjList();
    try {
      _productos = await _repository.listaPersonal(_productoParams);
    } catch (error) {
      _errorMessage = _mensaje(error);
      _setErrorObjList(error);
    } finally {
      _terminarFetching();
    }
  }

  Future<void> cargarMarcas() async {
     _comenzarMarcas();
    try {
      _marcas = await _repository.listaMarcas();
    } finally {
      _terminarMarcas();
    }
  }

  Future<void> setParams(ProductoParams params) async {
    if (params == _productoParams) return;
    _productoParams = params;
    await cargar();
  }

  void resetParams(String tag) {
    _productoParams = ProductoParams();
    notifyListeners();
  }

  Future<Producto?> obtenerUnoPorId(int id) async{
    late final Producto prod;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      prod = await _repository.unoPorId(id);
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Producto?> obtenerUnoPorSKU(String sku) async{
    late final Producto prod;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      prod = await _repository.unoPorSku(sku);
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Producto?> obtenerUnoPorNombre(String name) async{
    late final Producto prod;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      prod = await _repository.unoPorNombre(name);
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Producto?> registrar({
    required ProductoRequestDto request,
    required File file
  }) async {
    late final Producto prod;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      prod = await _repository.crear(request,file);
      _successMessage = 'Producto registrado correctamente';
      cargar();
      cargarMarcas();
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Producto?> actualizar(ProductoRequestDto request, File? file, int id) async{
    late final Producto prod;
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      prod = await _repository.modificar(request, file ?? null, id);
      _successMessage = 'Producto actualizado correctamente';
      cargar();
      cargarMarcas();
      return prod;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<bool> borrar(int id) async{
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
      final msj = await _repository.eliminar(id);
      _successMessage = msj;
      cargar();
      cargarMarcas();
      return true;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return false;
    } finally{
      _terminarOperacion();
    }
  }

  Future<bool> cambiarEstado(int id) async{
    _limpiarErrorObj();
    _comenzarOperacion();
    try{
    final msj = await _repository.cambiarEstado(id);
      _successMessage = msj;
      cargar();
      cargarMarcas();
      return true;
    } catch (error){
      _errorMessage = _mensaje(error);
      _setErrorObj(error);
      return false;
    } finally{
      _terminarOperacion();
    }
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

  void _comenzarMarcas() {
    _isLoadingMarcas = true;
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

  void _terminarMarcas() {
    _isLoadingMarcas = false;
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