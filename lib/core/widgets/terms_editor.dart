import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'term_entry_sheet.dart';

class TermsEditor extends StatelessWidget {
  const TermsEditor({super.key, required this.terms, required this.onChanged});

  final List<String> terms;

  final ValueChanged<List<String>> onChanged;

  Future<void> _openSheet(BuildContext context, {int? index}) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => TermEntrySheet(
        term: index == null ? null : terms[index],
        onDelete: index == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onChanged(<String>[...terms]..removeAt(index));
              },
        onSave: (String term, bool addAnother) {
          if (index == null) {
            onChanged(<String>[...terms, term]);
            return;
          }
          final List<String> next = <String>[...terms];
          next[index] = term;
          onChanged(next);
        },
      ),
      isScrollControlled: true,
      showDragHandle: true,
    );
  }

  Widget _term(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: AppSpacing.itemCardHeight,
            width: AppSpacing.indexColumn,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.cardPadding),
              child: Text('${index + 1}.', maxLines: 1, style: AppTextStyles.listSecondary),
            ),
          ),
          Expanded(
            child: Material(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              color: AppColors.surfaceCard,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                onTap: () => _openSheet(context, index: index),
                child: Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  height: AppSpacing.itemCardHeight,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Text(terms[index], maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < terms.length; index++) _term(context, index),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Add new T&C', maxLines: 1), onPressed: () => _openSheet(context)),
      ],
    );
  }
}
