==============================================================
JESR MOBILE APP POS SYSTEM
==============================================================

ABOUT THE PROJECT
-----------------
Jesr is a point of sale (POS) mobile application for Android. It supports
product management, a shopping cart and checkout, receipts, barcode
scanning, thermal-printer receipt printing, and a trilingual interface
(Uzbek / Russian / English).

The app is offline-first: all data is stored locally on the device first
and is automatically synchronized to the cloud database when an internet
connection is available. While offline, user actions (create, update,
delete) are queued and executed automatically once connectivity is
restored.


REPOSITORY (GITHUB)
-------------------
https://github.com/sobirovjasur/Jesr-POS


PROGRAMMING LANGUAGE
--------------------
- Dart (3.x)


FRAMEWORK AND TECHNOLOGIES
--------------------------
- Flutter ..................... main UI framework (Android)
- Riverpod ................... state management
- GoRouter ................... navigation / routing
- Clean Architecture ......... layered structure (presentation / domain / data)
- Material 3 ................. design system (purple accent #9103E4, SF Pro Display)
- Firebase ................... Authentication (phone + password), Firestore, Storage
- mobile_scanner ............. barcode / QR scanning
- unified_esc_pos_printer .... thermal-printer receipt printing
- image_picker / image_cropper  product images
- share_plus ................. receipt sharing
- connectivity_plus .......... internet status detection
- shared_preferences ......... settings (language selection, etc.)


DATABASE
--------
- Local : SQLite (sqflite) — primary database, for offline operation
- Cloud : Google Firebase Cloud Firestore — for synchronization
- Files : Firebase Storage — for images


KEY FEATURES
------------
- Sign in and registration (phone number + password)
- Home (POS): tap a product to add it to the cart, online/offline status
- Cart: selected vs. returned items, payment, postpone
- Receipts: statuses (Sold / Returned / Postponed), details, sharing
- Products: list, add/edit, barcode scanner
- Profile: edit details, branch / cashbox
- Settings: printer, language (Uzbek / Russian / English), about


GETTING STARTED
---------------
  flutter pub get
  flutter run --dart-define-from-file=config.json
