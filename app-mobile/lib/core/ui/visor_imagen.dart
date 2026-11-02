import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VisorImagen extends StatelessWidget {
  const VisorImagen({super.key, required this.foto, required this.tag});

  final File foto;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: .all(16),
          child: Center(
            child: Hero(
              tag: tag,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child:AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(foto, fit: BoxFit.fill),
                )
              ),
            ),
          ),
        )
      ),
    );
  }
}