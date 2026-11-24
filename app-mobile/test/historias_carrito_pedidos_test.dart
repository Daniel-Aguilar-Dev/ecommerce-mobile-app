import 'dart:io';

import 'package:ecommerce_app/core/ui/cantidad_input.dart';
import 'package:ecommerce_app/features/carrito/data/carrito_datasource.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/carrito/presentation/viewmodel/carrito_view_model.dart';
import 'package:ecommerce_app/features/pedidos/data/models/pedido_request_dto.dart';
import 'package:ecommerce_app/features/pedidos/data/models/pedido_response_dto.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/presentation/viewmodel/pedido_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'helpers/historia_fakes.dart';

void main() {
  late Directory hiveDir;
  var boxIndex = 0;

  setUpAll(() {
    hiveDir = Directory.systemTemp.createTempSync('ecommerce-historias-');
    Hive.init(hiveDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) hiveDir.deleteSync(recursive: true);
  });

  Future<(Box<dynamic>, CarritoLocalDatasource)> nuevoCarrito() async {
    final box = await Hive.openBox<dynamic>('carrito_${boxIndex++}');
    final source = CarritoLocalDatasource(db: box)..inicializarCarrito();
    addTearDown(() async {
      await box.close();
      await Hive.deleteBoxFromDisk(box.name);
    });
    return (box, source);
  }

  group('HU-5.1 Agregar producto al carrito', () {
    test('Agregar una unidad crea una línea con cantidad uno', () async {
      final (_, source) = await nuevoCarrito();
      final products = FakeProductoRepository();
      final vm = CarritoViewModel(
        productoRepository: products,
        carritoDatasource: source,
      );
      addTearDown(vm.dispose);
      await vm.agregarUnoAlCarrito(productoPublicoEjemplo);
      expect(vm.obtenerCarrito().items.single.cantidad, 1);
    });

    test('No agrega un producto agotado', () async {
      final (_, source) = await nuevoCarrito();
      final products = FakeProductoRepository()..stockDisponible = 0;
      final vm = CarritoViewModel(
        productoRepository: products,
        carritoDatasource: source,
      );
      addTearDown(vm.dispose);
      await vm.agregarUnoAlCarrito(productoPublicoEjemplo);
      expect(vm.obtenerCarrito().items, isEmpty);
      expect(vm.errorMessage, 'Producto agotado');
    });
  });

  group('HU-5.2 Consultar carrito', () {
    test('Calcula subtotal de línea y total estimado', () {
      final carrito = Carrito(
        items: [
          CarritoItem(producto: productoPublicoEjemplo, cantidad: 2),
          CarritoItem(producto: productoJugoEjemplo, cantidad: 3),
        ],
        cantidad: 5,
      );
      expect(carrito.items.first.subtotal, 25);
      expect(carrito.total, 40);
    });

    test('El carrito vacío se reconoce y totaliza en cero', () {
      const carrito = Carrito.vacio();
      expect(carrito.estaVacio, isTrue);
      expect(carrito.total, 0);
    });
  });

  group('HU-5.3 Ajustar cantidad', () {
    testWidgets(
      'El botón menos se bloquea en el mínimo y el más aumenta cantidad',
      (tester) async {
        final cambios = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CantidadInput(
                max: 3,
                min: 1,
                defaultValue: 1,
                onChange: cambios.add,
              ),
            ),
          ),
        );
        await tester.tap(find.byIcon(LucideIcons.minus));
        await tester.pump();
        expect(find.text('1'), findsOneWidget);
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pump();
        expect(find.text('2'), findsOneWidget);
        expect(cambios, [2]);
      },
    );

    testWidgets('El botón más se bloquea al alcanzar el stock máximo', (
      tester,
    ) async {
      final cambios = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CantidadInput(
              max: 2,
              min: 1,
              defaultValue: 2,
              onChange: cambios.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      expect(cambios, isEmpty);
    });
  });

  group('HU-5.4 Remover producto del carrito', () {
    test('Quitar una línea la elimina sin afectar la otra', () async {
      final (_, source) = await nuevoCarrito();
      source.agregarAlCarrito(productoPublicoEjemplo, 2);
      source.agregarAlCarrito(productoJugoEjemplo, 1);
      source.quitarDelCarrito(8);
      final carrito = source.obtenerCarrito();
      expect(carrito.items.map((i) => i.producto.nombre), ['Jugo']);
      expect(carrito.cantidad, 1);
    });

    test('Quitar la última línea deja el carrito vacío y total cero', () async {
      final (_, source) = await nuevoCarrito();
      source.agregarAlCarrito(productoPublicoEjemplo, 2);
      source.quitarDelCarrito(8);
      expect(source.obtenerCarrito().estaVacio, isTrue);
      expect(source.obtenerCarrito().total, 0);
    });
  });

  group('HU-5.5 Confirmar carrito', () {
    test(
      'Con stock disponible crea pedido y vacía carrito solo tras éxito',
      () async {
        final (_, source) = await nuevoCarrito();
        source.agregarAlCarrito(productoPublicoEjemplo, 2);
        final cartVm = CarritoViewModel(
          productoRepository: FakeProductoRepository(),
          carritoDatasource: source,
        );
        final orders = FakePedidoRepository();
        final orderVm = PedidoViewModel(pedidoRepository: orders);
        addTearDown(cartVm.dispose);
        addTearDown(orderVm.dispose);
        final stockErrors = await cartVm.checarStockCarrito(
          cartVm.obtenerCarrito(),
        );
        expect(stockErrors, isEmpty);
        final pedido = await orderVm.crear(cartVm.obtenerCarrito());
        if (pedido != null) cartVm.vaciarCarrito();
        expect(orders.ultimoCarrito?.items.single.cantidad, 2);
        expect(cartVm.obtenerCarrito().estaVacio, isTrue);
      },
    );

    test('Si el backend falla, conserva el carrito para reintentar', () async {
      final (_, source) = await nuevoCarrito();
      source.agregarAlCarrito(productoPublicoEjemplo, 1);
      final cartVm = CarritoViewModel(
        productoRepository: FakeProductoRepository(),
        carritoDatasource: source,
      );
      final orders = FakePedidoRepository()
        ..errorMutacion = StateError('Sin conexión');
      final orderVm = PedidoViewModel(pedidoRepository: orders);
      addTearDown(cartVm.dispose);
      addTearDown(orderVm.dispose);
      final stockErrors = await cartVm.checarStockCarrito(
        cartVm.obtenerCarrito(),
      );
      expect(stockErrors, isEmpty);
      final pedido = await orderVm.crear(cartVm.obtenerCarrito());
      if (pedido != null) cartVm.vaciarCarrito();
      expect(cartVm.obtenerCarrito().items.single.cantidad, 1);
      expect(orderVm.errorMessage, contains('Sin conexión'));
    });
  });

  group('HU-6.1 Generar pedido', () {
    test('El DTO manda las líneas y el precio snapshot del carrito', () {
      final dto = PedidoRequestDto(
        carrito: Carrito(
          items: [CarritoItem(producto: productoPublicoEjemplo, cantidad: 2)],
          cantidad: 2,
        ),
      );
      final body = dto.toJson();
      final carrito = body['carrito'] as Map<String, Object?>;
      final items = carrito['items'] as List<Object?>;
      final item = items.single as Map<String, Object?>;
      final producto = item['producto'] as Map<String, Object?>;
      expect(item['cantidad'], 2);
      expect(producto['id'], 8);
      expect(producto['precioVenta'], 12.5);
      expect(producto['stockActual'], 8);
      expect(producto['stockMinimo'], 0);
      expect(producto['stockReservado'], 0);
    });

    test(
      'La creación devuelve pedido pendiente asociado a sus productos',
      () async {
        final repo = FakePedidoRepository();
        final vm = PedidoViewModel(pedidoRepository: repo);
        addTearDown(vm.dispose);
        final carrito = Carrito(
          items: [CarritoItem(producto: productoPublicoEjemplo, cantidad: 1)],
          cantidad: 1,
        );
        final pedido = await vm.crear(carrito);
        expect(pedido?.estado, PedidoEstado.PED_PENDIENTE);
        expect(repo.ultimoCarrito?.items.single.producto.id, 8);
      },
    );
  });

  group('HU-6.2 Consultar mis pedidos', () {
    test('Carga el historial del cliente y pasa el filtro de estado', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      await vm.cargarMisPedidos(estado: PedidoEstado.PED_ENTREGADO);
      expect(repo.ultimoEstado, PedidoEstado.PED_ENTREGADO);
      expect(vm.pedidos, hasLength(1));
    });

    test(
      'Un error al consultar se expone y apaga el indicador de carga',
      () async {
        final repo = FakePedidoRepository()
          ..errorConsulta = StateError('Sin sesión');
        final vm = PedidoViewModel(pedidoRepository: repo);
        addTearDown(vm.dispose);
        await vm.cargarMisPedidos();
        expect(vm.errorMessage, contains('Sin sesión'));
        expect(vm.isFetching, isFalse);
      },
    );
  });

  group('HU-6.3 Cancelar pedido pendiente', () {
    test('Envía el ID de pedido al repositorio de cancelación', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      await vm.cancelar(21);
      expect(repo.ultimoId, 21);
      expect(vm.successMessage, 'Pedido cancelado correctamente');
    });

    test('Una cancelación rechazada por estado conserva el error', () async {
      final repo = FakePedidoRepository()
        ..errorMutacion = StateError('Tu pedido ya no se puede cancelar');
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      await vm.cancelar(21);
      expect(vm.errorMessage, contains('ya no se puede cancelar'));
    });
  });

  group('HU-6.4 Consultar pedidos entrantes', () {
    test('La vista personal pide pedidos con el estado seleccionado', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      await vm.cargarPedidosPersonal(estado: PedidoEstado.PED_PENDIENTE);
      expect(repo.ultimoEstado, PedidoEstado.PED_PENDIENTE);
      expect(vm.pedidos.single.clienteNombre, 'Ana Cliente');
    });

    test('La lista personal acepta respuesta vacía', () async {
      final repo = FakePedidoRepository()..pedidosPersonal = [];
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      await vm.cargarPedidosPersonal();
      expect(vm.pedidos, isEmpty);
      expect(vm.errorMessage, isNull);
    });
  });

  group('HU-6.5 Confirmar pedido', () {
    test('Confirma el pedido y cambia a estado confirmado', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      final pedido = await vm.confirmar(21);
      expect(repo.ultimoId, 21);
      expect(pedido?.estado, PedidoEstado.PED_CONFIRMADO);
    });

    test('El error de stock insuficiente se muestra y no confirma', () async {
      final repo = FakePedidoRepository()
        ..errorMutacion = StateError('Stock insuficiente');
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.confirmar(21), isNull);
      expect(vm.errorMessage, contains('Stock insuficiente'));
    });
  });

  group('HU-6.6 Rechazar pedido', () {
    test('Envía el motivo y deja el pedido cancelado', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      final pedido = await vm.rechazar(21, 'Sin disponibilidad');
      expect(repo.ultimoMotivo, 'Sin disponibilidad');
      expect(pedido?.estado, PedidoEstado.PED_CANCELADO);
    });

    test('Un motivo rechazado por backend no cambia el estado', () async {
      final repo = FakePedidoRepository()
        ..errorMutacion = StateError('El motivo es obligatorio');
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.rechazar(21, ''), isNull);
      expect(vm.errorMessage, contains('obligatorio'));
    });
  });

  group('HU-6.7 Marcar pedido listo para recoger', () {
    test('Cambia el pedido confirmado a listo y devuelve QR', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      final pedido = await vm.marcarListo(21);
      expect(pedido?.estado, PedidoEstado.PED_LISTO);
      expect(pedido?.codigoQr, 'qr-21');
    });

    test('No marca listo si backend rechaza el estado previo', () async {
      final repo = FakePedidoRepository()
        ..errorMutacion = StateError(
          'Solo un pedido confirmado puede marcarse como listo',
        );
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.marcarListo(21), isNull);
      expect(vm.errorMessage, contains('confirmado'));
    });
  });

  group('HU-6.8 Código QR de pedido listo', () {
    test('El DTO conserva el QR cuando el pedido está listo', () {
      final dto = PedidoResponseDto.fromJson(
        _pedidoJson(estado: 'PED_LISTO', codigoQr: 'qr-21'),
      );
      expect(dto.pedido.codigoQr, 'qr-21');
      expect(dto.pedido.estado, PedidoEstado.PED_LISTO);
    });

    test('Un pedido pendiente no incluye código QR', () {
      final dto = PedidoResponseDto.fromJson(
        _pedidoJson(estado: 'PED_PENDIENTE'),
      );
      expect(dto.pedido.codigoQr, isNull);
      expect(dto.pedido.estado, PedidoEstado.PED_PENDIENTE);
    });
  });

  group('HU-6.9 Escanear QR del pedido', () {
    test('Busca el QR y obtiene cliente, productos y estado', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      final pedido = await vm.buscarQr('qr-21');
      expect(repo.ultimoQr, 'qr-21');
      expect(pedido?.clienteNombre, 'Ana Cliente');
      expect(pedido?.carrito.single.cantidad, 2);
    });

    test('Un QR inválido muestra error y no devuelve pedido', () async {
      final repo = FakePedidoRepository()
        ..errorConsulta = StateError(
          'El código no corresponde a un pedido válido',
        );
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.buscarQr('no-es-qr'), isNull);
      expect(vm.errorMessage, contains('no corresponde'));
    });
  });

  group('HU-6.10 Confirmar entrega mediante QR', () {
    test('Envía el QR y método de pago para completar la entrega', () async {
      final repo = FakePedidoRepository();
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      final pedido = await vm.entregarPorQr('qr-21', 'M_EFECTIVO');
      expect(repo.ultimoQr, 'qr-21');
      expect(repo.ultimoMetodoPago, 'M_EFECTIVO');
      expect(pedido?.estado, PedidoEstado.PED_ENTREGADO);
    });

    test('Un pedido cancelado o entregado no se vuelve a entregar', () async {
      final repo = FakePedidoRepository()
        ..errorMutacion = StateError('no puede entregarse nuevamente');
      final vm = PedidoViewModel(pedidoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.entregarPorQr('qr-21', 'M_TARJETA'), isNull);
      expect(vm.errorMessage, contains('nuevamente'));
    });
  });
}

Map<String, dynamic> _pedidoJson({required String estado, String? codigoQr}) =>
    {
      'id': 21,
      'estado': estado,
      'costo': 25.0,
      'fecha': '2026-01-01T10:00:00',
      'numPedido': 21,
      'textPedido': '00021',
      'clienteId': 5,
      'clienteNombre': 'Ana Cliente',
      'codigoQr': codigoQr,
      'entregable': estado == 'PED_LISTO',
      'carrito': {
        'cantidad': 2,
        'items': [
          {
            'cantidad': 2,
            'producto': {'id': 8, 'nombre': 'Agua', 'precioVenta': 12.5},
          },
        ],
      },
    };
