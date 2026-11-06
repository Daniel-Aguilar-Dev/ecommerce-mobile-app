import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum InputSize{
  small,
  medium,
  large
}

class CantidadInput extends StatefulWidget{
  const CantidadInput({
    super.key,
    required this.max,
    required this.min,
    required this.onChange,
    this.acceptZero = true,
    this.size = InputSize.large
  }):assert(min >= 0);

  final int min;
  final int max;
  final void Function(int) onChange;
  final bool acceptZero;
  final InputSize size;

  @override
  State<StatefulWidget> createState() => _CantidadInputState();
}

class _CantidadInputState extends State<CantidadInput> {
  late int val = widget.acceptZero ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconSize = switch (widget.size) {
      InputSize.small => 16.0,
      InputSize.medium => 20.0,
      InputSize.large => 24.0,
    };
    final padding = switch (widget.size) {
      InputSize.small => 4.0,
      InputSize.medium => 6.0,
      InputSize.large => 8.0,
    };
    final labelSize = switch (widget.size) {
      InputSize.small => theme.textTheme.labelSmall,
      InputSize.medium => theme.textTheme.labelMedium,
      InputSize.large => theme.textTheme.labelLarge,
    };

    Widget button(IconData icon, bool disabled, VoidCallback onTap) {
      return InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(
            icon,
            size: iconSize,
            color: disabled ? AppColors.border : AppColors.texto.c900,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          button(LucideIcons.minus, val <= widget.min, () {
            setState(() => val--);
            widget.onChange(val);
          }),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: iconSize),
            child: Text(
              val.toString(),
              textAlign: TextAlign.center,
              style: labelSize,
            ),
          ),
          button(LucideIcons.plus, val >= widget.max, () {
            setState(() => val++);
            widget.onChange(val);
          }),
        ],
      ),
    );
  }
}