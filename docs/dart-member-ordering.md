# Dart Member Ordering Convention

Apply this to every Dart/Flutter class. Reorder and re-space only — never
change logic, names, or behaviour.

## 1. Member order within a class

1. `static const`
2. `static final`
3. `static` (mutable)
4. `final` instance fields
5. `late final` instance fields
6. mutable instance fields
7. nullable mutable fields
8. constructors — default, then named, then factories
9. getters and setters
10. public methods
11. private methods (`_foo`)
12. **overrides, last** — in `State` classes: lifecycle first (`initState`,
    `didChangeDependencies`, `didUpdateWidget`, `dispose`), then `==` and
    `hashCode` adjacent, then `toString`, then `build` at the very bottom

**Override getters** with no conventional position (`props`, `stringify`,
`hashCode` aside) sort by the tier rule in §2 on their return type — so
`bool get stringify` before `List<Object?> get props`.

**Widget-class exception:** in a `StatefulWidget` / `StatelessWidget`, the
`const` constructor comes *before* the fields, then the fields, then
`createState()`. This is standard Flutter style and overrides rule 1.

## 2. Field ordering inside each group

Sort by **type tier**, then **type name**, then **variable name**.

**Tier order:**

1. **Primitives** — `bool`, `double`, `int`, `num`, `String`
2. **Collections** — `Iterable`, `List`, `Map`, `Set`
3. **Everything else** — records, `BigInt`, `DateTime`, `Duration`, `dynamic`,
   `Function`, `Object`, `RegExp`, `Runes`, `Symbol`, enums, typed-data,
   Flutter types, and all project model classes

**Within a tier:**

- Type name alphabetical, case-insensitive.
- Then variable name alphabetical, case-insensitive.
- Ignore the leading `_` when sorting private fields.
- A nullable type sits immediately after its non-nullable base
  (`String?` right after `String`).
- Sort on the **full type string**, so type arguments break ties.
  `List<int>` before `List<String>`.
  **`Animation<double>` before `AnimationController`** — `<` sorts before `C`.
  This one is counterintuitive; expect to correct it in review.
- Records start with `(` — place them first in tier 3.
- `dynamic` and `Null` have no nullable counterpart (`dynamic?` is invalid).
- `Never` and `void` cannot be field types.

## 3. Method ordering

**Fields are sorted mechanically. Methods are not.**

Within the public group, and again within the private group, order methods by
**call order** — the sequence in which they actually run:

- Methods called from the constructor come first, in the order called.
- Then the main entry points, then what they call, top-down.
- A helper used by several methods goes after the last of its callers.
- A method with no callers in the class goes at the end of its group.

Getters stay alphabetical — they have no call order.

This is a judgment call, not a mechanical rule, so two reviewers may order the
same class differently. Accepted: reading order beats sortability for methods.

## 4. Blank lines

- One blank line between each distinct **type** in the field block.
- Fields of the *same* type sit together with no break between them.
- Section header comments mark group boundaries, since per-type blank lines
  erase them. Use `/* ── Mutable fields ── */` style.
- **No** blank lines inside parameter lists, map literals, or argument lists.

## 5. Compactness

- Single-expression bodies always use `=>`.
- Multi-statement bodies stay expanded — `dart format` re-expands them anyway.
- Introduce no line break that `dart format` would not require.

## 6. Widget properties at call sites

Named arguments in `build` are alphabetical, with two exceptions:

- `key` always first.
- `child` / `children` always last.

Example: `controller`, `decoration`, `enabled`, `focusNode`, `maxLines`, then
`child`.

## 7. Mirrored lists stay consistent

Constructor parameters, `copyWith` parameters, `props`, `toJson` map keys, and
`fromJson` arguments follow the **same tier + type + name order** as the fields
they mirror.

A parameter with no matching field (e.g. `copyWith`'s `clearMessages`) sorts
into its type group by name like any other.

## 8. Known trade-offs (accepted)

- `hashCode` is a getter but lives with the overrides, next to `==`.
- `toJson` key order is driven by Dart types, not JSON readability — `id` will
  not be first. Fine for machine-only payloads.
- `initState` sits near the bottom of a long `State` class even though it runs
  first.
- Alphabetical ordering splits semantically related fields
  (`marginTop` / `paddingTop`).

## 9. Tooling

- No Dart lint enforces field ordering — this is a team convention, upheld in
  review.
- IDE "Sort Members" (VS Code Dart plugin, Android Studio `⌥⌘S`) uses a
  different scheme. Disable it or don't run it.
- Set `page_width` in `analysis_options.yaml` if 80 chars is too tight:

```yaml
formatter:
  page_width: 120
```

## 10. Retrofitting an existing project

Reordering a whole repo produces large diffs and wrecks `git blame`. Prefer
applying this to new files and to files already being changed substantially.

---

## Reference example — model class

```dart
import 'dart:convert';

enum OrderStatus { cancelled, delivered, pending, shipped }

class Order {
  /* ── Static constants ── */
  static const double taxRate = 0.08;

  static const int maxItems = 50;

  static const String currencyCode = 'USD';

  /* ── Static variables ── */
  static int activeOrders = 0;

  /* ── Immutable fields ── */
  final double subtotal;

  final String customerId;
  final String id;

  final List<String> itemSkus;

  final DateTime placedAt;

  /* ── Lazy fields ── */
  late final double total = subtotal * (1 + taxRate);

  late final String receiptId = 'RCP-$id';

  /* ── Mutable fields ── */
  bool isPaid = false;

  int retryCount = 0;

  OrderStatus status = OrderStatus.pending;

  /* ── Nullable fields ── */
  String? couponCode;
  String? trackingNumber;

  DateTime? shippedAt;

  /* ── Constructors ── */
  Order({
    required this.subtotal,
    required this.customerId,
    required this.id,
    required this.itemSkus,
    required this.placedAt,
  }) {
    activeOrders++;
  }

  Order.empty() : this(subtotal: 0, customerId: '', id: '', itemSkus: const [], placedAt: DateTime(1970));

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        subtotal: (json['subtotal'] as num).toDouble(),
        customerId: json['customerId'] as String,
        id: json['id'] as String,
        itemSkus: List<String>.from(json['itemSkus'] as List),
        placedAt: DateTime.parse(json['placedAt'] as String),
      );

  /* ── Getters & setters ── */
  bool get canShip => isPaid && status == OrderStatus.pending;

  bool get isEmpty => itemSkus.isEmpty;

  int get itemCount => itemSkus.length;

  set coupon(String? value) => couponCode = value?.trim().toUpperCase();

  /* ── Public methods ── */
  bool applyCoupon(String code) {
    if (code.isEmpty || couponCode != null) return false;
    coupon = code;
    return true;
  }

  void markShipped(String tracking) {
    if (!canShip) throw StateError('Order $id cannot ship');
    shippedAt = DateTime.now();
    status = OrderStatus.shipped;
    trackingNumber = tracking;
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'customerId': customerId,
        'id': id,
        'itemSkus': itemSkus,
        'placedAt': placedAt.toIso8601String(),
        'status': status.name,
      };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  /* ── Private methods ── */
  bool _isValidSku(String sku) => RegExp(r'^[A-Z]{3}-\d{4}$').hasMatch(sku);

  void _log(String message) => print('[Order $id] $message');

  /* ── Overrides ── */
  @override
  bool operator ==(Object other) => other is Order && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Order($id, ${status.name}, $total $currencyCode)';
}
```

---

## Reference example — StatefulWidget

```dart
import 'dart:async';

import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.isEditable,
    required this.elevation,
    required this.maxLines,
    required this.title,
    required this.tags,
    required this.padding,
    this.onSaved,
    this.child,
  });

  final bool isEditable;

  final double elevation;

  final int maxLines;

  final String title;

  final List<String> tags;

  final EdgeInsets padding;

  final ValueChanged<String>? onSaved;

  final Widget? child;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> with SingleTickerProviderStateMixin {
  static const int debounceMs = 400;

  static const Duration animationDuration = Duration(milliseconds: 300);

  final FocusNode _focusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textController = TextEditingController();

  late final Animation<double> _fadeAnimation;

  late final AnimationController _animationController;

  bool _isDirty = false;
  bool _isSaving = false;

  int _charCount = 0;

  String _draft = '';
  String? _errorText;

  Timer? _debounce;

  bool get _canSave => _isDirty && !_isSaving && _errorText == null;

  int get _remaining => widget.maxLines * 80 - _charCount;

  void reset() {
    _textController.text = widget.title;
    setState(() {
      _draft = widget.title;
      _errorText = null;
      _isDirty = false;
    });
  }

  Future<void> save() async {
    if (!_canSave) return;
    setState(() => _isSaving = true);
    await Future<void>.delayed(animationDuration);
    widget.onSaved?.call(_draft);
    if (!mounted) return;
    setState(() {
      _isDirty = false;
      _isSaving = false;
    });
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: debounceMs), () {
      setState(() {
        _charCount = _textController.text.length;
        _draft = _textController.text;
        _errorText = _validate(_draft);
        _isDirty = _draft != widget.title;
      });
    });
  }

  String? _validate(String value) => value.trim().isEmpty ? 'Title cannot be empty' : null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: animationDuration, vsync: this);
    _fadeAnimation = CurvedAnimation(curve: Curves.easeIn, parent: _animationController);
    _draft = widget.title;
    _textController.text = _draft;
    _textController.addListener(_onTextChanged);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && !_isDirty) {
      _textController.text = widget.title;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: widget.elevation,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: widget.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(errorText: _errorText, labelText: 'Title'),
                  enabled: widget.isEditable,
                  focusNode: _focusNode,
                  maxLines: widget.maxLines,
                ),
                Wrap(
                  spacing: 8,
                  children: widget.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                Text('$_remaining left'),
                FilledButton(
                  onPressed: _canSave ? save : null,
                  child: Text(_isSaving ? 'Saving…' : 'Save'),
                ),
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```
