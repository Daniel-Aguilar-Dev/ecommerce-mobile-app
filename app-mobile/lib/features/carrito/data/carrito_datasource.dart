import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:hive/hive.dart';

import '../domain/carrito.dart';

class CarritoLocalDatasource {
  CarritoLocalDatasource({required Box<dynamic> db}) : _db = db;

  final Box<dynamic> _db;

  static const _key = 'carrito';

  void inicializarCarrito() {
    _db.put(_key, Carrito.vacio().toJson());
  }

  Carrito obtenerCarrito() {
    final carrito =  Carrito.fromJson(_db.get(_key));
    return carrito;
  }

  int _contar(List<CarritoItem> items) =>
      items.fold<int>(0, (suma, item) => suma + item.cantidad);

  void agregarAlCarrito(ProductoPublic prod, int cantidad) {
    final items = List<CarritoItem>.from(obtenerCarrito().items);

    final index = items.indexWhere((i) => i.producto.id == prod.id);
    if (index >= 0) {
      final actual = items[index];
      items[index] =
          CarritoItem(producto: actual.producto, cantidad: actual.cantidad + cantidad);
    } else {
      items.add(CarritoItem(producto: prod, cantidad: cantidad));
    }

    _db.put(_key, Carrito(items: items, cantidad: _contar(items)).toJson());
  }

  void quitarDelCarrito(int prodId) {
    final items = obtenerCarrito()
        .items
        .where((p) => p.producto.id != prodId)
        .toList();

    _db.put(_key, Carrito(items: items, cantidad: _contar(items)).toJson());
  }

  void actualizarCarrito(Carrito carrito) {
    _db.put(_key, carrito.toJson());
  }

  void vaciarCarrito() {
    inicializarCarrito();
  }

  Future<void> limpiarCarrito() async{
    await _db.close();
  }
}