import 'dart:async';

import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';
import 'package:ecommerce_app/core/ui/bottom_sheet_container.dart';
import 'package:ecommerce_app/core/ui/pressable_item.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/detalles_producto_gestion.dart';
import 'package:ecommerce_app/features/productos/presentation/editar_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/nuevo_producto_page.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/categorias_tabs.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  int _categoria = 0;
  Timer? _debounce;

  int _visibility = 0;
  int _stock = 0;
  int _order = 0;

  void _resetFilters(){
    _visibility = 0;
    _stock = 0;
    _order = 0;
  }
  void _setVisibility(int value){
    _visibility = value;
  }
  void _setOrder(int value){
    _order = value;
  }
  void _setStock(int value){
    _stock = value;
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
      final params = _categoria == 0 ? ProductoParams().copyWith(query: value.trim()) : ProductoParams().copyWith(query: value.trim(), categoria: _categoria);
      context.read<ProductoViewModel>().setParams(params);
    });
  }

  void _onCategoria(int id) {
    if (id == _categoria) return;
    setState(() => _categoria = id);

    context.read<ProductoViewModel>().setParams(
      ProductoParams().copyWith(
        query: _searchController.text.trim(),
        categoria: id == 0 ? null : id,
      ),
    );
  }

  void _filtrosModal(ProductoViewModel vm) async{
    vm.limpiarMensajes();
    final params = await showDialog<ProductoParams?>(
      context: context,
      builder: (context) => ProductoFiltersDialog(
        vm: vm,
        categoria: _categoria,
        order: _order,
        visibility: _visibility,
        stock: _stock,
        reset: _resetFilters,
        setVisibility: _setVisibility,
        setOrder: _setOrder,
        setStock: _setStock,
      )
    );
    if(params == null){
      return;
    } else {
      vm.setParams(params);
    }
  }

  Future<void> _editProductoPage(Producto p, ProductoViewModel vm) async {
    Navigator.pop(context); // cierra el bottom sheet
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarProductoView(productoId: p.id),
      ),
    );
    if (cambio == true && mounted) {
      vm.cargar();
    }
  }

  void _deleteProductoModal(Producto prod, ProductoViewModel vm) {
    Navigator.pop(context);
    vm.limpiarMensajes();
    showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteProductoDialog(producto: prod, viewModel: vm),
    );
  }

  void _changeStatusProductoModal(Producto prod, ProductoViewModel vm) {
    Navigator.pop(context);
    vm.limpiarMensajes();
    showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatusProductoDialog(producto: prod, viewModel: vm),
    );
  }

  Categoria placeholder = Categoria(id: 0, nombre: "nombre", descripcion: "descripcion", tieneProductos: false);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    final categorias = context.read<CategoriaRepository>();

    Widget pictureOptions(Producto prod) {
      return BottomSheetContainer(
        children: [
          Text(prod.nombre, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("En stock: ${prod.stockActual}", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: prod.stockActual <= prod.stockMinimo ? AppColors.error.main : AppColors.info.main)),
          const SizedBox(height: 8),
          PressableItem(
              icon: LucideIcons.edit,
              text: "Modificar",
              onPress: () => _editProductoPage(prod, vm),
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          ),
          PressableItem(
              icon: LucideIcons.vault,
              text: prod.estado.name == ProductoEstado.PROD_ACTIVO.name
                  ? 'Descontinuar'
                  : 'Reanudar',
              onPress: () => _changeStatusProductoModal(prod, vm),
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          ),
          PressableItem(
              icon: LucideIcons.trash,
              text: "Eliminar",
              onPress: () => _deleteProductoModal(prod, vm),
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          ),
          //TODO Implementar estas funciones para reabastecer, merma y movimientos
          PressableItem(
              icon: LucideIcons.packagePlus,
              text: "Reabastecer",
              onPress: () { Navigator.pop(context); },
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          ),
          PressableItem(
              icon: LucideIcons.packageMinus,
              text: "Registrar merma",
              onPress: () { Navigator.pop(context); },
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          ),
          PressableItem(
              icon: LucideIcons.bookBookmark,
              text: "Movimientos",
              onPress: () { Navigator.pop(context); },
              contentPadding: .symmetric(horizontal: 0, vertical: 0)
          )
        ]
      );
    }

    Widget loadingPlaceholder = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            spacing: 8,
            mainAxisSize: .min,
            crossAxisAlignment: .end,
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: CustomField(
                  controller: _searchController,
                  hint: 'Buscar un producto',
                  icon: LucideIcons.search,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.listFilter, size: 24,),
                padding: .all(12),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primario.c400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            ]
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
              child: Row(
                spacing: 8,
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: CustomField(
                      onChanged: _onSearchChanged,
                      controller: _searchController,
                      hint: 'Buscar un producto',
                      icon: LucideIcons.search,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _filtrosModal(vm),
                    icon: const Icon(LucideIcons.listFilter, size: 24,),
                    padding: .all(13),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primario.c400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                ]
              )
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder(future: categorias.listaPersonal(), builder: (context, snapshot) {
              if(snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primario.c400)),
                );
              }
              return CategoriaTabs(
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
              return ProductoCard(
                producto: prod,
                onPressButton: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => pictureOptions(prod),
                ),
                onCardTouch: () => Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallesProductoGestion(productoId: prod.id)
                  ),
                )
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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primario.c400,
        onPressed: () async {
          final cambio = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NuevoProductoView()),
          );
          if (cambio == true && mounted) {
            context.read<ProductoViewModel>().cargar();
          }
        },
        elevation: 1,
        child: Icon(LucideIcons600.plus, color: Colors.white),
      ),
    );
  }
}