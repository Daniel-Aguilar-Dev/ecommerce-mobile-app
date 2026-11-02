import 'dart:async';

import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_modals.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/editar_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/nuevo_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar(),
      child: const _ProductosView(),
    );
  }
}

class _ProductosView extends StatefulWidget {
  const _ProductosView();
  @override
  State<_ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<_ProductosView> {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();

    Widget loadingPlaceholder = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomField(
            controller: _searchController,
            hint: 'Buscar un producto',
            icon: LucideIcons.search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 340,
              ),
              itemBuilder: (_, _) => ProductoCard.placeholder(),
            ),
          ),
        ],
      ),
    );

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
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
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
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.62,
              mainAxisExtent: 340, // alto fijo de cada card
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

    Widget emptyList = RefreshIndicator(
      onRefresh: () => context.read<ProductoViewModel>().cargar(),
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: StatusView.empty(title: "No hay productos registrados"),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Skeletonizer(
        enabled: vm.isFetching,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:  vm.isFetching ? loadingPlaceholder : (vm.productos.isEmpty && _searchController.text == "") ? emptyList : list,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
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