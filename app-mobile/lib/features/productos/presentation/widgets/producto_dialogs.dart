import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/modal_cancel_button.dart';
import 'package:ecommerce_app/core/ui/modal_confirm_button.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeleteProductoDialog extends StatelessWidget {
  const DeleteProductoDialog({
    super.key,
    required this.producto,
    required this.viewModel,
  });

  final Producto producto;
  final ProductoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('¿Eliminar producto?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Este producto se eliminará de forma permanente en caso de no contar movimientos asociados a él',
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
              final res = await viewModel.borrar(producto.id);
              if(context.mounted) {
                Navigator.pop(context, res);

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

class StatusProductoDialog extends StatelessWidget {
  const StatusProductoDialog({
    super.key,
    required this.producto,
    required this.viewModel,
  });

  final Producto producto;
  final ProductoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('¿${producto.estado.name == ProductoEstado.PROD_ACTIVO.name ? "Descontinuar" : "Reanudar"} producto?',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Este producto ${producto.estado.name == ProductoEstado.PROD_ACTIVO.name ? "dejará de" : "volverá a"} estar disponible en el catálogo de los clientes para su consumo',
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
              final res = await viewModel.cambiarEstado(producto.id);
              if(context.mounted) {
                Navigator.pop(context, res);

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

class ProductoFiltersDialog extends StatefulWidget {
  const ProductoFiltersDialog({
    super.key,
    required this.categoria,
    required this.visibility,
    required this.stock,
    required this.order,
    required this.reset,
    required this.setVisibility,
    required this.setStock,
    required this.setOrder,
  });

  final int categoria;
  final int visibility;
  final int stock;
  final int order;
  final VoidCallback reset;
  final Function(int) setVisibility;
  final Function(int) setStock;
  final Function(int) setOrder;

  @override
  State<StatefulWidget> createState() => _ProductoFiltersDialogState();
}

class _ProductoFiltersDialogState extends State<ProductoFiltersDialog>{
  bool? _stockBajo;
  bool? _stockCero;
  bool? _soloVigentes;
  bool? _soloDescontinuados;
  Orden? _orden;

  late int _visibility = widget.visibility;
  late int _stock = widget.stock;
  late int _order = widget.order;

  @override
  Widget build(BuildContext context) {;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        spacing: 4,
        children: [
          const Icon(LucideIcons.funnel),
          Expanded(
            child: Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: () {
            widget.reset();
            Navigator.pop(context, null);
          }, icon: const Icon(LucideIcons.x), iconSize: 18, padding: .all(2), color: const Color(0xFF767778))
        ],
      ),
      content: Column(
        mainAxisSize: .min,
        children: [
          RadioGroup<int>(
          groupValue: _order,
          onChanged: (int? value) {
            setState(() {
              _order = value!;
              if(value == 1){
                _orden = Orden.nombre_desc;
              } else if (value == 2) {
                _orden = Orden.nombre_asc;
              } else {
                _orden = null;
              }
            });
          },
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: <Widget>[
                Text('Ordenar por'),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Sin orden'),
                  leading: Radio<int>(value: 0),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Nombre A-Z'),
                  leading: Radio<int>(value: 1),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Nombre Z-A'),
                  leading: Radio<int>(value: 2),
                ),
              ],
            ),
          ),
          RadioGroup<int>(
            groupValue: _visibility,
            onChanged: (int? value) {
              setState(() {
                _visibility = value!;
                if(value == 1){
                  _soloVigentes = true;
                  _soloDescontinuados = false;
                } else if (value == 2) {
                  _soloVigentes = false;
                  _soloDescontinuados = true;
                } else {
                  _soloVigentes = null;
                  _soloDescontinuados = null;
                }
              });
            },
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: <Widget>[
                Text('Estado de productos'),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Todos'),
                  leading: Radio<int>(value: 0),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Solo vigentes'),
                  leading: Radio<int>(value: 1),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Solo descontinados'),
                  leading: Radio<int>(value: 2),
                ),
              ],
            ),
          ),
          RadioGroup<int>(
            groupValue: _stock,
            onChanged: (int? value) {
              setState(() {
                _stock = value!;
                if(value == 1){
                  _stockBajo = true;
                  _stockCero = false;
                } else if (value == 2) {
                  _stockBajo = false;
                  _stockCero = true;
                } else {
                  _stockBajo = null;
                  _stockCero = null;
                }
              });
            },
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: <Widget>[
                Text('Disponibilidad'),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Todos'),
                  leading: Radio<int>(value: 0),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Pocas unidades'),
                  leading: Radio<int>(value: 1),
                ),
                const ListTile(
                  contentPadding: .all(0),
                  title: Text('Agotados'),
                  leading: Radio<int>(value: 2),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                  ),
                  onPressed: () {
                    widget.reset();
                    Navigator.pop(context, null);
                  },
                  child: const Text("Limpiar filtros")),
              )
            ],
          )
        ],
      ),
      actions: [
        ModalCancelButton(onPressed: () {
          widget.reset();
          Navigator.pop(context, null);
        }),
        ModalConfirmButton(onPressed: () async {
          Navigator.pop(context, ProductoParams().copyWith(
            stockBajo: _stockBajo,
            stockCero: _stockCero,
            soloDescontinuados: _soloDescontinuados,
            soloVigentes: _soloVigentes,
            orden: _orden,
            categoria: widget.categoria == 0 ? null : widget.categoria
          ));
        }, isLoading: false, label: "Aplicar",)
      ],
    );
  }
}