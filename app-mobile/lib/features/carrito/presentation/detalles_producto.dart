import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/ui/visor_imagen.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarExterno(title: "Detalles del producto"),
      body: FutureBuilder<ProductoPublic?>(
        future: context.read<ProductoRepository>().unoPublicoPorId(productoId),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => mostrarImagenCompleta('foto-producto-detalle'),
                      child: Hero(
                        tag: 'foto-producto-detalle',
                        child: SizedBox(
                          height: 250,
                          child: AspectRatio(aspectRatio: 1, child: CachedNetworkImage(
                            imageUrl: prod.imagen,
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
                          ),),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: .all(16),
                    child: Column(
                      spacing: 8,
                      mainAxisSize: .min,
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        Text("Marca: ${prod.marca}", style: theme.textTheme.bodyMedium),
                        Text(prod.nombre, style: theme.textTheme.titleLarge),
                        Text("\$ ${prod.precio.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                        Text(prod.descripcion, style: Theme.of(context).textTheme.labelLarge,),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: "Categoría: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: prod.categoria.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16,)
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}