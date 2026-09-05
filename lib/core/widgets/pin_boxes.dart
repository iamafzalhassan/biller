import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class PinBoxes extends StatefulWidget {
  const PinBoxes({
    super.key,
    required this.autofocus,
    required this.controller,
    required this.hasError,
    required this.onChanged,
    required this.onCompleted,
    this.enabled = true,
  });

  final bool autofocus;
  final bool enabled;
  final bool hasError;

  final TextEditingController controller;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  State<PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<PinBoxes> {
  static const double stripWidth = AppSpacing.pinBox * length + AppSpacing.md * (length - 1);

  static const int length = 4;

  final FocusNode _focusNode = FocusNode();

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    if (value.length == length) widget.onCompleted(value);
  }

  Widget _box(int index) {
    final int filled = widget.controller.text.length;
    final Color border = widget.hasError ? AppColors.danger : Colors.transparent;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: border, width: AppSpacing.borderFocus),
        borderRadius: BorderRadius.circular(AppSpacing.radiusField),
        color: AppColors.surfaceField,
      ),
      height: AppSpacing.pinBox,
      width: AppSpacing.pinBox,
      child: index < filled ? const _PinDot() : const SizedBox.shrink(),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
    if (widget.autofocus) WidgetsBinding.instance.addPostFrameCallback((Duration _) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focusNode.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: AppSpacing.pinBox,
          width: stripWidth,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[for (int index = 0; index < length; index++) _box(index)]),
              Positioned.fill(
                child: TextField(
                  autocorrect: false,
                  contextMenuBuilder: (BuildContext context, EditableTextState state) => const SizedBox.shrink(),
                  controller: widget.controller,
                  cursorColor: Colors.transparent,
                  cursorWidth: 0,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: false,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                  ),
                  enabled: widget.enabled,
                  enableInteractiveSelection: false,
                  enableSuggestions: false,
                  focusNode: _focusNode,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  maxLength: length,
                  onChanged: _handleChanged,
                  showCursor: false,
                  style: const TextStyle(color: Colors.transparent, fontSize: 1, height: 0.01),
                ),
              ),
            ],
          ),
        ),
        if (widget.hasError) const SizedBox(height: AppSpacing.md),
        if (widget.hasError)
          const Text(
            'Incorrect PIN',
            maxLines: 1,
            style: TextStyle(color: AppColors.danger, fontFamily: AppTextStyles.fontFamily, fontSize: 13, height: 1.2),
          ),
      ],
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
      height: AppSpacing.md,
      width: AppSpacing.md,
    );
  }
}
