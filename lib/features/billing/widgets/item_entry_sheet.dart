import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/formatters/thousands_formatter.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/dotted_divider.dart';
import '../../../core/widgets/sheet_frame.dart';
import '../../../models/invoice_item.dart';

class ItemEntrySheet extends StatefulWidget {
  const ItemEntrySheet({super.key, required this.item, required this.onDelete, required this.onSave});

  final InvoiceItem? item;

  final void Function(String description, num qty, int unitPriceCents, bool addAnother) onSave;

  final VoidCallback? onDelete;

  @override
  State<ItemEntrySheet> createState() => _ItemEntrySheetState();
}

class _ItemEntrySheetState extends State<ItemEntrySheet> {
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _qtyFocus = FocusNode();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  bool get _isEditing => widget.item != null;

  bool get _isValid => _descriptionController.text.trim().isNotEmpty && _qty > 0 && _unitPriceCents > 0;

  int get _amountCents => (_qty * _unitPriceCents).round();

  int get _unitPriceCents => _priceController.text.asCentsOrNull ?? 0;

  num get _qty => num.tryParse(_qtyController.text.replaceAll(',', '').trim()) ?? 0;

  void _save({required bool addAnother}) {
    if (!_isValid) return;
    widget.onSave(_descriptionController.text.trim(), _qty, _unitPriceCents, addAnother);
    if (!addAnother) {
      Navigator.of(context).pop();
      return;
    }
    _descriptionController.clear();
    _priceController.clear();
    _qtyController.clear();
    HapticFeedback.selectionClick();
    setState(() {});
    _descriptionFocus.requestFocus();
  }

  Widget _numberField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required TextInputAction textInputAction,
    required VoidCallback onSubmitted,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: const <TextInputFormatter>[ThousandsFormatter()],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      label: label,
      onChanged: (String _) => setState(() {}),
      onSubmitted: (String _) => onSubmitted(),
      selectAllOnFocus: true,
      textAlign: TextAlign.right,
      textInputAction: textInputAction,
    );
  }

  Widget _actions() {
    if (_isEditing) {
      return SheetActions(
        primary: FilledButton(onPressed: _isValid ? () => _save(addAnother: false) : null, child: const Text('Save', maxLines: 1)),
        secondary: OutlinedButton(
          onPressed: widget.onDelete,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          child: const Text('Delete', maxLines: 1),
        ),
      );
    }
    return SheetActions(
      primary: FilledButton(onPressed: _isValid ? () => _save(addAnother: true) : null, child: const Text('Save & Next', maxLines: 1)),
      secondary: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger),
        ),
        child: const Text('Cancel', maxLines: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final InvoiceItem? item = widget.item;
    if (item != null) {
      _descriptionController.text = item.description;
      _priceController.text = item.unitPriceCents == 0 ? '' : item.unitPriceCents.asAmount;
      _qtyController.text = item.qty == 0 ? '' : item.qty.asQty;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _descriptionFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_isEditing ? 'Edit Item' : 'Add Item', maxLines: 1, style: AppTextStyles.sectionHeading),
              const SizedBox(height: AppSpacing.sm),
              const DottedDivider(),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                inputFormatters: const <TextInputFormatter>[UpperCaseFormatter()],
                label: 'Description',
                onChanged: (String _) => setState(() {}),
                onSubmitted: (String _) => _qtyFocus.requestFocus(),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _numberField(
                      controller: _qtyController,
                      focusNode: _qtyFocus,
                      label: 'Qty',
                      onSubmitted: _priceFocus.requestFocus,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _numberField(
                      controller: _priceController,
                      focusNode: _priceFocus,
                      label: 'Unit price',
                      onSubmitted: () => _save(addAnother: !_isEditing),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  const Text('AMOUNT', maxLines: 1, style: AppTextStyles.overline),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(_amountCents.asLkr, maxLines: 1, style: AppTextStyles.totalsValueBold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }
}
