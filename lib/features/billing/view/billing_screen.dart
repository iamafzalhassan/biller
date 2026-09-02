import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/widgets/dotted_divider.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../models/invoice.dart';
import '../../../models/invoice_item.dart';
import '../../preview/controller/print_service.dart';
import '../controller/billing_controller.dart';
import '../controller/billing_state.dart';
import '../widgets/advance_sheet.dart';
import '../widgets/customer_field.dart';
import '../widgets/draft_banner.dart';
import '../widgets/item_entry_sheet.dart';
import '../widgets/item_row.dart';
import '../widgets/live_preview_pane.dart';
import '../widgets/totals_section.dart';
import 'layouts/billing_phone_layout.dart';
import 'layouts/billing_tablet_layout.dart';

final DateFormat _appBarDateFormat = DateFormat('d MMM, h:mm a');

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  BillingController get _controller => ref.read(billingControllerProvider.notifier);

  Future<void> _openSheet({InvoiceItem? item}) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ItemEntrySheet(
        item: item,
        onDelete: item == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                _removeItem(item.id);
              },
        onSave: (String description, num qty, int unitPriceCents, bool addAnother) {
          if (item == null) {
            _controller.addItem(description: description, qty: qty, unitPriceCents: unitPriceCents);
          } else {
            _controller.updateItem(id: item.id, description: description, qty: qty, unitPriceCents: unitPriceCents);
          }
        },
      ),
      isScrollControlled: true,
      showDragHandle: true,
    );
  }

  Future<void> _openAdvanceSheet(int advanceCents) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) =>
          AdvanceSheet(advanceCents: advanceCents, onRemove: () => _controller.setAdvance(0), onSave: _controller.setAdvance),
      isScrollControlled: true,
      showDragHandle: true,
    );
  }

  void _removeItem(String id) {
    final (int, InvoiceItem)? removed = _controller.removeItem(id);
    if (removed == null) return;
    context.showBriefSnack(
      'Item removed',
      action: SnackBarAction(label: 'Undo', onPressed: () => _controller.reinsertItem(removed.$1, removed.$2)),
    );
  }

  Future<void> _openPreview() => Navigator.of(context).pushNamed(Routes.preview);

  Future<void> _printDirect() async {
    final String number = ref.read(billingControllerProvider).invoice.invoiceNumber;
    final Uint8List bytes = await _controller.commit();
    await PrintService.layout(bytes, name: number);
    _controller.startNewBill();
  }

  void _reseedFields(BillingState state) {
    _nameController.text = state.invoice.customerName;
    _phoneController.text = state.invoice.customerPhone ?? '';
  }

  PreferredSizeWidget _appBar(BillingState state) {
    return AppBar(
      actions: <Widget>[
        if (kDebugMode) IconButton(icon: const Icon(Icons.science_outlined), onPressed: _controller.loadMockBill, tooltip: 'Load mock bill'),
        IconButton(icon: const Icon(Icons.receipt_long_outlined), onPressed: () => Navigator.of(context).pushNamed(Routes.recent), tooltip: 'Recent invoices'),
        IconButton(icon: const Icon(Icons.lock_outline), onPressed: () => Navigator.of(context).pushNamed(Routes.settings), tooltip: 'Settings'),
        const SizedBox(width: AppSpacing.sm),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(state.invoice.invoiceNumber, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
              ),
              if (state.invoice.isRevised) const _RevisedChip(),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(_appBarDateFormat.format(state.invoice.createdAt), maxLines: 1, style: AppTextStyles.listSecondary),
        ],
      ),
    );
  }

  Widget _customerField() {
    return CustomerField(
      nameController: _nameController,
      nameFocus: _nameFocus,
      onNameChanged: _controller.setCustomerName,
      onNameSubmitted: _phoneFocus.requestFocus,
      onPhoneChanged: _controller.setCustomerPhone,
      phoneController: _phoneController,
      phoneFocus: _phoneFocus,
    );
  }

  Widget? _draftBanner(BillingState state) {
    if (!state.isRestorable) return null;
    final Invoice? draft = ref.read(draftRepositoryProvider).draft;
    if (draft == null) return null;
    return DraftBanner(onDiscard: _controller.discardDraft, onRestore: _controller.restoreDraft, savedAt: draft.createdAt);
  }

  List<Widget> _itemRows(List<InvoiceItem> items) {
    return <Widget>[
      for (int index = 0; index < items.length; index++)
        Dismissible(
          key: ValueKey<String>(items[index].id),
          background: const _DeleteBackground(),
          direction: DismissDirection.endToStart,
          onDismissed: (DismissDirection _) => _removeItem(items[index].id),
          child: Column(
            children: <Widget>[
              if (index > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: DottedDivider(),
                ),
              ItemRow(
                item: items[index],
                onTap: () => unawaited(_openSheet(item: items[index])),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _addItemButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add item', maxLines: 1),
      onPressed: () => unawaited(_openSheet()),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _emptyItems() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        color: AppColors.surfaceCard,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: const Text('No items yet', maxLines: 1, style: AppTextStyles.listSecondary),
    );
  }

  Widget _totalsSection(BillingState state) {
    return TotalsSection(
      advanceCents: state.invoice.advanceCents,
      balanceCents: state.invoice.balanceCents,
      showsAdvance: state.invoice.showsAdvance,
      totalCents: state.invoice.totalCents,
      onAdvanceTap: () => unawaited(_openAdvanceSheet(state.invoice.advanceCents)),
    );
  }

  Widget _printButton(BillingState state, {required String label, required Future<void> Function() onPrint}) {
    return GestureDetector(
      onTap: state.canPrint ? null : () => context.showBriefSnack(state.blockingReason),
      child: FilledButton(
        onPressed: state.canPrint ? () => unawaited(onPrint()) : null,
        child: state.isPrinting
            ? const SizedBox(
                height: AppSpacing.progressIndicator,
                width: AppSpacing.progressIndicator,
                child: CircularProgressIndicator(color: AppColors.primaryOn, strokeWidth: 2),
              )
            : Text(label, maxLines: 1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _reseedFields(ref.read(billingControllerProvider));
    unawaited(WakelockPlus.enable());
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BillingState>(billingControllerProvider, (BillingState? previous, BillingState next) {
      if (previous != null && previous.formRevision != next.formRevision) _reseedFields(next);
    });

    final BillingState state = ref.watch(billingControllerProvider);
    final List<InvoiceItem> items = state.invoice.items;

    return Scaffold(
      appBar: _appBar(state),
      body: SafeArea(
        child: ResponsiveBuilder(
          phone: (BuildContext context) => BillingPhoneLayout(
            addItemButton: _addItemButton(),
            customerField: _customerField(),
            draftBanner: _draftBanner(state),
            emptyState: items.isEmpty ? _emptyItems() : null,
            itemRows: _itemRows(items),
            printButton: _printButton(state, label: 'Preview & Print', onPrint: _openPreview),
            scrollController: _scrollController,
            totalsSection: _totalsSection(state),
          ),
          tablet: (BuildContext context) => BillingTabletLayout(
            addItemButton: _addItemButton(),
            customerField: _customerField(),
            draftBanner: _draftBanner(state),
            emptyState: items.isEmpty ? _emptyItems() : null,
            itemRows: _itemRows(items),
            previewPane: const LivePreviewPane(),
            printButton: _printButton(state, label: 'Print', onPrint: _printDirect),
            scrollController: _scrollController,
            totalsSection: _totalsSection(state),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class _RevisedChip extends StatelessWidget {
  const _RevisedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusChip), color: AppColors.warning.withValues(alpha: 0.15)),
      margin: const EdgeInsets.only(left: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      child: const Text(
        'REVISED',
        maxLines: 1,
        style: TextStyle(
          color: AppColors.warning,
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      color: AppColors.danger.withValues(alpha: 0.12),
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: const Icon(Icons.delete_outline, color: AppColors.danger),
    );
  }
}
