import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/modal_cancel_button.dart';
import 'package:ecommerce_app/core/ui/modal_confirm_button.dart';
import 'package:ecommerce_app/core/validation/nombre_validator.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _createNombreController = TextEditingController();
  final _createDescController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _createNombreController.dispose();
    _createDescController.dispose();
    super.dispose();
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
        builder: (ctx, _) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Expanded(
              child: Text('Registrar categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x), iconSize: 18, padding: .all(2), color: const Color(0xFF767778))
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            mainAxisAlignment: .center,
            spacing: 8,
            children: [
              CustomField(
                controller: _createNombreController,
                hint: "Nombre",
                label: "Nombre",
                maxLength: 25,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: nombreValidator,
              ),
              CustomField(
                controller: _createDescController,
                hint: "Descripción",
                label: "Descripción",
                minLines: 2,
                maxLines: 4,
                maxLength: 50,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ModalCancelButton(onPressed: () {
            _createNombreController.text = "";
            _createDescController.text = "";
            if(vm.isLoading) return;
            Navigator.pop(context);
          }),
          ModalConfirmButton(onPressed: () async {
            final nombre = _createNombreController.text.trim().replaceAll("  ", " ");
            final descripcion = _createDescController.text.trim().replaceAll("  ", " ");

            if(!_formKey.currentState!.validate()) return;
            await vm.registrar(CategoriaRequestDto(nombre: nombre, descripcion: descripcion));

            _createNombreController.text = "";
            _createDescController.text = "";
            Navigator.pop(context);

            if(vm.successMessage != null) { AppToast.show(context, variant: ToastType.success, title: "¡Éxito!", message: vm.successMessage);}
            if(vm.errorMessage != null) { AppToast.show(context, variant: ToastType.error, title: "¡Error!", message: vm.errorMessage);}
          }, isLoading: vm.isLoading, label: "Guardar",)
        ],
      ),
      )
    );
  }

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

    Widget cardPlaceholder = CategoriaCard(categoria: Categoria(id: 0, nombre: "placeholder", descripcion: "placeholder de producto", tieneProductos: false), onEdit: (Categoria p1) {  }, onDelete: (Categoria p1) {  },);

    Widget categoriasList = Column(
      spacing: 16,
      children: [
        CustomField(
          controller: _searchController,
          hint: 'Buscar una categoría',
          icon: LucideIcons.search,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: vm.categorias.length,
            itemBuilder: (_, i) =>
              CategoriaCard(
                categoria: vm.categorias[i],
                onDelete: (categoria) => _deleteCategoriaModal(vm.categorias[i]),
                onEdit: (categoria) => debugPrint("[CATEGORIA] Editando ${categoria.nombre}"),
              ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Skeletonizer(
        enabled: vm.isFetching,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: vm.isFetching ? ListView(
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
          ) : vm.categorias.isEmpty ? empty : RefreshIndicator(
            onRefresh: () => context.read<CategoriaViewModel>().cargar(),
            child: categoriasList,
          ),
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

class EditCategoriaDialog {

}

class DeleteCategoriaDialog extends StatelessWidget {
  const DeleteCategoriaDialog({
    super.key,
    required this.categoria,
    required this.viewModel,
  });

  final Categoria categoria;
  final CategoriaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('¿Eliminar categoría?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminará la categoría ${categoria.nombre}. Esta acción es irreversible.',
        ),
        actions: [
          ModalCancelButton(
            onPressed: () {
              if(viewModel.isLoading) return;
              Navigator.pop(context);
            },
          ),
          ModalConfirmButton(
            label: 'Eliminar',
            isLoading: viewModel.isLoading,
            onPressed: () async {
              await viewModel.borrar(categoria.id);
              if(context.mounted) {
                Navigator.pop(context);

                if (viewModel.successMessage != null) {
                  AppToast.show(context, variant: ToastType.success,
                      title: "¡Éxito!",
                      message: viewModel.successMessage);
                }
                if (viewModel.errorMessage != null) {
                  AppToast.show(context, variant: ToastType.error,
                      title: "¡Error!",
                      message: viewModel.errorMessage);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/**
 *   void _onEdit(){
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    backgroundColor: Colors.white,
    title: Row(
    mainAxisAlignment: .center,
    crossAxisAlignment: .center,
    children: [
    Expanded(
    child: Text('Modificar categoría', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x), iconSize: 18, padding: .all(2), color: const Color(0xFF767778))
    ],
    ),
    content: Form(
    key: _formKey,
    child: Column(
    mainAxisSize: .min,
    crossAxisAlignment: .start,
    mainAxisAlignment: .center,
    spacing: 8,
    children: [
    CustomField(controller: _editNombreController, hint: "Nombre", label: "Nombre", maxLength: 25),
    CustomField(controller: _editDescController, hint: "Descripción", label: "Descripción", minLines: 2, maxLines: 4, maxLength: 50),
    ],
    ),
    ),
    actions: [
    ModalCancelButton(onPressed: () {
    Navigator.pop(context);
    }),
    ModalConfirmButton(onPressed: () {
    Navigator.pop(context);
    }, isLoading: false)
    ],
    ),
    );
    }
    void _onDelete(){
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    backgroundColor: Colors.white,
    title: Text('¿Eliminar categoría?', style: TextStyle(fontWeight: FontWeight.bold)),
    content: Text('Se eliminará la categoría ${widget.categoria.nombre} ya que no cuenta con productos asociados. Esta acción es irreversible', textAlign: TextAlign.start,),
    actions: [
    ModalCancelButton(onPressed: () => Navigator.pop(context)),
    ModalConfirmButton(onPressed: () {
    Navigator.pop(context);
    }, isLoading: false)
    ],
    ),
    );
    }



 */