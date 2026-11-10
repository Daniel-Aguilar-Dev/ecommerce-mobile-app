import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/constants.dart';
import 'package:ecommerce_app/core/validation/letras_numeros_validator.dart';
import 'package:ecommerce_app/core/validation/numero_positivo_validator.dart';
import 'package:ecommerce_app/core/validation/precio_validator.dart';
import 'package:ecommerce_app/core/validation/codigo_barras_validator.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/bottom_sheet_container.dart';
import 'package:ecommerce_app/core/ui/campos_obligatorios_text.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/core/ui/pressable_item.dart';
import 'package:ecommerce_app/core/ui/seccion_titulo.dart';
import 'package:ecommerce_app/core/ui/custom_dropdown.dart';
import 'package:ecommerce_app/core/ui/visor_imagen.dart';
import 'package:ecommerce_app/core/ui/custom_autocomplete.dart';
import 'package:ecommerce_app/core/layout/multistep_form.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/utils/scanner_codigo_barras.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dashed_border/dashed_border.dart';

import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/data/unidades_medida.dart';

class EditarProductoView extends StatelessWidget {
  const EditarProductoView({super.key, required this.productoId});

  final int productoId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar()
      ..cargarMarcas(),
      child: _EditarProductoPage(id: productoId),
    );
  }
}

class _EditarProductoPage extends StatefulWidget {
  const _EditarProductoPage({ required this.id });

  final int id;

  @override
  State<_EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<_EditarProductoPage>{
  late final id = widget.id;

  late final _categorias = context.read<CategoriaRepository>();
  Producto? _editable;

  late final Future<void> _cargaInicial;
  late final Future<List<Categoria>> _categoriasFuture = _categorias.listaPersonal();

  final _formKey = GlobalKey<FormState>();
  final _skuFieldKey = GlobalKey<FormFieldState<String>>();

  //Controllers step 1
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();

  //Controllers step 2
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _unidadController = TextEditingController();
  final _skuController = TextEditingController();

  final List<TextInputFormatter> _doubleFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}\.?\d{0,2}$')),
  ];

  final List<TextInputFormatter> _intFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}$')),
  ];

  final List<TextInputFormatter> _skuFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(13),
  ];

  //Valores que no se pueden obtener de un input
  int? _categoriaId;
  Categoria? _selectedCategoria;
  File? _foto;

  @override
  void initState() {
    super.initState();
    _cargaInicial = _cargarProducto();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _marcaController.dispose();
    _categoriaId = null;
    _selectedCategoria = null;
    _foto = null;
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockMinimoController.dispose();
    _unidadController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async{
    try{
      _editable = await context.read<ProductoRepository>().unoPorId(id);
      _nombreController.text = _editable?.nombre ?? "";
      _descripcionController.text = _editable?.descripcion ?? "";
      _marcaController.text = _editable?.marca ?? "";
      _categoriaId = _editable?.categoria.id;
      _selectedCategoria = _editable?.categoria;
      _precioCompraController.text = _editable!.precioCompra.toString();
      _precioVentaController.text = _editable!.precioVenta.toString();
      _stockMinimoController.text = _editable!.stockMinimo.toString();
      _unidadController.text = _editable?.unidadMedia ?? "";
      _skuController.text = _editable?.sku ?? "";

    } catch (error){
      AppToast.show(context, variant: ToastType.error, title: "¡Error al recuperar el producto!", message: "$error");
      Navigator.pop(context);
    }
  }

  void _mostrarImagenCompleta(String tag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) =>
            VisorImagen(foto: _foto, url: _editable?.imagenUrl, tag: tag),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget pictureOptions(BuildContext sheetContext) {
    return BottomSheetContainer(
        children: [
          Text(_foto != null ? "Cambiar foto" : "Elegir foto", style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          PressableItem(
              icon: LucideIcons.camera,
              text: "Desde la camara",
              onPress: () { Navigator.pop(sheetContext, ImageSource.camera); },
          ),
          PressableItem(
              icon: LucideIcons.images,
              text: "Desde la galeria",
              onPress: () { Navigator.pop(sheetContext, ImageSource.gallery); },
          )
        ]
    );
  }

  Widget validadorImagen(){
    return FormField<File>(
      initialValue: _foto,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            "Imagen del producto",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Text("toca para cambiar la imagen"),
          Row(
            crossAxisAlignment: .center,
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            spacing: 8,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: GestureDetector(
                  onTap: () => _mostrarImagenCompleta('foto-producto'),
                  child: Hero(
                    tag: 'foto-producto',
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: _foto != null ? Image.file(
                        _foto!,
                        fit: BoxFit.fill,
                      ) : CachedNetworkImage(
                        imageUrl: _editable?.imagenUrl ?? "",
                        fit: BoxFit.fill,
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/images/prod_placeholder.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: GestureDetector(
                  onTap: () async {
                    final nueva = await _pickImage();
                    if (nueva != null) state.didChange(nueva);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.superficie.c50, borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: DashedBorder(
                        color: AppColors.terciario.c300,
                        width: 2.0,
                        dashLength: 8.0,
                        dashGap: 4.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(LucideIcons.images, size: 36, color: AppColors.terciario.c300,),
                    ),
                  ),
                )
              ),
            ],
          ),
          if (state.hasError)
            Text(
              state.errorText!,
              style: TextStyle(color: AppColors.error.main, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Future<File?> _pickImage() async {
    bool existiaImagen = _foto != null;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => pictureOptions(sheetContext),
    );
    if (source == null) return null;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked == null) return null;

      final original = File(picked.path);
      var result = original;

      if (await original.length() > kMaxImageBytes) {
        var quality = 70;
        while (quality >= 30) {
          final out = await FlutterImageCompress.compressAndGetFile(
            original.absolute.path,
            '${original.parent.path}/c_${DateTime.now().millisecondsSinceEpoch}.jpg',
            quality: quality,
            minWidth: 1280,
            minHeight: 1280,
          );
          if (out == null) break;

          result = File(out.path);
          if (await result.length() <= kMaxImageBytes) break;
          quality -= 15;
        }

        if (await result.length() > kMaxImageBytes) {
          throw const ImageTooLargeException('La imagen no debe superar los 2 MB');
        }
      }

      if (!mounted) return null;
      setState(() => _foto = result);
      AppToast.show(context, variant: ToastType.success, title: "¡Éxito!", message: existiaImagen ? 'Imagen cambiada correctamente' : 'Imagen obtenida correctamente');

      return result;
    } on ImageTooLargeException catch (e) {
      if (!mounted) return null;
      AppToast.show(context, variant: ToastType.error, title: "¡Imágen muy pesada!", message: e.message);
    } catch (_) {
      if (!mounted) return null;
      AppToast.show(context, variant: ToastType.error, title: "¡Error!", message: 'No se pudo obtener la imagen');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();

    late final form = MultiStepForm(
      // Required callback
      onSubmit: () async {
        if (_formKey.currentState!.validate()) {
          final request = ProductoRequestDto(
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
              marca: _marcaController.text,
              stockActual: _editable?.stockActual ?? 0,
              stockMinimo: int.parse(_stockMinimoController.text),
              stockReservado: 0,
              precioVenta: double.parse(_precioVentaController.text),
              precioCompra: double.parse(_precioCompraController.text),
              unidadMedia: _unidadController.text,
              sku: _skuController.text.isEmpty ? null : _skuController.text,
              categoria: {"id": _selectedCategoria?.id, "nombre": _selectedCategoria?.nombre, "descripcion": _selectedCategoria?.descripcion, "tieneProductos": _selectedCategoria?.tieneProductos}
          );

          await vm.actualizar(request, _foto, id);

          if(vm.successMessage != null) {
            Navigator.pop(context,true);
            AppToast.show(context, variant: ToastType.success, title: "¡Éxito!", message: vm.successMessage);
          }
          if(vm.errorMessage != null) { AppToast.show(context, variant: ToastType.error, title: "¡Error!", message: vm.errorMessage);}
        }
      },

      isSubmitting: vm.isLoading,

      // Define form steps
      steps: [
        // Step 1
        FormStep(
          title: 'Información\ngeneral',
          fields: [
            SeccionTitulo(title: "Datos básicos del producto"),
            validadorImagen(),
            CustomField(
              controller: _nombreController,
              hint: 'Ej. Arroz 1kg',
              label: "Nombre del producto",
              isRequired: false,
              maxLength: 150,
              validator: (value) => letrasNumerosValidator(value, 'El nombre del producto es obligatorio'),
              keyboardType: .name,
              textInputAction: .next,
            ),
            vm.marcas.isEmpty ?
            CustomField(
              controller: _marcaController,
              hint: 'Ej. Marinela',
              label: "Marca",
              isRequired: false,
              maxLength: 25,
              validator: (value) => letrasNumerosValidator(value, 'La marca del producto es obligatoria'),
              keyboardType: .name,
              textInputAction: .next,
            ):
            CustomAutocomplete(
              controller: _marcaController,
              hint: 'Ej. Marinela',
              label: "Marca",
              isRequired: false,
              maxLength: 25,
              validator: (value) => letrasNumerosValidator(value, 'La marca del producto es obligatoria'),
              options: vm.marcas,
            ),
            FutureBuilder<List<Categoria>>(
              future: _categoriasFuture,
              builder: (context, snapshot) {
                final categorias = snapshot.data ?? const [];
                if(snapshot.connectionState == ConnectionState.waiting) return Text("Cargando categorías...");
                if(snapshot.hasError) return Text('Error: ${snapshot.error}', style: TextStyle(color: AppColors.error.main, fontStyle: FontStyle.italic));
                if (categorias.isEmpty) {
                  return Center(child: Text('Debes registrar al menos una categoría para continuar', style: TextStyle(color: AppColors.error.main, fontStyle: FontStyle.italic)));
                }
                return CustomDropdown<int>(
                  label: 'Categoría',
                  hint: 'Selecciona una categoría',
                  isRequired: false,
                  icon: LucideIcons.tag,
                  value: _categoriaId,
                  items: [
                    for (final c in categorias)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (id) => setState(() {
                    _categoriaId = id;
                    for(final c in categorias){
                      if(c.id == id){
                        _selectedCategoria = c;
                        break;
                      }
                    }
                  }),
                  requiredMessage: "Elige una categoría para continuar",
                );
              },
            ),
            CustomField(
                controller: _descripcionController,
                hint: "Agrega una descripción breve",
                label: "Descripción",
                isRequired: false,
                minLines: 2,
                maxLines: 6,
                maxLength: 150,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if(value == null || value.trim().isEmpty) return 'El descripción del producto es obligatoria';
                  return null;
                }
            ),
            CamposObligatoriosText()
          ],
        ),

        // Step 2
        FormStep(
          title: 'Precios\ne inventario',
          fields: [
            SeccionTitulo(title: "Datos de inventario"),
            CustomField(
              controller: _precioCompraController,
              hint: '0.00',
              label: "Precio de compra",
              isRequired: false,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _doubleFormatter,
              validator: (value) => precioValidator(value, 'El precio de compra es obligatorio'),
              textInputAction: .next,
            ),
            CustomField(
              controller: _precioVentaController,
              hint: '0.00',
              label: "Precio de venta",
              isRequired: false,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _doubleFormatter,
              validator: (value) => precioValidator(value, 'El precio de venta es obligatorio'),
              textInputAction: .next,
            ),
            CustomField(
              controller: _stockMinimoController,
              hint: 'Cantidad a considerar para pocas unidades',
              label: "Stock mínimo",
              isRequired: false,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _intFormatter,
              validator: (value) => numeroPositivoValidator(value, 'El stock mínimo es obligatorio', 999999, false),
              textInputAction: .next,
            ),
            CustomAutocomplete(
              controller: _unidadController,
              label: 'Unidad de medida',
              hint: 'Ej. pieza, litro, kg',
              isRequired: false,
              options: unidades,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La unidad de medida es obligatoria'
                  : null,
              maxLength: 25,
              keyboardType: .name,
              textInputAction: .next,
            ),
            Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomField(
                    key: _skuFieldKey,
                    controller: _skuController,
                    hint: 'Código de barras',
                    label: 'Código de barras del producto',
                    isRequired: false,
                    maxLength: 13,
                    inputFormatters: _skuFormatter,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: codigoBarrasValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28), // baja el botón a la altura del input
                  child: IconButton(
                    onPressed: () async{
                      String? codigo = await escanearCodigo(context);
                      if(codigo != null){
                        _skuController.text = codigo;
                        _formKey.currentState?.validate();
                      } else {
                        AppToast.show(context, variant: ToastType.info, title: "No se pudo escanear el código", message: "Intentalo nuevamente o ingresalo manualmente");
                      }
                    },
                    icon: const Icon(LucideIcons.scanBarcode, size: 20),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primario.c400,
                      fixedSize: const Size(46, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),

        FormStep(
          title: 'Resumen',
          fields: [
            SeccionTitulo(title: "Datos para el consumidor"),
              Center(
                child: SizedBox(
                  width: 175,
                  height: 175,
                  child: GestureDetector(
                    onTap: () => _mostrarImagenCompleta('foto-producto-detalle'),
                    child: Hero(
                      tag: 'foto-producto-detalle',
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: _foto != null ? Image.file(
                          _foto!,
                          fit: BoxFit.fill,
                        ) : CachedNetworkImage(
                          imageUrl: _editable?.imagenUrl ?? "",
                          fit: BoxFit.fill,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            'assets/images/prod_placeholder.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Text.rich(
              TextSpan(
                text: "Nombre del producto: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _nombreController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Precio de venta: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "\$ ${double.tryParse(_precioVentaController.text)?.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Marca: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _marcaController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Categoria: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _selectedCategoria?.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Descripción: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _descripcionController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SeccionTitulo(title: "Datos de inventario"),
            Text.rich(
              TextSpan(
                text: "Stock inicial: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _editable?.stockActual.toString() ?? "",
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Stock mínimo: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _stockMinimoController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Precio de compra: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "\$ ${double.tryParse(_precioCompraController.text)?.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Distribuido en: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _unidadController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            if(_skuController.text.isNotEmpty) Text.rich(
              TextSpan(
                text: "Código de barras: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: _skuController.text,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],

      // Customizable button styles
      nextButtonColor: AppColors.primario.c400,
      prevButtonColor: Colors.white,
      submitButtonColor: AppColors.primario.c400,
      nextButtonTextColor: Colors.white,
      prevButtonTextColor: AppColors.primario.c400,
      submitButtonTextColor: Colors.white,
      stepIndicatorActiveColor: AppColors.primario.c400,
      stepIndicatorDefaultColor: const Color(0xFFDADADA),
    );

    return Scaffold(
      appBar: AppBarExterno(title: "Modificar producto"),
      body: SafeArea(child:
      Padding(
        padding: .all(16),
        child: FutureBuilder<void>(
          future: _cargaInicial,
          builder: (context, snapshot) {
            if(snapshot.connectionState != ConnectionState.done) {
              return Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primario.c400,
                      semanticsLabel: "Cargando producto...",
                    )
                  )
                ],
              );
            }
            return Form(
              key: _formKey,
              child: form,
            );
          },
        ),
      )
      ),
    );
  }
}