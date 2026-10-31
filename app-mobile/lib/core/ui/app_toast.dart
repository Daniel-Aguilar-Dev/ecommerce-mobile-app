import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ToastType { success, warning, info, error }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    {
      required ToastType variant,
      required String title,
      String? message,
      Duration duration = const Duration(seconds: 4),
    }
    )
  {
    final backColor = switch(variant){
      ToastType.success => AppColors.success.soft,
      ToastType.warning => AppColors.warning.soft,
      ToastType.info => AppColors.info.soft,
      ToastType.error => AppColors.error.soft,
    };

    final textColor = switch(variant){
      ToastType.success => AppColors.success.onSoft,
      ToastType.warning => AppColors.warning.onSoft,
      ToastType.info => AppColors.info.onSoft,
      ToastType.error => AppColors.error.onSoft,
    };

    final icon = switch(variant){
      ToastType.success => LucideIcons.circleCheck,
      ToastType.warning => LucideIcons.triangleAlert,
      ToastType.info => LucideIcons.badgeInfo,
      ToastType.error => LucideIcons.circleAlert,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Card(
          margin: EdgeInsets.zero,
          color: backColor,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            leading: Icon(icon, color: textColor, size: 36,),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            subtitle: message != null ? Text(message, style: TextStyle(color: textColor)) : null,
            trailing: IconButton(onPressed: () => messenger.hideCurrentSnackBar(), icon: Icon(LucideIcons.x, color: textColor, size: 20)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: .symmetric(horizontal: 16),
        behavior: SnackBarBehavior.fixed,
        //margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
      )
    );
  }
}