import 'dart:io';

import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_repository.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';

final categoriaEjemplo = Categoria(
  id: 3,
  nombre: 'Bebidas',
  descripcion: 'Bebidas frías',
  tieneProductos: true,
);

final categoriaPublicaEjemplo = CategoriaPublic(
  id: 3,
  nombre: 'Bebidas',
  descripcion: 'Bebidas frías',
);

final productoPublicoEjemplo = ProductoPublic(
  id: 8,
  nombre: 'Agua',
  descripcion: 'Agua natural',
  marca: 'Marca',
  sku: '7501234567890',
  stock: 8,
  precio: 12.5,
  unidadMedia: 'PZA',
  estado: ProductoEstado.PROD_ACTIVO,
  categoria: categoriaPublicaEjemplo,
  imagen: '',
  estadoStock: 'Disponible',
);

final productoJugoEjemplo = ProductoPublic(
  id: 9,
  nombre: 'Jugo',
  descripcion: 'Jugo de naranja',
  marca: 'Marca',
  sku: '7501234567891',
  stock: 5,
  precio: 5,
  unidadMedia: 'PZA',
  estado: ProductoEstado.PROD_ACTIVO,
  categoria: categoriaPublicaEjemplo,
  imagen: '',
  estadoStock: 'Disponible',
);

final productoEjemplo = Producto(
  id: 8,
  nombre: 'Agua',
  descripcion: 'Agua natural',
  marca: 'Marca',
  sku: '7501234567890',
  stockActual: 8,
  stockMinimo: 2,
  stockReservado: 0,
  precioVenta: 12.5,
  precioCompra: 6,
  unidadMedia: 'PZA',
  estado: ProductoEstado.PROD_ACTIVO,
  costoPromedio: 6,
  categoria: categoriaEjemplo,
  imagenPublicId: 'img-8',
  imagenVersion: 1,
  imagenUrl: '',
);

ProductoRequestDto solicitudProductoEjemplo({int stock = 8}) =>
    ProductoRequestDto(
      nombre: 'Agua',
      descripcion: 'Agua natural',
      marca: 'Marca',
      sku: '7501234567890',
      stockActual: stock,
      stockMinimo: 2,
      stockReservado: 0,
      precioVenta: 12.5,
      precioCompra: 6,
      unidadMedia: 'PZA',
      estado: ProductoEstado.PROD_ACTIVO,
      categoria: const {'id': 3},
    );

PedidoPublic pedidoEjemplo({
  PedidoEstado estado = PedidoEstado.PED_PENDIENTE,
  String? codigoQr,
}) => PedidoPublic(
  id: 21,
  estado: estado,
  costo: 25,
  fecha: DateTime(2026, 1, 1),
  carrito: const [
    PedidoItem(
      productoId: 8,
      nombre: 'Agua',
      cantidad: 2,
      precioUnitario: 12.5,
    ),
  ],
  numPedido: 21,
  textPedido: '00021',
  clienteId: 5,
  clienteNombre: 'Ana Cliente',
  codigoQr: codigoQr,
  entregable: estado == PedidoEstado.PED_LISTO,
);

class FakeProductoRepository implements ProductoRepository {
  List<Producto> productos = [productoEjemplo];
  List<ProductoPublic> productosPublicos = [productoPublicoEjemplo];
  Object? errorConsulta;
  Object? errorMutacion;
  int stockDisponible = 8;
  List<StockLineaResponseDto> erroresCarrito = const [];
  int? ultimoId;
  String? ultimoSku;
  ProductoParams? ultimosParametros;
  ProductoRequestDto? ultimaSolicitud;

  @override
  Future<List<ProductoPublic>> listaPublica(
    ProductoParamsPublic? params,
  ) async => productosPublicos;
  @override
  Future<List<Producto>> listaPersonal(ProductoParams? params) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimosParametros = params;
    return productos;
  }

  @override
  Future<ProductoPublic> unoPublicoPorId(int id) async =>
      productoPublicoEjemplo;
  @override
  Future<Producto> unoPorId(int id) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimoId = id;
    return productoEjemplo;
  }

  @override
  Future<Producto> unoPorNombre(String nombre) async => productoEjemplo;
  @override
  Future<Producto> unoPorSku(String sku) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimoSku = sku;
    return productoEjemplo;
  }

  @override
  Future<List<String>> listaMarcas() async => ['Marca'];
  @override
  Future<int> validarStock(int id, int cantidad) async => stockDisponible;
  @override
  Future<List<StockLineaResponseDto>> validarCarrito(Carrito carrito) async =>
      erroresCarrito;
  @override
  Future<Producto> crear(ProductoRequestDto dto, File file) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimaSolicitud = dto;
    return productoEjemplo;
  }

  @override
  Future<Producto> modificar(ProductoRequestDto dto, File? file, int id) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimaSolicitud = dto;
    ultimoId = id;
    return productoEjemplo;
  }

  @override
  Future<String> cambiarEstado(int id) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = id;
    return 'Producto descontinuado correctamente';
  }

  @override
  Future<String> eliminar(int id) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = id;
    return 'Producto eliminado correctamente';
  }
}

class FakeCategoriaRepository implements CategoriaRepository {
  List<Categoria> categorias = [categoriaEjemplo];
  Object? errorConsulta;
  Object? errorMutacion;
  int? ultimoId;
  String? ultimoNombre;

  @override
  Future<List<CategoriaPublic>> listaPublica() async => [
    categoriaPublicaEjemplo,
  ];
  @override
  Future<List<Categoria>> listaPersonal([String? query]) async {
    if (errorConsulta != null) throw errorConsulta!;
    return categorias;
  }

  @override
  Future<CategoriaPublic> unaPublicaPorId(int id) async =>
      categoriaPublicaEjemplo;
  @override
  Future<Categoria> unaPorId(int id) async => categoriaEjemplo;
  @override
  Future<Categoria> crear({
    required String nombre,
    required String descripcion,
  }) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoNombre = nombre;
    return Categoria(
      id: 4,
      nombre: nombre,
      descripcion: descripcion,
      tieneProductos: false,
    );
  }

  @override
  Future<Categoria> modificar({
    required int id,
    required String nombre,
    required String descripcion,
  }) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = id;
    ultimoNombre = nombre;
    return Categoria(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tieneProductos: true,
    );
  }

  @override
  Future<String> eliminar(int id) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = id;
    return 'Categoría eliminada correctamente';
  }
}

class FakePedidoRepository implements PedidoRepository {
  List<PedidoPublic> pedidosCliente = [pedidoEjemplo()];
  List<PedidoPublic> pedidosPersonal = [pedidoEjemplo()];
  Object? errorConsulta;
  Object? errorMutacion;
  PedidoEstado? ultimoEstado;
  int? ultimoId;
  String? ultimoMotivo;
  String? ultimoQr;
  String? ultimoMetodoPago;
  Carrito? ultimoCarrito;

  @override
  Stream<String> escucharCambiosPersonal() => const Stream.empty();
  @override
  Future<List<PedidoPublic>> misPedidos(PedidoEstado? estado) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimoEstado = estado;
    return pedidosCliente;
  }

  @override
  Future<List<PedidoPublic>> listaPersonal(PedidoEstado? estado) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimoEstado = estado;
    return pedidosPersonal;
  }

  @override
  Future<PedidoPublic> getMiPedido(int pedidoId) async => pedidoEjemplo();
  @override
  Future<PedidoPublic> getUnPedido(int pedidoId) async => pedidoEjemplo();
  @override
  Future<PedidoPublic> getPedidoByQR(String codigoQr) async {
    if (errorConsulta != null) throw errorConsulta!;
    ultimoQr = codigoQr;
    return pedidoEjemplo(estado: PedidoEstado.PED_LISTO, codigoQr: codigoQr);
  }

  @override
  Future<PedidoPublic> crear({required Carrito carrito}) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoCarrito = carrito;
    return pedidoEjemplo();
  }

  @override
  Future<void> cancelar(int pedidoId) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = pedidoId;
  }

  @override
  Future<PedidoPublic> confirmar(int pedidoId) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = pedidoId;
    return pedidoEjemplo(estado: PedidoEstado.PED_CONFIRMADO);
  }

  @override
  Future<PedidoPublic> rechazar(int pedidoId, String motivo) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = pedidoId;
    ultimoMotivo = motivo;
    return pedidoEjemplo(estado: PedidoEstado.PED_CANCELADO);
  }

  @override
  Future<PedidoPublic> listo(int pedidoId) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoId = pedidoId;
    return pedidoEjemplo(estado: PedidoEstado.PED_LISTO, codigoQr: 'qr-21');
  }

  @override
  Future<PedidoPublic> entregarPorQr(String codigoQr, String metodoPago) async {
    if (errorMutacion != null) throw errorMutacion!;
    ultimoQr = codigoQr;
    ultimoMetodoPago = metodoPago;
    return pedidoEjemplo(
      estado: PedidoEstado.PED_ENTREGADO,
      codigoQr: codigoQr,
    );
  }
}
