import 'dart:async';

import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/carrito/presentation/viewmodel/carrito_view_model.dart';
import 'package:ecommerce_app/features/carrito/presentation/detalles_producto.dart';
import 'package:ecommerce_app/features/carrito/presentation/widgets/categorias_tabs_public.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/categorias_tabs.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card_public.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu>{
  final _searchController = TextEditingController();
  int _categoria = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CarritoViewModel>().cargar();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final params = _categoria == 0 ? ProductoParamsPublic().copyWith(query: value.trim()) : ProductoParams().copyWith(query: value.trim(), categoria: _categoria);
      context.read<CarritoViewModel>().setParams(params as ProductoParamsPublic);
    });
  }

  void _onCategoria(int id) {
    if (id == _categoria) return;
    setState(() => _categoria = id);

    context.read<CarritoViewModel>().setParams(
      ProductoParamsPublic().copyWith(
        query: _searchController.text.trim(),
        categoria: id == 0 ? null : id,
      ),
    );
  }
  Categoria placeholder = Categoria(id: 0, nombre: "nombre", descripcion: "descripcion", tieneProductos: false);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarritoViewModel>();
    final categorias = context.read<CategoriaRepository>();

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
          CategoriaTabs(
            categorias: [placeholder, placeholder, placeholder, placeholder, placeholder, placeholder],
            seleccionada: 0,
            onSelect: _onCategoria,
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
              itemBuilder: (_, _) => ProductoCardPublic.placeholder(),
            ),
          ),
        ],
      ),
    );

    Widget list = RefreshIndicator(
      onRefresh: () => context.read<CarritoViewModel>().cargar(),
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
          SliverToBoxAdapter(
            child: FutureBuilder(future: categorias.listaPublica(), builder: (context, snapshot) {
              if(snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primario.c400)),
                );
              }
              return CategoriasTabsPublic(
                categorias: snapshot.data ?? [],
                seleccionada: _categoria,
                onSelect: _onCategoria,
              );
            }),
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
              return ProductoCardPublic(
                producto: prod,
                loading: vm.checkingStockId == prod.id,
                onPressButton: () async {
                  if(!context.mounted) return;
                  if(vm.isLoading) return;
                  await vm.agregarUnoAlCarrito(prod);
                  if(vm.errorMessage != null) {
                    AppToast.show(context, variant: ToastType.info,
                        title: "¡No se pudo agregar al carrito!",
                        message: vm.errorMessage);
                  } else {
                    AppToast.show(context, variant: ToastType.success, title: "¡Agregado!", message: "Se agregó ${prod.nombre} al carrito");
                  }
                },
                onCardTouch: () => Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetallesProducto(productoId: prod.id)
                  ),
                ),
                showButton: prod.stock <= 0,
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // espacio para el FAB
        ],
      ),
    );

    Widget emptyList = RefreshIndicator(
      onRefresh: () => context.read<CarritoViewModel>().cargar(),
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: StatusView.empty(title: "No hay productos disponibles"),
            ),
          ],
        ),
      ),
    );

    if(vm.errorObjList != null) return StatusView.byApiException(exception: vm.errorObj!, onRetry: vm.cargar);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Skeletonizer(
        enabled: vm.isFetching,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:  vm.isFetching ? loadingPlaceholder : (vm.productos.isEmpty && _searchController.text == "" && vm.productoParams.isEmpty) ? emptyList : list,
        ),
      ),
    );
  }
}