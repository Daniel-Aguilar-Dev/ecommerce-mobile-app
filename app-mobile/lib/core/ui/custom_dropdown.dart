import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/colors.dart';
import 'custom_input_decoration.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.value,
    this.label,
    this.icon,
    this.validator,
    this.isRequired = false,
    this.requiredMessage = "Este campo es obligatorio"
  });

  /// Opciones como (valor, texto a mostrar).
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final IconData? icon;
  final String? Function(T?)? validator;
  final bool isRequired;
  final String requiredMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.w600),
              children: [
                if (isRequired)
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
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          borderRadius: BorderRadius.circular(7),
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 19,
            color: AppColors.texto.c900,
          ),
          hint: Text(
            hint,
            style: TextStyle(color: AppColors.texto.c400, fontSize: 13),
          ),
          decoration: customInputDecoration(icon: icon),
          validator: (v) {
            if (isRequired && v == null) return requiredMessage;
            return validator?.call(v);
          },
        ),
      ],
    );
  }
}