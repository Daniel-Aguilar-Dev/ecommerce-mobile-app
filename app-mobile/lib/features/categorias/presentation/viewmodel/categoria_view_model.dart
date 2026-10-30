import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:flutter/cupertino.dart';

class CategoriaViewModel extends ChangeNotifier{
  CategoriaViewModel({required CategoriaRepository categoriaRepository})
      : _repository = categoriaRepository;

  final CategoriaRepository _repository;

  List<Categoria> _categorias = [];

  bool _isFetching = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Categoria> get categorias => _categorias;


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

  Future<void> cargar([String? query]) async {
    _comenzarFetch();
    try {
      _categorias = await _repository.listaPersonal(query);
    } catch (error) {
      _errorMessage = _mensaje(error);
    } finally {
      _terminarFetching();
    }
  }

  Future<Categoria?> obtenerUno(int id) async{
    late final Categoria cat;
    _comenzarOperacion();
    try{
      cat = await _repository.unaPorId(id);
      return cat;
    } catch (error){
      _errorMessage = _mensaje(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Categoria?> registrar(CategoriaRequestDto request) async {
    late final Categoria cat;
    _comenzarOperacion();
    try{
      cat = await _repository.crear(descripcion:request.descripcion, nombre: request.nombre);
      _successMessage = 'Categoría registrada correctamente';
      cargar();
      return cat;
    } catch (error){
      _errorMessage = _mensaje(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<Categoria?> actualizar(CategoriaRequestDto request, int id) async{
    late final Categoria cat;
    _comenzarOperacion();
    try{
      cat = await _repository.modificar(id:id, descripcion:request.descripcion, nombre: request.nombre);
      _successMessage = 'Categoría actualizada correctamente';
      cargar();
      return cat;
    } catch (error){
      _errorMessage = _mensaje(error);
      return null;
    } finally{
      _terminarOperacion();
    }
  }

  Future<bool> borrar(int id) async{
    _comenzarOperacion();
    try{
      await _repository.eliminar(id);
      _successMessage = 'Categoría actualizada correctamente';
      cargar();
      return true;
    } catch (error){
      _errorMessage = _mensaje(error);
    } finally{
      _terminarOperacion();
      return false;
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

  void _terminarFetching() {
    _isFetching = false;
    notifyListeners();
  }

  void _terminarOperacion() {
    _isLoading = false;
    notifyListeners();
  }

  String _mensaje(Object error) {
    if (error is ApiException) return error.message;
    if (error is String) return error;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}