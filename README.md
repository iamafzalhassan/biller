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
- **Security:** crypto (SHA-256 PIN hashing)
- **Utilities:** intl, uuid, image_picker, path_provider, package_info_plus, wakelock_plus
- **Typography:** Inter (bundled)

## Core Screens

1. **Setup** - Step-by-step business onboarding with PIN and recovery code
2. **Billing** - Customer details, item entry, advance and totals, with a live preview on tablets
3. **Preview** - Full A5 receipt preview before printing
4. **Recent Invoices** - Invoice history with reprint and save-a-copy actions
5. **Settings** - PIN-protected business profile, logo, terms, numbering, printer and security
