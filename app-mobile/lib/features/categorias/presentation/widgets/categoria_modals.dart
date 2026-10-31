import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/modal_cancel_button.dart';
import 'package:ecommerce_app/core/ui/modal_confirm_button.dart';
import 'package:ecommerce_app/core/validation/nombre_validator.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/presentation/viewmodel/categoria_view_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddCategoriaDialog extends StatefulWidget {
  const AddCategoriaDialog({super.key, required this.vm});

  final CategoriaViewModel vm;

  @override
  State<StatefulWidget> createState() => _AddCategoriaDialogState();
}

class _AddCategoriaDialogState extends State<AddCategoriaDialog>{
  final _formKey = GlobalKey<FormState>();
  final _createNombreController = TextEditingController();
  final _createDescController = TextEditingController();

  @override
  void dispose() {
    _createNombreController.dispose();
    _createDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return AlertDialog(
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
          if(vm.isLoading) return;
          _createNombreController.text = "";
          _createDescController.text = "";
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
    );
  }
}

class EditCategoriaDialog extends StatefulWidget {
  const EditCategoriaDialog({super.key, required this.categoria, required this.vm});

  final Categoria categoria;
  final CategoriaViewModel vm;

  @override
  State<StatefulWidget> createState() => _EditCategoriaDialogState();
}

class _EditCategoriaDialogState extends State<EditCategoriaDialog>{
  final _formKey = GlobalKey<FormState>();
  final _editNombreController = TextEditingController();
  final _editDescController = TextEditingController();

  @override
  void initState() {
    _editNombreController.text = widget.categoria.nombre;
    _editDescController.text = widget.categoria.descripcion;
    super.initState();
  }

  @override
  void dispose() {
    _editNombreController.dispose();
    _editDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return AlertDialog(
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
              controller: _editNombreController,
              hint: "Nombre",
              label: "Nombre",
              maxLength: 25,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: nombreValidator,
            ),
            CustomField(
              controller: _editDescController,
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
          if(vm.isLoading) return;
          Navigator.pop(context);
        }),
        ModalConfirmButton(onPressed: () async {
          final nombre = _editNombreController.text.trim().replaceAll("  ", " ");
          final descripcion = _editDescController.text.trim().replaceAll("  ", " ");

          if(!_formKey.currentState!.validate()) return;
          await vm.actualizar(CategoriaRequestDto(nombre: nombre, descripcion: descripcion), widget.categoria.id);

          _editNombreController.text = "";
          _editDescController.text = "";
          Navigator.pop(context);

          if(vm.successMessage != null) { AppToast.show(context, variant: ToastType.success, title: "¡Éxito!", message: vm.successMessage);}
          if(vm.errorMessage != null) { AppToast.show(context, variant: ToastType.error, title: "¡Error!", message: vm.errorMessage);}
        }, isLoading: vm.isLoading, label: "Guardar",)
      ],
    );
  }
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