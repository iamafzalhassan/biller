import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.autofocus = false,
    this.isGrowable = false,
    this.obscureText = false,
    this.selectAllOnFocus = false,
    this.maxLength,
    required this.label,
    this.prefixText,
    this.inputFormatters,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    required this.controller,
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final bool autofocus;
  final bool isGrowable;
  final bool obscureText;
  final bool selectAllOnFocus;

  final int? maxLength;

  final String label;
  final String? prefixText;

  final List<TextInputFormatter>? inputFormatters;

  final FocusNode? focusNode;

  final TextAlign textAlign;

  final TextCapitalization textCapitalization;

  final TextEditingController controller;

  final TextInputAction? textInputAction;

  final TextInputType? keyboardType;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  void _onFocusChanged() {
    if (!widget.selectAllOnFocus || !_focusNode.hasFocus) return;
    widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length);
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: AppSpacing.controlHeight, maxHeight: widget.isGrowable ? double.infinity : AppSpacing.controlHeight),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusField), color: AppColors.surfaceField),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.fieldLabel, textAlign: widget.textAlign),
        TextField(
          autofocus: widget.autofocus,
          controller: widget.controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            constraints: const BoxConstraints(),
            contentPadding: EdgeInsets.zero,
            counterText: '',
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            filled: false,
            focusedBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            isCollapsed: true,
            prefixStyle: AppTextStyles.fieldValue,
            prefixText: widget.prefixText,
          ),
          focusNode: _focusNode,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.isGrowable ? null : 1,
          minLines: 1,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: AppTextStyles.fieldValue,
          textAlign: widget.textAlign,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
        ),
      ],
    ),
  );
}
