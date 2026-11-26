// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A widget that displays a multi-step form with navigation controls.
///
/// This widget manages the state and navigation between multiple form steps,
/// providing a consistent interface for collecting user input across multiple screens.
class MultiStepForm extends StatefulWidget {
  /// Creates a MultiStepFormWidget.
  ///
  /// The [steps] parameter is required and contains the list of form steps to display.
  const MultiStepForm({
    super.key,
    required this.steps,
    required this.onSubmit,
    this.nextButtonColor = const Color(0xFF2196F3), // Primary blue
    this.prevButtonColor = const Color(0xFF424242), // Dark grey
    this.submitButtonColor = const Color(0xFF4CAF50), // Green
    this.nextButtonTextColor = Colors.white,
    this.prevButtonTextColor = Colors.white,
    this.submitButtonTextColor = Colors.white,
    this.stepIndicatorActiveColor = const Color(0xFF2196F3), // Primary blue
    this.stepIndicatorDefaultColor = const Color(0xFF757575), // Medium grey
    this.isSubmitting = false
  });

  /// The list of form steps to display.
  final List<FormStep> steps;

  /// Callback function called when all steps are completed.
  ///
  /// This function is called when the user reaches and completes the last step.
  final Function onSubmit;

  /// The color of the next button.
  final Color nextButtonColor;

  /// The color of the previous button.
  final Color prevButtonColor;

  /// The color of the submit button.
  final Color submitButtonColor;

  /// The color of the next button text.
  final Color nextButtonTextColor;

  /// The color of the previous button text.
  final Color prevButtonTextColor;

  /// The color of the submit button text.
  final Color submitButtonTextColor;

  /// The color of the active step indicator.
  final Color stepIndicatorActiveColor;

  /// The color of the default step indicator.
  final Color stepIndicatorDefaultColor;

  final bool isSubmitting;

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  late List<GlobalKey<FormState>> formKeys;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    initFormGlobalKeys();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void initFormGlobalKeys() {
    setState(() {
      formKeys = List.generate(
        widget.steps.length,
            (index) => GlobalKey<FormState>(),
      );
    });
  }

  Widget _buildStepIndicator(int index, String title, BuildContext context) {
    final isActive = _currentStep >= index;
    final isPast = _currentStep > index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.stepIndicatorActiveColor;
    final inactiveLine = isDark ? Colors.white10 : Colors.grey[300]!;
    final isFirst = index == 0;
    final isLast = index == widget.steps.length - 1;

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: isFirst
                      ? Colors.transparent
                      : (isPast || isActive ? activeColor : inactiveLine),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast || isActive
                      ? activeColor
                      : (isDark ? Colors.white10 : Colors.grey[200]),
                  boxShadow: isPast || isActive
                      ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: isPast
                      ? const Icon(LucideIcons.check, color: Colors.white, size: 18)
                      : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey[600]),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: isLast
                      ? Colors.transparent
                      : (isPast ? activeColor : inactiveLine),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? activeColor
                    : (isDark ? Colors.white70 : Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Form(
        key: formKeys[_currentStep],
        child: Scaffold(
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  top: size.width * 0.04,
                  right: size.width * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / widget.steps.length,
                        backgroundColor: isDark
                            ? Colors.white10
                            : widget.stepIndicatorDefaultColor.withAlpha(15),
                        valueColor: AlwaysStoppedAnimation(
                            widget.stepIndicatorActiveColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: FormTheme.spacing * 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < widget.steps.length; i++)
                          _buildStepIndicator(i, widget.steps[i].title, context),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        top: size.width * 0.04,
                        left: size.width * 0.02,
                        bottom: size.height * .15,
                        right: size.width * 0.02),
                    child: Padding(
                      padding: .all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          ...widget.steps[_currentStep].fields,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              children: [
                if (_currentStep != 0)
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          if(widget.isSubmitting) return;
                          _animationController.reverse().then((_) {
                            setState(() => _currentStep--);
                            _animationController.forward();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: widget.prevButtonTextColor,
                          backgroundColor: widget.prevButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )
                        ),
                        child: const Text("Anterior"),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      if(widget.isSubmitting) return;
                      final extraOk = widget.steps[_currentStep].beforeNextStep?.call() ?? true;
                      if (formKeys[_currentStep].currentState!.validate()) {
                        if(!extraOk) return;
                        if (_currentStep < widget.steps.length - 1) {
                          _animationController.reverse().then((_) {
                            setState(() => _currentStep++);
                            _animationController.forward();
                          });
                        } else {
                          widget.onSubmit();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _currentStep == widget.steps.length - 1
                          ? widget.submitButtonTextColor
                          : widget.nextButtonTextColor,
                      backgroundColor: _currentStep == widget.steps.length - 1
                          ? widget.submitButtonColor
                          : widget.nextButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    child: widget.isSubmitting
                        ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        :Text(_currentStep == widget.steps.length - 1
                        ? 'Guardar'
                        : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormStep {
  const FormStep({
    required this.title,
    required this.fields,
    this.subtitle,
    this.beforeNextStep,
  });

  /// The title displayed at the top of the form step.
  final String title;

  /// An optional subtitle displayed below the title.
  final String? subtitle;

  /// The list of form field widgets to display in this step.
  final List<Widget> fields;

  /// A callback that can be used for validate fields that cannot be validated in a textfield
  final bool Function()? beforeNextStep;
}


class FormTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF2A2A2A);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color successColor = Color(0xFF40B273);
  static const Color errorColor = Color(0xFFE74C3C);

  static const double borderRadius = 12.0;
  static const double spacing = 16.0;

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(13), // Changed from withOpacity(0.05)
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
