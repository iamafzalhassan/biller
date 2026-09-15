# Biller

![Flutter](https://img.shields.io/badge/Flutter-3.32%2B-02569B?logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6-00A6A6)
![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?logo=sqlite&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)

An offline billing app for the counter of a wholesale wallet and handbag shop, built with Flutter for Android phones and tablets. The cashier types a customer name and the item lines, taps Print, and hands over a clean A5 receipt.

Biller needs no network and no backend. The business profile, invoice history and printer setup all live on the device. Receipts go to a WiFi printer through the Android print system, or straight to a Bluetooth thermal printer over ESC/POS.

## Features

- **Counter-speed billing**: one screen for the customer name, phone and item lines, with quantity, unit price and live line totals. The screen stays awake while billing, and all text is entered in uppercase.
- **Advance payments** with the balance calculated automatically.
- **Undo on remove**: a removed item line can be restored to its original position from the snackbar.
- **A5 PDF receipts** with a header, meta row, items table, totals, terms, signatures and footer, paginated across as many pages as the items need.
- **WiFi printing** through the Android print framework.
- **Bluetooth thermal printing** on 58 mm or 80 mm paper, using a custom ESC/POS receipt builder.
- **Clear print outcomes**: no printer selected, Bluetooth off or a failed connection each explain what to do next, and every receipt can be reprinted.
- **Draft recovery**: an unfinished bill is saved as you type and offered back when the app reopens.
- **Invoice history** of up to 500 recent invoices, purged after a configurable 1 to 365 days, with reprint and save-a-copy actions. Every printed receipt is also archived as a PDF.
- **Structured invoice numbers** in `PREFIX-DEVICE-0001` form, with a letter per device so several counters never issue the same number.
- **Guided setup** in eight steps: business name, address, phone numbers, email, terms, numbering, PIN and recovery code.
- **Settings behind a PIN**, including the business logo, printed terms, numbering, printer, paper size and history retention.
- **Phone and tablet layouts**, with a live receipt preview beside the billing form on tablets.
- **Offline device activation**, so a copied APK does not run on an unapproved phone.

## Architecture

- **Layered by responsibility.** `data` holds sources and repositories, `features` holds a controller, view and widgets per screen, and `models`, `pdf`, `escpos` and `printing` stay independent of each other.
- **Riverpod controllers.** Each screen is driven by a `Notifier` or `AsyncNotifier`, and repositories and sources are wired through providers.
- **Layering rules.** Widgets never touch repositories, controllers never import `BuildContext`, and the PDF layer never imports Material.
- **One responsive breakpoint.** Only the view layer branches on screen size, at a single 600 dp width.
- **No code generation.** `toJson`, `fromJson` and `copyWith` are written by hand.

## How the money works

- **Money is integer cents.** Every amount is an `int` count of cents, never a `double`, from item lines to totals, advance and balance.
- **One formatter at the edge.** The same `#,##0.00` formatter produces every amount on screen, in the PDF and on the thermal receipt, so they can never disagree.
- **Totals are derived.** The total, advance line and balance are computed from the items each time, never stored separately.

## How printing works

1. **The number is consumed only after the PDF builds.** The invoice is stamped with the pending number and built first; the sequence advances, the invoice is saved to history and the draft is cleared only once that succeeds, so a failed build never skips a number.
2. **The PDF is paginated by measurement.** The receipt builder works out how many rows fit on each page and on the last page, which also carries the totals, terms and signatures.
3. **The dispatcher picks a route.** WiFi sends the PDF to the Android print system; thermal builds ESC/POS bytes and sends them to the paired printer.
4. **Thermal layout is character-exact.** Text is wrapped to the 32 or 48 characters a line holds on 58 mm or 80 mm paper, with item descriptions indented under their line number.
5. **Every outcome is explicit.** Sent, cancelled, no printer, Bluetooth unavailable, connection failed and build failed each map to a message, so the cashier always knows whether to reprint.

## Security

- **Device activation.** On first launch the app shows a device code derived from the Android ID. The developer signs it with an Ed25519 private key that never leaves their computer, and the app verifies the key against the public key built into the APK on every launch. A key only works on the device it was made for.
- **PIN protection.** The Settings PIN and the one-time recovery code are hashed with a random 16-byte salt and 10,000 rounds of SHA-256, compared in constant time, and kept in encrypted secure storage.
- **Limits.** Like any on-device check, activation stops casual sharing of the APK rather than a determined reverse engineer.

## Tech stack

| Area | Choice |
|---|---|
| Language | Dart 3.8 |
| UI | Flutter, Material 3, Inter |
| State | flutter_riverpod |
| Storage | sqflite, shared_preferences, flutter_secure_storage |
| PDF and printing | pdf, printing |
| Thermal printing | esc_pos_utils_plus, print_bluetooth_thermal |
| Security | crypto, ed25519_edwards |
| Utilities | intl, uuid, image_picker, path_provider, package_info_plus, wakelock_plus |

## Design system

Biller shares one design system with two other apps of mine: warm paper surfaces, navy ink, and a dotted divider as the signature motif. Colours, spacing and text styles are tokens in `core/constants`, every amount uses tabular figures so columns line up, and shared widgets (`AppTextField`, `SectionHeader`, `SheetFrame`, `DottedDivider`, `PinBoxes`, `CodeBox`) live in `core/widgets`. Screens never use a raw colour or a bare measurement.

## Code conventions

- A strict member ordering convention for every class: fields sorted by type tier, then type, then name; methods ordered by call order.
- No comments in source. Names, types and ordering carry the meaning.
- `dart format` at a 240-column page width.

## Project structure

```
lib/
    main.dart
    app/            App, theme, providers, routes
    core/           Constants, formatters, licensing, responsive helpers, utils, shared widgets
    data/           Repositories and sources (SQLite, preferences, secure storage, files, Bluetooth)
    escpos/         ThermalReceiptBuilder
    features/       activation, billing, preview, recent, settings, setup
    models/         BusinessProfile, Invoice, InvoiceItem, PrinterSettings, ThermalPaper
    pdf/            Receipt builder and its sections
    printing/       PrintDispatcher, PrintOutcome, SystemPrintService
tool/
    activation.dart Key generation and device signing
```

## Building

**Requirements:** Flutter 3.32 or later and the Android SDK.

1. Generate the activation key pair once from the project root with `dart run tool/activation.dart keygen`. This writes the public key into `lib/core/licensing/activation_public_key.dart` and keeps the private key in your home folder.
2. Run with `flutter run`, or build a release with `flutter build apk --release`.
3. To activate a device, run `dart run tool/activation.dart sign <device code>` and enter the printed key in the app.

Back up the private key. Without it no new device can be activated, and generating a new pair locks out every device already activated.

## Roadmap

- Email a copy of each receipt to the owner address collected during setup
- Export invoice history
