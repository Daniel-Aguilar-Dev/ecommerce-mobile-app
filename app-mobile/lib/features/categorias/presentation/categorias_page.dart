import 'dart:async';

import 'package:ecommerce_app/core/layout/status_view.dart';
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

class CategoriasPage extends StatelessWidget {
  const CategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CategoriaViewModel(
        categoriaRepository: ctx.read<CategoriaRepository>(),
      )..cargar(),
      child: const _CategoriasView(),
    );
  }
}

class _CategoriasView extends StatefulWidget {
  const _CategoriasView();
  @override
  State<_CategoriasView> createState() => _CategoriasViewState();
}

class _CategoriasViewState extends State<_CategoriasView> {
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
      context.read<CategoriaViewModel>().cargar(
        value.trim(),
        true
      );
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

  late Widget listPlaceholder = ListView(
    children: [
      CustomField(
        controller: _searchController,
        hint: 'Buscar una categoría',
        icon: LucideIcons.search,
      ),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
      CategoriaCard.placeholder(),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriaViewModel>();

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
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          vm.categorias.isEmpty ?
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: StatusView.noResults()),
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

    Widget emptyList = RefreshIndicator(
      onRefresh: () => context.read<CategoriaViewModel>().cargar(),
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: StatusView.empty(title: "No hay categorías registradas")
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
          child: vm.isFetching ? listPlaceholder : (vm.categorias.isEmpty && _searchController.text == "") ? emptyList : list,
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