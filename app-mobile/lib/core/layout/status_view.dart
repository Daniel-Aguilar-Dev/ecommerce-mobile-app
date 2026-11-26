import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/core/ui/icono_por_error.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusView extends StatelessWidget{
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText = "Reintentar",
    this.onPressButton,
    this.isLoading = false
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback? onPressButton;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16),
      child: Column(
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
              child: Icon(icon, color: AppColors.terciario.c300, size: 64),
            ),
          ),
          Center(
            child:Text(title,
                textAlign: .center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold
            )),
          ),
          if(subtitle != null) Center(
            child:Text(subtitle ?? "", textAlign: .center, style: Theme.of(context).textTheme.bodySmall),
          ),
          if(onPressButton != null) FilledButton(
              style: _buttonStyle,
              onPressed: () {
                if(isLoading) return;
                onPressButton?.call();
              },
              child: isLoading
                  ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  :
              Text(buttonText)
          )
        ],
      ),
    );
  }

  const StatusView.empty({
    Key? key,
    String title = 'No hay registros',
    String? subtitle,
  }) : this(
    key: key,
    icon: LucideIcons.fileQuestionMark,
    title: title,
    subtitle: subtitle,
  );

  const StatusView.noResults({Key? key})
      : this(
    key: key,
    icon: LucideIcons.searchX,
    title: 'Sin coincidencias',
    subtitle: 'Prueba con otro término',
  );

  const StatusView.error({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    bool isLoading = false,
  }) : this(
    key: key,
    icon: LucideIcons.circleAlert,
    title: message,
    buttonText: 'Reintentar',
    onPressButton: onRetry,
    isLoading: isLoading,
  );

  const StatusView.offline({Key? key, VoidCallback? onRetry})
      : this(
    key: key,
    icon: LucideIcons.wifiOff,
    title: 'Sin conexión',
    subtitle: 'Revisa tu internet e intenta de nuevo',
    buttonText: 'Reintentar',
    onPressButton: onRetry,
  );

  StatusView.byApiException({
    Key? key,
    required ApiException exception,
    String buttonText = "Reintentar",
    VoidCallback? onRetry,
    bool isLoading = false,
  }) : this(
    key: key,
    icon: iconoPorError(exception),
    title: exception.message,
    buttonText: buttonText,
    onPressButton: onRetry,
    isLoading: isLoading,
  );

}


final _buttonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(AppColors.primario.c400),
  foregroundColor: WidgetStatePropertyAll(Colors.white),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontWeight: FontWeight.w600),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);