# Jesr POS

Jesr — a point of sale (POS) app for Android, built with Flutter.

Offline-first: data is stored locally in SQLite and synced to Firebase
(Firestore) when online. Supports products, cart, checkout, receipts,
barcode scanning, a thermal-printer receipt, and uz / ru / en localization.

## Tech

- Flutter, Riverpod, GoRouter, Clean Architecture
- SQLite (local) + Firebase Auth/Firestore/Storage (cloud)
- Light theme design system (purple accent `#9103E4`, SF Pro Display)

## Getting started

```bash
flutter pub get
flutter run --dart-define-from-file=config.json
```

`config.json` holds API keys (e.g. `REMOVE_BG_API_KEY`) and is gitignored;
see `config.example.json`.
