import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/carrito//presentation/detalles_producto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>{
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: .all(16),
        child: Column(
          children: [
            CustomField(
              controller: _searchController,
              hint: 'Buscar un producto',
              icon: LucideIcons.search,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo electrónico';
                }
                if (!value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            Text("Lista de productos"),
            CachedNetworkImage(
              imageUrl: "http://via.placeholder.com/350x150",
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  Image.asset(
                    'assets/images/cart_logo.png',
                    fit: BoxFit.contain,
                  ),
              width: 170,
              height: 165,
              fit: BoxFit.contain,
            ),
            FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetallesProducto()
                  ),
                ),
                child: Text("Ver producto")
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primario.c400,
        onPressed: () => {},
        elevation: 1,
        child: Icon(LucideIcons600.plus, color: Colors.white),
      ),
    );
  }
}