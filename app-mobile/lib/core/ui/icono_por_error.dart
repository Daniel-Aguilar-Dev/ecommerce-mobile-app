import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconData iconoPorError(ApiException error){
  return switch(error){
    ErrorAutenticacion() => LucideIcons.lock,
    SinConexion() => LucideIcons.wifiOff,
    TiempoAgotado() => LucideIcons.clock,
    ErrorServidor() => LucideIcons.serverCrash,
    PeticionRechazada() => LucideIcons.ban,
    RespuestaInvalida() => LucideIcons.fileWarning,
    DtoInvalido() => LucideIcons.octagonAlert,
  };
}