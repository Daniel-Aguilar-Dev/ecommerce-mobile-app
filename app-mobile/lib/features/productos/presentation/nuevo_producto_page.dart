import 'dart:io';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/constants.dart';
import 'package:ecommerce_app/core/validation/letras_numeros_validator.dart';
import 'package:ecommerce_app/core/validation/numero_positivo_validator.dart';
import 'package:ecommerce_app/core/validation/codigo_barras_validator.dart';
import 'package:ecommerce_app/core/validation/precio_validator.dart';
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
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/data/unidades_medida.dart';


const int kMaxImageBytes = 2 * 1024 * 1024;

class NuevoProductoView extends StatelessWidget {
  const NuevoProductoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar()
      ..cargarMarcas(),
      child: const _NuevoProductoPage(),
    );
  }
}

class _NuevoProductoPage extends StatefulWidget {
  const _NuevoProductoPage();

  @override
  State<_NuevoProductoPage> createState() => _NuevoProductoPageState();
}

class _NuevoProductoPageState extends State<_NuevoProductoPage>{
  late final _categorias = context.read<CategoriaRepository>();

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
  final _stockInicialController = TextEditingController();
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
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _marcaController.dispose();
    _categoriaId = null;
    _selectedCategoria = null;
    _foto = null;
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockInicialController.dispose();
    _stockMinimoController.dispose();
    _unidadController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _mostrarImagenCompleta(String tag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) =>
            VisorImagen(foto: _foto!, tag: tag),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget pictureOptions() {
    return BottomSheetContainer(
      children: [
        Text(_foto != null ? "Cambiar foto" : "Elegir foto", style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        PressableItem(
            icon: LucideIcons.camera,
            text: "Desde la camara",
            onPress: () { Navigator.pop(context, ImageSource.camera); },
            contentPadding: .symmetric(horizontal: 0)
        ),
        PressableItem(
            icon: LucideIcons.images,
            text: "Desde la galeria",
            onPress: () { Navigator.pop(context, ImageSource.gallery); },
            contentPadding: .symmetric(horizontal: 0)
        )
      ]
    );
  }

  Widget validadorImagen(){
    return FormField<File>(
      initialValue: _foto,
      validator: (v) => v == null ? 'Selecciona una imagen' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text.rich(
            TextSpan(
              text: "Imagen del producto",
              style: const TextStyle(fontWeight: FontWeight.w600),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error.main,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Text("toca para elegir una imagen"),
          Row(
            crossAxisAlignment: .center,
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            spacing: 8,
            children: [
              if(_foto != null) SizedBox(
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
                      child: Image.file(
                        _foto!,
                        fit: BoxFit.fill,
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
                      child: Icon(_foto != null ? LucideIcons.images : LucideIcons.imagePlus, size: 36, color: AppColors.terciario.c300,),
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
      backgroundColor: Colors.transparent,
      builder: (_) => pictureOptions(),
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

    final form = MultiStepForm(
      // Required callback
      onSubmit: () async {
        if (_formKey.currentState!.validate()) {
          final request = ProductoRequestDto(
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
              marca: _marcaController.text,
              stockActual: int.parse(_stockInicialController.text),
              stockMinimo: int.parse(_stockMinimoController.text), 
              stockReservado: 0,
              precioVenta: double.parse(_precioVentaController.text),
              precioCompra: double.parse(_precioCompraController.text),
              unidadMedia: _unidadController.text,
              sku: _skuController.text.isEmpty ? null : _skuController.text,
              categoria: {"id": _selectedCategoria!.id, "nombre": _selectedCategoria!.nombre, "descripcion": _selectedCategoria!.descripcion, "tieneProductos": _selectedCategoria!.tieneProductos}
          );

          await vm.registrar(request: request, file: _foto!);

          if(vm.successMessage != null) {
            Navigator.pop(context, true);
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
              isRequired: true,
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
              isRequired: true,
              maxLength: 25,
              validator: (value) => letrasNumerosValidator(value, 'La marca del producto es obligatoria'),
              keyboardType: .name,
              textInputAction: .next,
            ):
            CustomAutocomplete(
                controller: _marcaController,
                hint: 'Ej. Marinela',
                label: "Marca",
                isRequired: true,
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
                  isRequired: true,
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
              isRequired: true,
              minLines: 2,
              maxLines: 6,
              maxLength: 150,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              validator: (value) => letrasNumerosValidator(value, 'El descripción del producto es obligatoria')
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
              isRequired: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _doubleFormatter,
              validator: (value) => precioValidator(value, 'El precio de compra es obligatorio'),
              textInputAction: .next,
            ),
            CustomField(
              controller: _precioVentaController,
              hint: '0.00',
              label: "Precio de venta",
              isRequired: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _doubleFormatter,
              validator: (value) => precioValidator(value, 'El precio de venta es obligatorio'),
              textInputAction: .next,
            ),
            CustomField(
              controller: _stockInicialController,
              hint: 'Stock con el que se cuenta actualmente',
              label: "Stock actual",
              isRequired: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _intFormatter,
              validator: (value) => numeroPositivoValidator(value, 'El stock inicial es obligatorio', 999999, true),
              textInputAction: .next,
            ),
            CustomField(
              controller: _stockMinimoController,
              hint: 'Cantidad a considerar para pocas unidades',
              label: "Stock mínimo",
              isRequired: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _intFormatter,
              validator: (value) => numeroPositivoValidator(value, 'El stock mínimo es obligatorio', 999999, false),
              textInputAction: .next,
            ),
            CustomAutocomplete(
              controller: _unidadController,
              label: 'Unidad de medida',
              hint: 'Ej. pieza, litro, kg',
              isRequired: true,
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
                    isRequired: true,
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
            if(_foto != null)
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
                        child: Image.file(
                          _foto!,
                          fit: BoxFit.fill,
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
                    text: _stockInicialController.text,
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
      appBar: AppBarExterno(title: "Nuevo producto"),
      body: SafeArea(child:
        Padding(
          padding: .all(16),
          child: Form(
            key: _formKey,
            child: form,
          )
        )
      ),
    );
  }
}
