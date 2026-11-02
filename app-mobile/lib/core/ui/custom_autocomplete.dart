import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/theme/colors.dart';
import 'custom_form_field.dart';

class CustomAutocomplete extends StatefulWidget {
  const CustomAutocomplete({
    super.key,
    required this.controller,
    required this.options,
    required this.hint,
    this.label,
    this.icon,
    this.isRequired = false,
    this.validator,
    this.onSelected,
    this.maxLength,
    this.keyboardType,
    this.textInputAction
  });

  final TextEditingController controller;
  final List<String> options;
  final String hint;
  final String? label;
  final IconData? icon;
  final bool isRequired;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSelected;
  final int? maxLength;
  final TextInputType? keyboardType;
final TextInputAction? textInputAction;

  @override
  State<CustomAutocomplete> createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          optionsBuilder: (value) {
            final q = value.text.trim().toLowerCase();
            if (q.isEmpty) return const Iterable<String>.empty();
            return widget.options.where((o) => o.toLowerCase().contains(q));
          },
          onSelected: widget.onSelected,
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            return CustomField(
              controller: controller,
              focusNode: focusNode,
              label: widget.label,
              hint: widget.hint,
              icon: widget.icon,
              isRequired: widget.isRequired,
              validator: widget.validator,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final option = options.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(color: AppColors.texto.c900),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}