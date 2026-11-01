import 'dart:async';

import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_modals.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_card.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/editar_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/nuevo_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card_public.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

import '../domain/producto.dart';

class ProductosManagementPage extends StatelessWidget {
  const ProductosManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar(),
      child: const _ProductosManagementView(),
    );
  }
}

class _ProductosManagementView extends StatefulWidget {
  const _ProductosManagementView();
  @override
  State<_ProductosManagementView> createState() => _ProductosManagementViewState();
}

class _ProductosManagementViewState extends State<_ProductosManagementView> {
  late final role = context.read<AuthViewModel>().session?.usuario.rol;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<ProductoViewModel>().setParams(ProductoParams().copyWith(query: value.trim()));
    });
  }

  void _filtrosModal() {
    final vm = context.read<CategoriaViewModel>();
    vm.limpiarMensajes();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>ListenableBuilder(
          listenable: vm,
          builder: (ctx, _) => AddCategoriaDialog(vm: vm),
        )
    );
  }

  void _editProductoPage(Producto p) {
    final vm = context.read<ProductoViewModel>();
    vm.limpiarMensajes();
    vm.setProducto(p);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const EditarProductoView()
      ),
    );
  }

  void _deleteProductoModal(Categoria categoria) async {
    final vm = context.read<CategoriaViewModel>();
    vm.limpiarMensajes();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteCategoriaDialog(categoria: categoria, viewModel: vm),
    );
  }

  void _changeStatusProductoModal(Categoria categoria) async {
    final vm = context.read<CategoriaViewModel>();
    vm.limpiarMensajes();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteCategoriaDialog(categoria: categoria, viewModel: vm),
    );
  }

  late Widget listPlaceholder = ListView(
    children: [
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
      ProductoCard.placeholder(),
    ],
  );

  late Producto test = Producto(
    id: 1,
    nombre: "Coca cola chubby 500ml",
    descripcion: "Refresco saborizado delicioso",
    marca: 'Coca cola',
    stockActual: 8,
    stockMinimo: 5,
    stockReservado: 0,
    precioVenta: 15.00,
    precioCompra: 12.00,
    unidadMedia: 'Caja',
    estado: ProductoEstado.PROD_ACTIVO,
    costoPromedio: 20.00,
    categoria: Categoria(id: 1, nombre: "nombre", descripcion: "descripcion", tieneProductos: false),
    imagenPublicId: '',
    imagenVersion: 0,
    imagenUrl: 'https://images.ctfassets.net/ttw7uwgviuml/5VWXGBceP805NXdwZ7y6kH/3f701eef69baea0f458867a51ee53bf9/82038_WFMex_Packaged_COCA_COLA_CHUBBY_REGULAR_355_ml_Secos.jpg?fm=webp',
  );

  late ProductoPublic testP = ProductoPublic(
    id: 1,
    nombre: "Coca cola chubby 500ml",
    descripcion: "Refresco saborizado delicioso",
    marca: 'Coca cola',
    stock: 8,
    precio: 15.00,
    unidadMedia: 'Caja',
    estado: ProductoEstado.PROD_ACTIVO,
    categoria: Categoria(id: 1, nombre: "nombre", descripcion: "descripcion", tieneProductos: false),
    imagen: 'https://images.ctfassets.net/ttw7uwgviuml/5VWXGBceP805NXdwZ7y6kH/3f701eef69baea0f458867a51ee53bf9/82038_WFMex_Packaged_COCA_COLA_CHUBBY_REGULAR_355_ml_Secos.jpg?fm=webp',
    estadoStock: "Agotado"
  );

  late Widget card = ProductoCard(producto: test, onCardTouch: () {}, onPressButton: () {});

  late Widget card_public = ProductoCardPublic(producto: testP, onCardTouch: () {}, onPressButton: () {});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();

    Widget list = RefreshIndicator(
      onRefresh: () => context.read<ProductoViewModel>().cargar(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomField(
                onChanged: _onSearchChanged,
                controller: _searchController,
                hint: 'Buscar un producto',
                icon: LucideIcons.search,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          vm.productos.isEmpty ?
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: StatusView.noResults()),
          ) :
          SliverGrid.builder(
            itemCount: vm.productos.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220, // ancho máximo por card
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
              //mainAxisExtent: 340, // alto fijo de cada card
            ),
            itemBuilder: (_, i) {
              final prod = vm.productos[i];
              return ProductoCard(
                producto: prod,
                onCardTouch: () {},
                onPressButton: () {},
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // espacio para el FAB
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Skeletonizer(
        enabled: vm.isFetching,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: vm.isFetching ? listPlaceholder : (vm.productos.isEmpty && _searchController.text == "") ? StatusView.empty(title: "No hay productos registrados") : list,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primario.c400,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const NuevoProductoView()
          ),
        ),
        elevation: 1,
        child: Icon(LucideIcons600.plus, color: Colors.white),
      ),
    );
  }
}