import 'dart:async';

import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_modals.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class ProductosManagementPage extends StatelessWidget {
  const ProductosManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CategoriaViewModel(
        categoriaRepository: ctx.read<CategoriaRepository>(),
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
      /*context.read<CategoriaViewModel>().cargar(
          value.trim(),
          true
      );*/
    });
  }

  void _deleteCategoriaModal(Categoria categoria) async {
    final vm = context.read<CategoriaViewModel>();
    vm.limpiarMensajes();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteCategoriaDialog(categoria: categoria, viewModel: vm),
    );
  }

  void _newCategoriaModal() {
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

  void _editCategoriaModal(Categoria categoria) {
    final vm = context.read<CategoriaViewModel>();
    vm.limpiarMensajes();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>ListenableBuilder(
          listenable: vm,
          builder: (ctx, _) => EditCategoriaDialog(categoria: categoria, vm: vm),
        )
    );
  }

  Widget cardPlaceholder = CategoriaCard(categoria: Categoria(id: 0, nombre: "placeholder", descripcion: "placeholder de producto", tieneProductos: false), onEdit: (Categoria p1) {  }, onDelete: (Categoria p1) {  },);

  late Widget listPlaceholder = ListView(
    children: [
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder,
      cardPlaceholder
    ],
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriaViewModel>();

    Widget empty = Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      spacing: 16,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              color: AppColors.superficie.c50,
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: .all(24),
            child: Icon(LucideIcons.fileQuestionMark, color: AppColors.terciario.c300, size: 64),
          ),
        ),
        Center(
          child:Text("No hay categorías registradas", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold
          )),
        )
      ],
    );

    Widget emptySearch = Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      spacing: 16,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              color: AppColors.superficie.c50,
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: .all(24),
            child: Icon(LucideIcons.fileQuestionMark, color: AppColors.terciario.c300, size: 64),
          ),
        ),
        Center(
          child:Text("Sin coincidencias", style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold
          )),
        )
      ],
    );

    Widget list = RefreshIndicator(
      onRefresh: () => context.read<CategoriaViewModel>().cargar(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomField(
                onChanged: _onSearchChanged,
                controller: _searchController,
                hint: 'Buscar una categoría',
                icon: LucideIcons.search,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          vm.categorias.isEmpty ?
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: emptySearch),
          ) :
          SliverList.builder(
            itemCount: vm.categorias.length,
            itemBuilder: (_, i) {
              final cat = vm.categorias[i];
              return CategoriaCard(
                categoria: cat,
                onDelete: (categoria) => _deleteCategoriaModal(categoria),
                onEdit: (categoria) => _editCategoriaModal(categoria),
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
          child: vm.isFetching ? listPlaceholder : (vm.categorias.isEmpty && _searchController.text == "") ? empty : list,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primario.c400,
        onPressed: _newCategoriaModal,
        elevation: 1,
        child: Icon(LucideIcons600.plus, color: Colors.white),
      ),
    );
  }
}