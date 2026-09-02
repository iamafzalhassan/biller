# Design Reference — Mintly

**Source:** Mintly Invoicing & Budgeting iOS App by Moe Talaat (Behance, July 2026)
**Built with:** React Native, designed in Figma
**Status:** Reference only — captured for consideration, not adopted

> **Accuracy note.** Values below were read off portfolio screenshots at screen
> resolution, not from a published token file. Colours are close approximations,
> spacing is inferred from proportion. Treat everything here as a starting point
> to tune by eye, not as exact values to copy in.

> **Originality note.** This is another designer's published work. Borrow the
> *principles* — paper-toned surfaces, document-like invoice screens, one accent
> colour — not the literal layout. Biller should end up looking like its own app.

---

## 1. Colour

### Surfaces

| Token | Approx. value | Use |
|---|---|---|
| `surfaceBase` | `#FAF8F3` | Screen background — warm off-white, not grey |
| `surfaceCard` | `#FFFDF8` | Cards and list rows, a shade lighter than base |
| `surfaceInverse` | `#1C2B27` | Dark hero/cover panels |
| `divider` | `#E8E3D8` | Hairlines — warm-tinted, never pure grey |

The defining choice is that **nothing is pure white or pure grey**. Every surface
carries a slight cream tint, which makes invoice screens read as paper rather
than as UI. This is the single most transferable idea for a receipt app.

### Brand and accent

| Token | Approx. value | Use |
|---|---|---|
| `primary` | `#1B6B4F` | Deep green — FAB, primary buttons, active tab |
| `primaryOn` | `#FFFFFF` | Text/icons on primary |
| `primarySubtle` | `#E3EFE9` | Selected chip backgrounds, subtle fills |

One accent colour, used sparingly. Green appears on the FAB, the primary CTA,
active navigation, and positive amounts — nowhere else.

### Semantic

| Token | Approx. value | Use |
|---|---|---|
| `danger` | `#C0392B` | Overdue amounts, destructive actions |
| `success` | `#1B6B4F` | Same as primary — paid states |
| `warning` | `#B8860B` | Draft / pending states |
| `neutralChip` | `#EDE9E0` | Inactive status chips |

### Text

| Token | Approx. value | Use |
|---|---|---|
| `textPrimary` | `#1A1A18` | Headings, amounts |
| `textSecondary` | `#6B6B63` | Metadata, labels, dates |
| `textTertiary` | `#9B9B93` | Placeholders, disabled |

---

## 2. Typography

A single sans-serif family throughout (SF Pro on iOS; **Inter** is the closest
free equivalent for Flutter).

| Role | Size | Weight | Notes |
|---|---|---|---|
| Hero amount | 34–40 | 700 | Large balance figures |
| Screen title | 24 | 700 | "Invoices", "Hi, Remal" |
| Section heading | 17 | 600 | "Recent invoices" |
| Body | 15 | 400 | Default |
| List primary | 15 | 600 | Client name, item description |
| List secondary | 13 | 400 | `textSecondary` — dates, invoice numbers |
| Overline label | 11 | 600 | ALL CAPS, letter-spaced ~0.8 — "OUTSTANDING", "CLIENTS" |
| Chip | 11 | 600 | ALL CAPS — "PAID", "DRAFT" |

### Two conventions worth taking

**Uppercase overline labels.** Small, letter-spaced, `textSecondary`, sitting
directly above a large value. Cheap way to add structure without adding weight.
Fits Biller's all-uppercase rule naturally.

**Amounts get the strongest treatment on screen.** Currency figures are always
the heaviest and largest thing in their block. In a billing app the number is
the content; everything else is a label for it.

---

## 3. Spacing and layout

Consistent 4pt base, with an effective 8pt rhythm.

| Token | Value |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `xxl` | 32 |

- **Screen horizontal padding:** 16
- **Card internal padding:** 14–16
- **Gap between cards:** 10–12
- **List row height:** ~56–64 for two-line rows
- **Section spacing:** 24 above a new section heading

### Corner radii

| Element | Radius |
|---|---|
| Cards, list rows | 12 |
| Buttons | 10 |
| Chips / badges | 6 (or fully rounded) |
| FAB | Circular |
| Avatars | Circular |

### Elevation

Almost none. Cards are separated by their tint and a hairline border, not by
shadow. Only the FAB carries a visible drop shadow. This is what keeps the
screens feeling like printed sheets rather than stacked panels.

---

## 4. Components

### Metric card
Two-up grid. Overline label, then large amount, then a one-line caption, with a
small sparkline in the corner. Fixed height so the grid stays even.

### List row
Avatar or initials circle · primary text over secondary text · right-aligned
amount with a status chip below it. Hairline divider between rows, no divider
after the last row.

### Status chip
Small, uppercase, 11pt, filled with a low-saturation tint of its semantic
colour. Never a saturated badge.

### Line-item entry
Plain rows in a bordered block rather than individual cards, with a `+ Add line`
text action directly beneath the last row. Lighter than cards, and fits more
rows above the keyboard — worth considering against Biller's card approach.

### FAB
Circular, `primary` fill, centred in the bottom tab bar, overlapping it. iOS
convention; on Android this would be a standard bottom-right FAB or, for Biller,
no FAB at all since the primary action is a full-width bar.

### Bottom navigation
Four items with a centre FAB. Icon over an 11pt uppercase label. Active item
in `primary`, inactive in `textSecondary`.

---

## 5. Invoice screen conventions

The strongest part of the reference, and the part most relevant to Biller.

- The invoice detail screen uses the **paper surface for the whole screen**, not
  a card floating on a background. The document *is* the screen.
- Meta fields (issue date, due date) sit in a two-column key/value block at the
  top, right-aligned values, hairline dividers between rows.
- The items block is a bordered container with an internal header row, not a
  styled table.
- Totals sit flush right at the bottom, with the final figure separated by a
  slightly heavier rule and set in the largest weight on the screen.
- Terms and footer text in `textSecondary` at 12pt.

---

## 6. What applies to Biller

**Take**
- Warm paper-toned surfaces throughout — the single best idea here
- Uppercase, letter-spaced overline labels (fits the all-caps rule already)
- One accent colour used sparingly
- Near-zero elevation; hairlines and tint instead of shadows
- Amounts as the heaviest element in any block
- Bordered item block with an inline add action, as an alternative to cards

**Adapt**
- Green accent is Mintly's brand, not Biller's. Keep the *approach* — one deep,
  low-saturation accent — and pick a different hue.
- Bottom tab bar and FAB assume a multi-section app. Biller has one screen, so
  the primary action belongs in a sticky bottom bar instead.

**Ignore**
- Dashboards, metric cards, sparklines
- Status chips (paid / overdue / draft) — Biller has no invoice lifecycle
- Client records and avatars — no saved customer list
- Anything implying send-then-collect-later; Biller is pay-at-counter

---

## 7. Draft token file

If this direction is chosen, `core/constants/app_colors.dart` would start
roughly as:

```dart
abstract final class AppColors {
  static const surfaceBase    = Color(0xFFFAF8F3);
  static const surfaceCard    = Color(0xFFFFFDF8);
  static const divider        = Color(0xFFE8E3D8);

  static const primary        = Color(0xFF1B6B4F);  // replace with Biller's hue
  static const primaryOn      = Color(0xFFFFFFFF);
  static const primarySubtle  = Color(0xFFE3EFE9);

  static const danger         = Color(0xFFC0392B);
  static const warning        = Color(0xFFB8860B);

  static const textPrimary    = Color(0xFF1A1A18);
  static const textSecondary  = Color(0xFF6B6B63);
  static const textTertiary   = Color(0xFF9B9B93);
}
```

The PDF layer gets its own reduced palette — paper white, near-black text, one
hairline grey. Screen tints should not carry into print.
