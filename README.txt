==============================================================
  JESR POS
==============================================================

LOYIHA HAQIDA
-------------
Jesr — Android uchun savdo nuqtasi (Point of Sale, POS) mobil ilovasi.
Ilova mahsulotlarni boshqarish, savat va to'lov (kassa), cheklar,
shtrix-kod skaneri, termal printerda chek chop etish hamda uch tilli
interfeys (o'zbekcha / ruscha / inglizcha) imkoniyatlarini o'z ichiga
oladi.

Ilova "offline-first" tamoyilida ishlaydi: barcha ma'lumotlar avval
qurilmaning o'zida saqlanadi va internet mavjud bo'lganda bulutli bazaga
avtomatik sinxronlanadi. Internet bo'lmaganda ham (yaratish, tahrirlash,
o'chirish) amallari navbatga olinadi va aloqa tiklangach bajariladi.


DASTURLASH TILI
---------------
- Dart (3.x)


FRAMEWORK VA TEXNOLOGIYALAR
---------------------------
- Flutter ............. asosiy UI framework (Android)
- Riverpod ........... holatni boshqarish (state management)
- GoRouter ........... navigatsiya / marshrutlash
- Clean Architecture . qatlamli tuzilma (presentation / domain / data)
- Material 3 ......... dizayn tizimi (binafsha aksent #9103E4, SF Pro Display)
- Firebase ........... Authentication (telefon + parol), Firestore, Storage
- mobile_scanner ..... shtrix-kod / QR skaner
- unified_esc_pos_printer . termal printerda chek chop etish
- image_picker / image_cropper . mahsulot rasmlari
- share_plus ......... chekni ulashish
- connectivity_plus .. internet holatini aniqlash
- shared_preferences . sozlamalar (til tanlovi va h.k.)


MA'LUMOTLAR BAZASI
------------------
- Mahalliy (local)  : SQLite (sqflite) — asosiy baza, offline ishlash uchun
- Bulutli (cloud)   : Google Firebase Cloud Firestore — sinxronizatsiya uchun
- Rasm fayllari     : Firebase Storage


ASOSIY IMKONIYATLAR
-------------------
- Tizimga kirish va ro'yxatdan o'tish (telefon raqami + parol)
- Bosh sahifa (POS): mahsulotni bosib savatga qo'shish, online/offline holati
- Savat: tanlangan/qaytariladigan mahsulotlar, to'lov, "Otложить"
- Cheklar: holatlar (Sotildi / Qaytarildi / Keyinga qoldirilgan), tafsilot, ulashish
- Mahsulotlar: ro'yxat, qo'shish/tahrirlash, shtrix-kod skaneri
- Profil: ma'lumotlarni tahrirlash, filial / kassa
- Sozlamalar: printer, til (o'zbekcha/ruscha/inglizcha), ilova haqida


ISHGA TUSHIRISH
---------------
  flutter pub get
  flutter run --dart-define-from-file=config.json

Eslatma: config.json fayli API kalitlarini saqlaydi va repozitoriyga
qo'shilmaydi (gitignore'da). Namuna uchun config.example.json ga qarang.
