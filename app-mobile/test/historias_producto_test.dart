import 'package:ecommerce_app/core/validation/letras_numeros_validator.dart';
import 'package:ecommerce_app/core/validation/nombre_validator.dart';
import 'package:ecommerce_app/core/validation/numero_positivo_validator.dart';
import 'package:ecommerce_app/core/validation/precio_validator.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_response_public_dto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/historia_fakes.dart';

void main() {
  group('HU-2.1 Registrar producto', () {
    test('Rechaza nombre obligatorio vacío y acepta uno válido', () {
      expect(nombreValidator('  '), isNotNull);
      expect(nombreValidator('Agua Natural'), isNull);
    });

    test('Rechaza precios y stock en cero; acepta valores positivos', () {
      expect(precioValidator('0', 'El precio es obligatorio'), isNotNull);
      expect(precioValidator('18.50', 'El precio es obligatorio'), isNull);
      expect(
        numeroPositivoValidator('0', 'El stock es obligatorio', 5000, false),
        isNotNull,
      );
      expect(
        numeroPositivoValidator('6', 'El stock es obligatorio', 5000, false),
        isNull,
      );
    });
  });

  group('HU-2.2 Consultar productos', () {
    test('Serializa filtros por nombre y categoría', () {
      final params = ProductoParams(query: 'agua mineral', categoria: 3);
      final uri = Uri.parse(
        'https://local.test/productos${params.getUrlParams()}',
      );
      expect(uri.queryParameters['query'], 'agua mineral');
      expect(uri.queryParameters['categoria'], '3');
    });

    test('Serializa los filtros de inventario bajo y sin stock', () {
      final params = ProductoParams(stockBajo: true, stockCero: true);
      final uri = Uri.parse(
        'https://local.test/productos${params.getUrlParams()}',
      );
      expect(uri.queryParameters['stockBajo'], 'true');
      expect(uri.queryParameters['stockCero'], 'true');
    });
  });

  group('HU-2.3 Consultar detalle de producto', () {
    test(
      'El DTO público conserva nombre, precio, categoría y disponibilidad',
      () {
        final dto = ProductoResponsePublicDto.fromJson({
          'id': 8,
          'nombre': 'Agua',
          'descripcion': 'Natural',
          'marca': 'Marca',
          'sku': '7501234567890',
          'stock': 4,
          'precio': 12.5,
          'unidadMedida': 'PZA',
          'estado': 'PROD_ACTIVO',
          'categoria': {'id': 3, 'nombre': 'Bebidas', 'descripcion': 'Frías'},
          'imagen': 'https://img.test/agua.png',
          'estadoStock': 'Disponible',
        });
        expect(dto.nombre, 'Agua');
        expect(dto.precio, 12.5);
        expect(dto.categoria.nombre, 'Bebidas');
        expect(dto.estadoStock, 'Disponible');
      },
    );

    test('La respuesta de un producto agotado conserva su leyenda de disponibilidad', () {
      final dto = ProductoResponsePublicDto.fromJson({
        'id': 8,
        'nombre': 'Agua',
        'descripcion': 'Natural',
        'marca': 'Marca',
        'stock': 0,
        'precio': 12.5,
        'unidadMedida': 'PZA',
        'estado': 'PROD_ACTIVO',
        'categoria': {'id': 3, 'nombre': 'Bebidas', 'descripcion': 'Frías'},
        'imagen': '',
        'estadoStock': 'Agotado',
      });
      expect(dto.stock, 0);
      expect(dto.estadoStock, 'Agotado');
    });
  });

  group('HU-2.4 Buscar producto por código de barras', () {
    test('Encuentra el producto asociado al SKU escaneado', () async {
      final repo = FakeProductoRepository();
      final vm = ProductoViewModel(productoRepository: repo);
      addTearDown(vm.dispose);
      final product = await vm.obtenerUnoPorSKU('7501234567890');
      expect(product?.id, 8);
      expect(repo.ultimoSku, '7501234567890');
    });

    test(
      'Un SKU inexistente produce resultado vacío y mensaje de error',
      () async {
        final repo = FakeProductoRepository()
          ..errorConsulta = 'Producto no encontrado';
        final vm = ProductoViewModel(productoRepository: repo);
        addTearDown(vm.dispose);
        expect(await vm.obtenerUnoPorSKU('00000000'), isNull);
        expect(vm.errorMessage, contains('Producto no encontrado'));
      },
    );
  });

  group('HU-2.5 Modificar producto', () {
    test('Envía la modificación al ID seleccionado y conserva los datos de la solicitud', () async {
      final repo = FakeProductoRepository();
      final vm = ProductoViewModel(productoRepository: repo);
      addTearDown(vm.dispose);
      final result = await vm.actualizar(
        solicitudProductoEjemplo(stock: 8),
        null,
        8,
      );
      await Future<void>.delayed(Duration.zero);
      expect(result?.id, 8);
      expect(repo.ultimoId, 8);
      expect(repo.ultimaSolicitud?.stockActual, 8);
    });

    test(
      'Un nombre duplicado muestra error y no confirma la actualización',
      () async {
        final repo = FakeProductoRepository()
          ..errorMutacion = 'Ya existe un producto con ese nombre';
        final vm = ProductoViewModel(productoRepository: repo);
        addTearDown(vm.dispose);
        expect(
          await vm.actualizar(solicitudProductoEjemplo(), null, 8),
          isNull,
        );
        expect(
          vm.errorMessage,
          contains('Ya existe un producto con ese nombre'),
        );
      },
    );
  });

  group('HU-2.6 Cambiar estado de producto', () {
    test('Alterna el estado y expone el mensaje del repositorio', () async {
      final repo = FakeProductoRepository();
      final vm = ProductoViewModel(productoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.cambiarEstado(8), isTrue);
      expect(repo.ultimoId, 8);
      expect(vm.successMessage, 'Producto descontinuado correctamente');
    });

    test('Un error de permisos no se reporta como cambio exitoso', () async {
      final repo = FakeProductoRepository()..errorMutacion = 'Acceso denegado';
      final vm = ProductoViewModel(productoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.cambiarEstado(8), isFalse);
      expect(vm.errorMessage, contains('Acceso denegado'));
    });
  });

  group('HU-2.7 Eliminar producto', () {
    test(
      'Elimina el producto sin movimientos y comunica el resultado',
      () async {
        final repo = FakeProductoRepository();
        final vm = ProductoViewModel(productoRepository: repo);
        addTearDown(vm.dispose);
        expect(await vm.borrar(8), isTrue);
        expect(repo.ultimoId, 8);
        expect(vm.successMessage, 'Producto eliminado correctamente');
      },
    );

    test('Rechaza eliminar un producto con movimientos asociados', () async {
      final repo = FakeProductoRepository()
        ..errorMutacion = 'Debe descontinuarse';
      final vm = ProductoViewModel(productoRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.borrar(8), isFalse);
      expect(vm.errorMessage, contains('Debe descontinuarse'));
    });
  });

  group('HU-2.8 Registrar categoría', () {
    test('Rechaza nombre vacío o con dígitos y acepta letras', () {
      expect(nombreValidator(''), isNotNull);
      expect(nombreValidator('Bebidas 2'), isNotNull);
      expect(nombreValidator('Bebidas'), isNull);
    });

    test('Registra y devuelve la categoría con los datos capturados', () async {
      final repo = FakeCategoriaRepository();
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      final result = await vm.registrar(
        const CategoriaRequestDto(
          nombre: 'Lácteos',
          descripcion: 'Productos refrigerados',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(result?.nombre, 'Lácteos');
      expect(repo.ultimoNombre, 'Lácteos');
      expect(vm.successMessage, 'Categoría registrada correctamente');
    });
  });

  group('HU-2.9 Consultar categorías', () {
    test('Muestra las categorías devueltas por el repositorio', () async {
      final repo = FakeCategoriaRepository();
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      await vm.cargar();
      expect(vm.categorias.map((c) => c.nombre), contains('Bebidas'));
    });

    test('Una respuesta vacía deja la lista sin categorías', () async {
      final repo = FakeCategoriaRepository()..categorias = [];
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      await vm.cargar();
      expect(vm.categorias, isEmpty);
    });
  });

  group('HU-2.10 Modificar categoría', () {
    test(
      'Actualiza la categoría seleccionada y refleja el nuevo nombre',
      () async {
        final repo = FakeCategoriaRepository();
        final vm = CategoriaViewModel(categoriaRepository: repo);
        addTearDown(vm.dispose);
        final result = await vm.actualizar(
          const CategoriaRequestDto(
            nombre: 'Abarrotes',
            descripcion: 'Despensa',
          ),
          3,
        );
        await Future<void>.delayed(Duration.zero);
        expect(result?.nombre, 'Abarrotes');
        expect(repo.ultimoId, 3);
        expect(vm.successMessage, 'Categoría actualizada correctamente');
      },
    );

    test('Un nombre duplicado no confirma la modificación', () async {
      final repo = FakeCategoriaRepository()
        ..errorMutacion = 'Ya existe una categoría con ese nombre';
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      final result = await vm.actualizar(
        const CategoriaRequestDto(nombre: 'Bebidas', descripcion: 'Duplicada'),
        4,
      );
      expect(result, isNull);
      expect(vm.errorMessage, contains('Ya existe una categoría'));
    });
  });

  group('HU-2.11 Eliminar categoría', () {
    test('Elimina la categoría sin productos y devuelve éxito', () async {
      final repo = FakeCategoriaRepository();
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.borrar(3), isTrue);
      expect(repo.ultimoId, 3);
      expect(vm.successMessage, 'Categoría eliminada correctamente');
    });

    test('No permite eliminar una categoría asociada a productos', () async {
      final repo = FakeCategoriaRepository()
        ..errorMutacion = 'La categoría tiene productos';
      final vm = CategoriaViewModel(categoriaRepository: repo);
      addTearDown(vm.dispose);
      expect(await vm.borrar(3), isFalse);
      expect(vm.errorMessage, contains('La categoría tiene productos'));
    });
  });

  group('Validación de texto de categoría', () {
    test('La descripción acepta letras, números y espacios', () {
      expect(letrasNumerosValidator('Bebidas frías 2', 'Obligatorio'), isNull);
    });
    test('La descripción requerida no acepta valor vacío', () {
      expect(
        letrasNumerosValidator(' ', 'La descripción es obligatoria'),
        'La descripción es obligatoria',
      );
    });
  });
}
