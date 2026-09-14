# Biller

A fast, offline-first Flutter billing application built for the counter of a wholesale wallet and handbag shop. The cashier types a customer name and item lines, taps Print, and hands over a clean A5 receipt, on both Android phones and tablets.

## Project Overview

Biller replaces handwritten bills at a busy wholesale counter, where speed matters more than anything else. It needs no network or backend. Business details, invoice history and printer configuration all live on the device. Receipts go to a WiFi printer through the Android print system or straight to a Bluetooth thermal printer using ESC/POS.

## Key Features

**Counter-Speed Billing**
- Single-screen bill entry with customer name, phone and item lines
- Item entry sheet with quantity, unit price and live line totals
- Advance payment support with automatic balance calculation
- Remove items with undo (the item is reinserted at its original position)
- Screen stays awake while billing, using a wakelock
- All text entry forced to uppercase through an input formatter and keyboard capitalization

**Receipt Generation & Printing**
- Pixel-aligned A5 PDF receipts built with the `pdf` package (header, meta row, items table, totals, terms, signatures, footer)
- Multi-page pagination with dynamic header height calculation
- WiFi / system printing through the Android print framework
- Bluetooth thermal printing with a custom ESC/POS receipt builder (58 mm and 80 mm paper)
- Clear, actionable print outcomes (no printer selected, Bluetooth off, connection failed), so a receipt can always be reprinted

**Draft Recovery**
- In-progress bills auto-saved with a 400 ms debounce
- Restore-or-discard banner when the app reopens with an unfinished bill
- Drafts cleared automatically once a bill is committed

**Invoice History**
- Recent invoices stored in SQLite with a 500-row cap
- Configurable retention period (1 to 365 days) with automatic purging
- Reprint or save a PDF copy of any past invoice
- PDF receipts archived to device storage on every print

**Invoice Numbering**
- Structured invoice numbers in `PREFIX-DEVICE-0001` format
- Per-device letter so multiple counters never issue the same number
- Pending number committed only after a bill is successfully built

**Security**
- One-time, offline device activation: the app only runs on devices the developer has approved (see [Device Activation](#device-activation))
- 4-digit PIN gate protecting the Settings screen
- PINs hashed with salted, iterated SHA-256 (10,000 rounds) and compared in constant time
- One-time recovery code generated at setup for PIN reset
- Credentials held in encrypted secure storage

**Guided Setup & Settings**
- Eight-step onboarding: business name, address, phone numbers, email, terms, numbering, PIN, recovery code
- Structured four-field business address composed for the receipt
- Business logo upload from the gallery
- Editable terms and conditions printed on every receipt
- Printer selection, paper size and print target configuration

**Responsive Layouts**
- Dedicated phone and tablet layouts with a single 600dp width breakpoint
- Tablet layout with a live receipt preview pane beside the billing form

## Architecture Highlights

- Layered structure: `data` (sources and repositories), `features` (controller, view, widgets), `models`, `pdf`, `escpos`, `printing`
- Riverpod `Notifier` / `AsyncNotifier` controllers for predictable state handling
- Provider-based dependency graph for loose coupling between repositories and data sources
- Repository pattern over SharedPreferences, secure storage, SQLite and the file system
- Strict layering rules: widgets never touch repositories, controllers never import `BuildContext`, and the PDF layer never imports Material
- Money represented as integer cents everywhere, formatted only at the edge through one shared LKR formatter
- Hand-written `toJson` / `fromJson` / `copyWith`, with no code generation

## Technical Stack

- **Frontend:** Flutter, Dart 3.8+
- **State Management:** flutter_riverpod
- **Local Storage:** sqflite, shared_preferences, flutter_secure_storage
- **PDF & Printing:** pdf, printing
- **Thermal Printing:** print_bluetooth_thermal, esc_pos_utils_plus
- **Security:** crypto (SHA-256 PIN hashing), ed25519_edwards (activation key signatures)
- **Utilities:** intl, uuid, image_picker, path_provider, package_info_plus, wakelock_plus
- **Typography:** Inter (bundled)

## Core Screens

1. **Activation** - Shown once per device until a valid activation key is entered
2. **Setup** - Step-by-step business onboarding with PIN and recovery code
3. **Billing** - Customer details, item entry, advance and totals, with a live preview on tablets
4. **Preview** - Full A5 receipt preview before printing
5. **Recent Invoices** - Invoice history with reprint and save-a-copy actions
6. **Settings** - PIN-protected business profile, logo, terms, numbering, printer and security

## Device Activation

Biller is shared privately, not published. An APK file can be copied to any phone, so the app locks itself to devices the developer approves. There is no login and no server, and activation works fully offline.

### How it works

1. On first launch the app shows the **Activate Biller** screen with a **device code**, for example `3F2A-9C1B-7D4E-0A55`. The code comes from the phone's Android ID.
2. The user copies the code and sends it to the developer.
3. The developer signs the code with a private Ed25519 key that never leaves their computer, and sends back an **activation key**.
4. The user taps **Paste Key**. The app checks the key against the public key built into the APK and opens.

The key is checked again on every launch. It only works on the device it was made for, so copying the APK or the app's data to another phone does not carry the activation over. The public key inside the APK can check keys but cannot create them, so opening up the APK does not let anyone make their own key.

### One-time setup (developer)

Run this once, from the project root:

```bash
dart run tool/activation.dart keygen
```

This does two things:

- Saves the private key to `%USERPROFILE%\.biller\activation_private_key`.
- Writes the matching public key into `lib/core/licensing/activation_public_key.dart`.

Then rebuild the release APK. An APK built before `keygen` has an empty public key and rejects every activation key.

> **Back up the private key file** somewhere safe, such as a USB drive or private cloud storage. Never commit it or share it. Without it, no new device can be activated. Creating a new key pair would lock out every device already activated, so `keygen` refuses to overwrite an existing key.

### Activating a device

1. Install the release APK on the device and open it.
2. Get the device code shown on the **Activate Biller** screen (the user can tap **Copy Code** and send it on WhatsApp).
3. On the developer's computer, run:

   ```bash
   dart run tool/activation.dart sign 3F2A-9C1B-7D4E-0A55
   ```

   Replace the example with the real device code. Dashes and letter case do not matter.
4. Send the printed **activation key** back. It is about 100 characters, so send it as text the user can copy.
5. On the device, copy the key and tap **Paste Key**. The app activates and continues to Setup, or straight to Billing if the device was already set up.

### Things to know

- **Use the release APK's code.** Android gives each signing key its own Android ID, so a debug build and a release build on the same phone show different device codes. Always keep signing releases with the same keystore.
- **Factory reset or new phone:** the device code changes, so sign the new code.
- **Updating an existing install:** the Activation screen appears once. The business profile, invoice history and settings are kept.
- **`UNAVAILABLE` device code:** the phone did not provide an Android ID, and it cannot be activated.
- **Warning while signing:** if `sign` reports that the public key does not match your private key, the project's `activation_public_key.dart` was changed. Restore it from git before building, or keys will not be accepted.
- **Limits:** this stops casual sharing of the APK. Like any check that runs on the device, a skilled reverse engineer could remove it. Building with `--obfuscate --split-debug-info=<dir>` makes that harder.
