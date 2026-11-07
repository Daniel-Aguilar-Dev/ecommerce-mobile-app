import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/cantidad_input.dart';
import 'package:ecommerce_app/core/ui/visor_imagen.dart';
import 'package:ecommerce_app/features/carrito/presentation/viewmodel/carrito_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/producto_card_public.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class DetallesProducto extends StatelessWidget {
  const DetallesProducto({ super.key, required this.productoId });
  final int productoId;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => ProductoViewModel(
          productoRepository: ctx.read<ProductoRepository>(),
        ),
        child: _DetallesView(productoId: productoId)
    );
  }
}

class _DetallesView extends StatefulWidget{
  const _DetallesView({ required this.productoId });
  final int productoId;

  @override
  State<StatefulWidget> createState() => _DetallesViewState();
}

class _DetallesViewState extends State<_DetallesView>{
  late final productoId = widget.productoId;
  int cantidad = 1;
  int stockNuevo = 0;

  late final Future<ProductoPublic?> _productoFuture;
  Future<List<ProductoPublic>>? _similaresFuture;

  ({Color fondo, Color color}) _disponibilidad(ProductoPublic producto) {
    final estado = producto.estadoStock;
    if (estado == "Agotado") {
      return (fondo: AppColors.error.soft, color: AppColors.error.onSoft);
    }
    if (estado == "Pocas unidades") {
      return (fondo: AppColors.warning.soft, color: AppColors.warning.onSoft);
    }
    return (fondo: AppColors.success.soft, color: AppColors.success.onSoft);
  }

  int _resetInput = 0; // contador para la key

  @override
  void initState() {
    super.initState();
    _productoFuture =
        context.read<ProductoRepository>().unoPublicoPorId(productoId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CarritoViewModel>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarExterno(title: "Detalles del producto"),
      body: FutureBuilder<ProductoPublic?>(
        future: _productoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.primario.c400,
                semanticsLabel: "Cargando...",
              ),
            );
          }

          if (snapshot.hasError) {
            return StatusView.error(message: snapshot.error.toString());
          }

          final prod = snapshot.data;
          if (prod == null) {
            // HU-2.3: si no se encuentra, pantalla de registro no encontrado
            return StatusView.error(message: "Producto no encontrado");
          }

          final tag = _disponibilidad(prod);
          _similaresFuture ??= vm.getProudctosSimilares(prod.categoria.id);

          void mostrarImagenCompleta(String tag) {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black87,
                transitionDuration: const Duration(milliseconds: 250),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (_, _, _) =>
                    VisorImagen(url: prod.imagen, tag: tag),
                transitionsBuilder: (_, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        GestureDetector(
                          onTap: () => mostrarImagenCompleta('foto-producto-${prod.id}'),
                          child: Hero(
                            tag: 'foto-producto-${prod.id}',
                            child: AspectRatio(
                              aspectRatio: 4/3, // cuadrada; usa 4/3 si la quieres menos alta
                              child: SizedBox(
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: prod.imagen,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    'assets/images/prod_placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: .all(16),
                          child: Column(
                            spacing: 4,
                            mainAxisSize: .min,
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .start,
                            children: [
                              Text(prod.marca, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300, color: AppColors.primario.c900, decoration: TextDecoration.underline)),
                              Text(prod.nombre, style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: 24)),
                              Text("\$ ${prod.precio.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tag.fondo,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  prod.estadoStock,
                                  style: theme.textTheme.labelMedium!.copyWith(
                                    color: tag.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(prod.descripcion, style: Theme.of(context).textTheme.bodyLarge,),
                              const SizedBox(height: 16),
                              FutureBuilder(
                                future: _similaresFuture,
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState != ConnectionState.done) {
                                    return Center(
                                      child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primario.c400)),
                                    );
                                  }

                                  if(snapshot.data == null) return const SizedBox(height: 1);

                                  final list = snapshot.data!.where((item) => item.id != prod.id).toList();

                                  if(list.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment: .start,
                                      mainAxisAlignment: .start,
                                      mainAxisSize: .min,
                                      children: [
                                        Text("Más en ${prod.categoria.nombre.toLowerCase()}", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 300,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: list.length,
                                            separatorBuilder: (_, __) => const SizedBox(width: 4),
                                            itemBuilder: (context, i) {
                                              final p = list[i];
                                              return SizedBox(
                                                width: 175,
                                                child: ProductoCardPublic(
                                                  producto: p,
                                                  onCardTouch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetallesProducto(productoId: p.id))),
                                                  onPressButton: () {},
                                                  showButton: false
                                                ),
                                              );
                                            }
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  return const SizedBox(height: 1);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Padding(
                    padding: .all(16),
                    child: Row(
                      crossAxisAlignment: .center,
                      mainAxisAlignment: .spaceBetween,
                      spacing: 16,
                      children: [
                        CantidadInput(max: stockNuevo == 0 ? prod.stock : stockNuevo, min: 1, acceptZero: false, onChange: (val) => setState(() => cantidad = val), key: ValueKey(_resetInput)),
                        Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            vm.limpiarMensajes();
                            if(prod.stock <= 0) return;
                            int stockReal =  await vm.agregarAlCarrito(prod, cantidad);
                            if(vm.errorMessage != null){
                              setState(() {
                                cantidad = 1;
                                stockNuevo = stockReal;
                                _resetInput++; // recrea el input en 1
                              });
                              AppToast.show(context, variant: ToastType.info, title: "¡Información!", message: vm.errorMessage);
                            }else {
                              AppToast.show(context, variant: ToastType.success, title: "¡Éxito!", message: vm.successMessage);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              prod.stock <= 0 ? AppColors.border : AppColors.primario.c400,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          child: vm.isLoading ? CircularProgressIndicator(strokeWidth: 2, color: Colors.white) : Row(crossAxisAlignment: .center, mainAxisAlignment: .center, spacing: 4,children: [const Icon(LucideIcons.shoppingCartPlus), const Text("Agregar al carrito")],)
                          ),
                        )
                      ],
                    ),
                  )
                )
              ],
            )
          );
        }
      ),
    );
  }
}