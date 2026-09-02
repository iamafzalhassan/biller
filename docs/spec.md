# Biller — Wholesale Billing App

**Specification v1.0**
Client: wholesale wallet & handbag shop
Platform: Android (phone + tablet)
Framework: Flutter

---

## 1. Purpose

A single-purpose billing app for a busy wholesale counter. The cashier types a
customer name and a list of items, taps Print, and gets an A5 receipt. A copy is
emailed to the shop owner automatically. No accounts, no cloud sync, no history
archive — speed at the counter is the only goal.

---

## 2. Scope

### In scope
- Manual entry of customer name and line items
- Automatic amount and total calculation
- A5 PDF receipt, multi-page capable
- WiFi printing via Android's system print dialog
- Automatic email of the receipt PDF to the owner
- Last 20 invoices retained for reprint / edit-and-reprint / resend
- Draft autosave and restore
- PIN-protected settings

### Out of scope
- Product catalogue
- Long-term invoice history or reporting
- Tax calculation
- Discounts
- Multi-currency
- Multiple user accounts
- iOS

---

## 3. Business rules

| Rule | Value |
|---|---|
| Currency | LKR, displayed as `Rs. 12,000.00` |
| Decimals | Always 2, never rounded to whole rupees |
| Internal storage | Integer cents, to avoid floating-point drift |
| Tax | None |
| Discount | None — the owner sets prices manually |
| Text casing | ALL UPPERCASE, enforced at input |
| Invoice number | `{prefix}{device}-{seq}` e.g. `INV-A-0042` |
| Sequence increment | On Print tap, regardless of print success |
| Printed copies | One (customer only) |

### Totals

```
Total    = Σ (qty × unitPrice)
Balance  = Total − Advance
```

Advance defaults to 0. Advance and Balance appear on the receipt only when
Advance > 0.

---

## 4. Data model

```dart
class InvoiceItem {
  final String id;
  final String description;   // uppercase
  final num qty;              // allows 0.5 for half-dozen
  final int unitPriceCents;

  int get amountCents => (qty * unitPriceCents).round();
}

class Invoice {
  final String invoiceNumber;
  final DateTime createdAt;
  final String customerName;  // uppercase
  final String? customerPhone;
  final List<InvoiceItem> items;
  final int advanceCents;
  final bool isRevised;
  final int? previousTotalCents;   // set only when isRevised

  int get totalCents => items.fold(0, (s, i) => s + i.amountCents);
  int get balanceCents => totalCents - advanceCents;
}

class BusinessProfile {
  final String name;          // uppercase
  final String address;       // uppercase
  final String phone;
  final String ownerEmail;
  final String termsAndConditions;
  final String invoicePrefix; // e.g. "INV"
  final String deviceId;      // single letter: A, B, C
}
```

### Currency formatting

One formatter, used by both the UI and the PDF, so they can never disagree.

```dart
extension CentsFormatting on int {
  String get asLkr => 'Rs. ${(this / 100).toStringAsFixed(2)}';
}
```

---

## 5. Architecture

Feature-first with a shared core. State via Riverpod.

```
lib/
  core/
    constants/      app_colors.dart, app_spacing.dart, app_text_styles.dart
    extensions/     cents_formatting_ext.dart, context_ext.dart
    formatters/     upper_case_formatter.dart
    responsive/     breakpoints.dart, responsive_builder.dart
    utils/          validators.dart, invoice_number_gen.dart
    result.dart
  models/
    invoice.dart, invoice_item.dart, business_profile.dart
  data/
    repositories/   settings_repository.dart
                    auth_repository.dart
                    recent_invoices_repository.dart
                    draft_repository.dart
                    email_repository.dart
    sources/        prefs_source.dart
                    secure_storage_source.dart
                    sqflite_source.dart
                    email_api_client.dart
  features/
    setup/          view/, controller/
    billing/        view/, view/layouts/, widgets/, controller/
    preview/        view/, controller/
    recent/         view/, widgets/, controller/
    settings/       view/, controller/
  pdf/
    receipt_builder.dart
    pdf_theme.dart
    sections/       header.dart, meta_row.dart, items_table.dart,
                    totals.dart, terms.dart, page_footer.dart
  app/
    app.dart, router.dart, providers.dart
```

### Layering rules

1. Widgets never touch repositories — only controllers.
2. Controllers never import `BuildContext`.
3. The `pdf/` layer never imports `package:flutter/material.dart`.
4. Only `features/*/view/` branches on screen size. Controllers and models are
   layout-agnostic.
5. Consistent member ordering in every class: fields → constructor → getters →
   public methods → private methods.

---

## 6. Screens

### 6.1 Setup wizard

Shown once on first launch. One field per step, large touch targets.

1. Business name
2. Address
3. Phone
4. Owner email
5. Terms & conditions (multiline)
6. Invoice prefix + Device ID letter
7. Set 4-digit PIN
8. **Recovery code shown once** — a generated code that resets the PIN. Instruct
   the user to write it down. There is no other reset path.

### 6.2 Billing screen

The primary screen. Everything else is secondary.

**Elements**
- App bar: invoice number and date (left), Recent icon and lock icon (right)
- Draft restore banner (conditional)
- Customer name (required), customer phone (optional)
- Scrollable item list
- Advance field — collapsed, revealed by an "Add advance" text button
- Sticky bottom bar: Total in large type + full-width **Preview & Print**

**Item row — phone (< 600dp)**

```
┌──────────────────────────────────┐
│ DESCRIPTION                      │
│ [Qty] × [Price] = Rs. 4,500.00 ⊗ │
└──────────────────────────────────┘
```

**Item row — tablet (≥ 600dp)**

Single inline row: description · qty · price · amount · delete.

### 6.3 Preview

Phone only. Full-screen A5 PDF render with **Print** and **Done**.
On tablet the preview is always visible in the right pane, so Print goes
straight to the system dialog.

### 6.4 Recent

Last 20 completed invoices: number · customer · total · time.
Tapping one opens a sheet with **Reprint**, **Edit & Reprint**, **Resend email**.

### 6.5 Settings (PIN-gated)

Business profile, owner email, T&C editor, invoice prefix, device ID,
change PIN.

---

## 7. Keyboard and input behaviour

This is the part that determines whether the app is usable at a busy counter.
Treat it as a first-class requirement, not polish.

### Focus chain
- Description → Qty → Price → **auto-create next row, focus its Description**
- The cashier never taps "Add item". Typing flows continuously.
- Haptic tick on row auto-creation.

### Field configuration

| Field | Keyboard | Action | Formatter |
|---|---|---|---|
| Customer name | text | next | uppercase |
| Customer phone | phone | next | — |
| Description | text | next | uppercase |
| Qty | number, decimal | next | — |
| Price | number, decimal | next | — |
| Advance | number, decimal | done | — |

Set `textCapitalization: TextCapitalization.characters` on uppercase fields so
the on-screen keyboard *shows* caps. Without it the user types lowercase and
watches it transform, which reads as a bug.

### Numeric fields
Select-all on focus, so a mistyped price is overwritten rather than backspaced.

```dart
controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);
```

### Insets and scrolling
- `resizeToAvoidBottomInset: true`
- List padded by `MediaQuery.viewInsets.bottom`
- `Scrollable.ensureVisible` on focus change, 200ms curve
- Total bar floats above the keyboard — the running total is always visible

### Validation — deliberately quiet
- No error state while a field has focus
- On focus-loss: empty description or qty ≤ 0 → thin amber underline only
- No snackbars, no dialogs, no red text mid-typing
- Print button **disabled, not hidden**, until customer name and at least one
  valid row exist
- Tapping a disabled Print → one-line snackbar naming what is missing

### Other counter affordances
- Swipe-left to delete a row, with undo snackbar
- Long-press Total to copy the amount
- `WakelockPlus` enabled while the billing screen is open, disabled on dispose

---

## 8. Responsive layout

Single breakpoint at **600dp width**. Width decides, never orientation — a phone
in landscape keeps the phone layout.

### Phone (< 600dp)
- Single column
- Two-line item cards
- Sticky bottom totals bar
- Preview as a separate route

### Tablet (≥ 600dp)
- Two panes: entry left (~60%), **live PDF preview right (~40%)**
- Single-line item rows
- Totals panel in the right pane, below the preview
- No separate preview route
- Live preview rebuild debounced at 500ms

```
features/billing/view/
  billing_screen.dart          // LayoutBuilder picks a layout
  layouts/
    billing_phone_layout.dart
    billing_tablet_layout.dart
```

Shared widgets: `totals_panel`, `customer_field`, `draft_banner`.
Layout-specific: `item_row_compact`, `item_row_wide`.

---

## 9. PDF receipt

**Page format:** `PdfPageFormat.a5`
**Builder:** `MultiPage` — pagination is built in from the start, not retrofitted.

### Structure

**Every page**
- Business name, address, phone (header)
- Invoice number, date, customer name, customer phone (meta row)
- Items table header row (`repeat: true`)
- Page footer: `Page 1 of 2`, hidden when there is only one page

**Last page only**
- Total
- Advance and Balance, only if advance > 0. Balance in bold.
- Terms & conditions
- Signature line

### Items table

| # | Description | Qty | Price | Amount |
|---|---|---|---|---|

Description wraps to a maximum of 2 lines, ellipsis beyond.
Soft target of ~18 rows per page; let `MultiPage` flow the remainder.

### Revision marker
When `isRevised` is true, print **REVISED** beside the invoice number so a
superseded paper copy cannot be confused with the current one.

### Test case
Generate a 40-item invoice once and verify pagination, repeated headers, and
last-page-only totals.

---

## 10. Email pipeline

### Trigger
On Print tap — before the system print dialog opens.

### Client
1. Build PDF bytes
2. `POST /sendReceipt` with base64 PDF + metadata
3. **Fire-and-forget with a local outbox.** On failure, queue in prefs and retry
   on next app resume. The cashier never waits and never sees an error.

### Cloud Function (Node)
- Provider: Resend or SendGrid
- To: `ownerEmail` from settings
- Subject: `INV-A-0042 · NIMAL TRADERS · Rs. 12,000.00`
- Attachment: the receipt PDF

### Revisions
An edited invoice sends a **second email** with the **same subject line**, so
mail clients thread it with the original. The body leads with:

```
REVISED — this replaces the earlier copy of INV-A-0042.
Previous total: Rs. 14,500.00  →  New total: Rs. 12,000.00
```

The diff line is the point of the email — it lets the owner judge in one glance
whether the change was routine.

### Security
Lock the endpoint with Firebase App Check or a shared secret header. An open
email endpoint will be abused.

---

## 11. State and persistence

| Data | Store | Notes |
|---|---|---|
| Business profile | `shared_preferences` | |
| Invoice sequence | `shared_preferences` | Incremented on Print |
| Admin PIN + recovery code | `flutter_secure_storage` | |
| Draft invoice | `shared_preferences` | Single JSON key, debounced 400ms |
| Recent invoices | `sqflite` | Rolling buffer, newest 20 |
| Email outbox | `shared_preferences` | Retried on app resume |

### Draft restore
On launch, if a non-empty draft exists, show a quiet banner:

> Unsaved bill from 2:14 PM · **Restore** · **Discard**

A banner, not a dialog — a modal blocks the counter. The draft clears on
successful print.

### Recent invoices
Rolling buffer. On insert, delete rows beyond the newest 20. No settings, no
cleanup UI.

**Edit & Reprint** loads the invoice back into the billing screen, keeps the
same invoice number, sets `isRevised = true`, and stores `previousTotalCents`.

---

## 12. Failure handling

| Failure | Behaviour |
|---|---|
| Printer not found / print cancelled | Invoice number is already consumed, email already sent. Recover via Reprint from Recent. Print success never touches app state. |
| Email request fails | Queued in outbox, retried on app resume. Silent to the cashier. |
| App killed mid-bill | Draft restored via banner on next launch. |
| Forgotten PIN | Recovery code from setup. No other path — reinstalling wipes the business profile. |
| Two devices in use | Distinct device letters prevent invoice number collision. |

---

## 13. Build order

1. **Models + total calculation** — pure Dart, unit tested
2. Design tokens + `responsive_builder`
3. Billing screen, phone layout, complete focus chain
4. Tablet layout with live preview pane
5. PDF builder, including multi-page and REVISED marker
6. Draft autosave + restore banner
7. Recent invoices: reprint, edit & reprint, resend
8. Setup wizard, PIN gate, device ID
9. Cloud Function + outbox retry

Steps 1–5 produce a genuinely usable app. 6–9 are hardening.

---

## 14. Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `pdf` | Receipt generation |
| `printing` | System print dialog, A5 |
| `shared_preferences` | Settings, draft, outbox |
| `flutter_secure_storage` | PIN, recovery code |
| `sqflite` | Recent invoices buffer |
| `wakelock_plus` | Keep screen awake while billing |
| `http` or `dio` | Cloud Function client |
| `uuid` | Item IDs |

---

## 15. Open questions for the shop owner

Not blocking, but worth confirming before release:

1. How long are the longest product descriptions? Affects the 2-line wrap cap.
2. Are goods ever delivered rather than collected? A delivery address would need
   its own field on the receipt.
3. Are items ever sold by the dozen rather than the piece? A unit column would
   change the table layout.
4. Should the receipt carry a shop logo? Straightforward in the PDF, but
   settings would need an image picker.
5. Does anything on the receipt need to appear in Sinhala or Tamil? This is a
   font-embedding decision in the PDF layer and is awkward to add later.
