import 'package:flutter/widgets.dart';

/// Lightweight in-app translations (uz / ru / en).
///
/// Two ways to read a string:
///  * [BuildContext.tr] — reactive; resolves via [Localizations.localeOf] so the
///    widget rebuilds when the app locale changes. Use this inside `build`.
///  * [L10n.trc] — context-free; reads [L10n.currentLanguageCode] (kept in sync
///    by LocaleNotifier). Use this for imperative strings such as snackbars,
///    dialogs and exceptions raised outside the widget tree.
///
/// Interpolated UI strings store only the static label here (e.g. 'Остаток:')
/// and the value is appended at the call site.
class L10n {
  L10n._();

  /// Kept in sync by LocaleNotifier so context-free lookups work.
  static String currentLanguageCode = 'ru';

  static const Map<String, Map<String, String>> _values = {
    // Navigation + tab titles
    'nav_home': {'uz': 'Asosiy', 'ru': 'Главная', 'en': 'Home'},
    'nav_products': {'uz': 'Mahsulotlar', 'ru': 'Товары', 'en': 'Products'},
    'nav_receipts': {'uz': 'Cheklar', 'ru': 'Чеки', 'en': 'Receipts'},
    'nav_profile': {'uz': 'Profil', 'ru': 'Профиль', 'en': 'Profile'},
    'products_title': {'uz': 'Mahsulotlar', 'ru': 'Товары', 'en': 'Products'},
    'receipts_title': {'uz': 'Cheklar', 'ru': 'Чеки', 'en': 'Receipts'},

    // Common
    'common_attention': {'uz': 'Diqqat', 'ru': 'Внимание', 'en': 'Attention'},
    'common_yes': {'uz': 'Ha', 'ru': 'Да', 'en': 'Yes'},
    'common_no': {'uz': 'Yo\'q', 'ru': 'Нет', 'en': 'No'},
    'common_save': {'uz': 'Saqlash', 'ru': 'Сохранить', 'en': 'Save'},
    'common_cancel': {'uz': 'Bekor qilish', 'ru': 'Отмена', 'en': 'Cancel'},
    'common_error': {'uz': 'Xato', 'ru': 'Ошибка', 'en': 'Error'},
    'common_share': {'uz': 'Ulashish', 'ru': 'Поделиться', 'en': 'Share'},
    'common_description': {'uz': 'Tavsif', 'ru': 'Описание', 'en': 'Description'},
    'common_done': {'uz': 'Tayyor', 'ru': 'Готово', 'en': 'Done'},
    'common_back': {'uz': 'Orqaga', 'ru': 'Назад', 'en': 'Back'},
    'common_add': {'uz': 'Qo\'shish', 'ru': 'Добавить', 'en': 'Add'},

    // Empty states
    'empty_products': {'uz': 'Mahsulotlar yo\'q', 'ru': 'Товаров нет', 'en': 'No products'},
    'empty_search_results': {'uz': 'Hech narsa topilmadi', 'ru': 'Ничего не найдено', 'en': 'Nothing found'},
    'empty_products_list': {'uz': 'Mahsulot yo\'q, mahsulot qo\'shing', 'ru': 'Нет товаров, добавьте товар', 'en': 'No products, add a product'},
    'empty_no_description': {'uz': 'Tavsif yo\'q', 'ru': 'Нет описания', 'en': 'No description'},
    'empty_no_specifications': {'uz': 'Xususiyatlar yo\'q', 'ru': 'Нет характеристик', 'en': 'No specifications'},
    'empty_cart_title': {'uz': 'Savat bo\'sh', 'ru': 'Корзина пуста', 'en': 'Cart is empty'},
    'empty_cart_subtitle': {'uz': 'Asosiy ekranda mahsulot qo\'shing', 'ru': 'Добавьте товары на главном экране', 'en': 'Add items on the home screen'},
    'empty_product_not_found': {'uz': 'Mahsulot topilmadi', 'ru': 'Товар не найден', 'en': 'Product not found'},

    // Home
    'home_go_to_cart': {'uz': 'Savatga o\'tish', 'ru': 'Перейти в корзину', 'en': 'Go to cart'},
    'home_online': {'uz': 'Onlayn', 'ru': 'Онлайн', 'en': 'Online'},
    'home_offline': {'uz': 'Oflayn', 'ru': 'Офлайн', 'en': 'Offline'},
    'home_syncing': {'uz': 'Sinxr.', 'ru': 'Синхр.', 'en': 'Syncing'},
    'home_cart_empty': {'uz': 'Savat bo\'sh', 'ru': 'Корзина пуста', 'en': 'Cart is empty'},
    'home_insufficient_funds': {'uz': 'Mablag\' yetarli emas', 'ru': 'Недостаточно средств', 'en': 'Insufficient funds'},

    // Products list / cards
    'products_add_button': {'uz': 'Qo\'shish', 'ru': 'Добавить', 'en': 'Add'},
    'products_search_hint': {'uz': 'Mahsulotlarni izlash', 'ru': 'Поиск товаров', 'en': 'Search products'},
    'products_stock_short': {'uz': 'Qoldiq:', 'ru': 'Ост:', 'en': 'Stock:'},
    'products_stock_remaining': {'uz': 'Qoldiq:', 'ru': 'Остаток:', 'en': 'Stock:'},
    'product_out_of_stock': {'uz': 'Sotuvda yo\'q', 'ru': 'Нет в наличии', 'en': 'Out of stock'},
    'product_per_unit': {'uz': '/dona', 'ru': '/шт', 'en': '/unit'},

    // Product detail
    'product_details_title': {'uz': 'Mahsulot tafsilotlari', 'ru': 'Детали товара', 'en': 'Product Details'},
    'product_edit_button': {'uz': 'Mahsulotni tahrirlash', 'ru': 'Изменить товар', 'en': 'Edit Product'},
    'product_info_section': {'uz': 'Mahsulot haqida ma\'lumot', 'ru': 'Информация о товаре', 'en': 'Product Information'},
    'product_stock_label': {'uz': 'Qoldiq', 'ru': 'Остаток', 'en': 'Stock'},
    'product_sold_label': {'uz': 'Sotilgan', 'ru': 'Продано', 'en': 'Sold'},
    'product_added_label': {'uz': 'Qo\'shilgan', 'ru': 'Добавлено', 'en': 'Added'},
    'product_updated_label': {'uz': 'Oxirgi yangilanish', 'ru': 'Последнее обновление', 'en': 'Last Updated'},
    'product_description_tab': {'uz': 'Tavsif', 'ru': 'Описание', 'en': 'Description'},
    'product_specs_tab': {'uz': 'Xususiyatlar', 'ru': 'Характеристики', 'en': 'Specifications'},
    'product_hide_text': {'uz': 'Yashirish', 'ru': 'Скрыть', 'en': 'Hide'},
    'product_show_more': {'uz': 'Ko\'proq ko\'rsatish', 'ru': 'Показать ещё', 'en': 'Show more'},

    // Product form
    'product_success_added': {'uz': 'Muvaffaqiyatli qo\'shildi!', 'ru': 'Успешно добавлен в систему!', 'en': 'Successfully added to the system!'},
    'product_your_product': {'uz': 'Sizning mahsulotingiz', 'ru': 'Ваш продукт', 'en': 'Your product'},
    'product_success_updated': {'uz': 'Muvaffaqiyatli yangilandi!', 'ru': 'Успешно обновлён!', 'en': 'Successfully updated!'},
    'product_deleted': {'uz': 'Mahsulot o\'chirildi', 'ru': 'Товар удалён', 'en': 'Product deleted'},
    'product_removed_from_system': {'uz': 'Mahsulot tizimdan o\'chirildi', 'ru': 'Продукт удалён из системы', 'en': 'Product removed from the system'},
    'product_confirm_delete': {'uz': 'Bu mahsulotni o\'chirmoqchimisiz?', 'ru': 'Хотите удалить этот товар?', 'en': 'Delete this product?'},
    'product_photo_label': {'uz': 'Mahsulot rasmi', 'ru': 'Фото товара', 'en': 'Product Photo'},
    'product_name_label': {'uz': 'Mahsulot nomi', 'ru': 'Название товара', 'en': 'Product Name'},
    'product_name_hint': {'uz': 'Mahsulotingiz nomi', 'ru': 'Название вашего продукта', 'en': 'Your product name'},
    'product_price_label': {'uz': 'Narx', 'ru': 'Цена', 'en': 'Price'},
    'product_price_hint': {'uz': 'Mahsulot narxi', 'ru': 'Цена товара', 'en': 'Product price'},
    'product_quantity_label': {'uz': 'Soni / Dona', 'ru': 'Кол-во / Шт', 'en': 'Qty / Pcs'},
    'product_quantity_hint': {'uz': 'Miqdori', 'ru': 'Количество', 'en': 'Quantity'},
    'product_barcode_label': {'uz': 'Shtrix-kod', 'ru': 'Штрих-код', 'en': 'Barcode'},
    'product_barcode_hint': {'uz': 'Skanerlang yoki kiriting', 'ru': 'Отсканируйте или введите', 'en': 'Scan or enter'},
    'product_installment_label': {'uz': 'Bo\'lib to\'lash', 'ru': 'В рассрочку', 'en': 'Installment'},
    'product_installment_hint': {'uz': '6 oyga', 'ru': 'на 6 месяцев', 'en': 'for 6 months'},
    'product_specs_label': {'uz': 'Xususiyatlar', 'ru': 'Характеристики', 'en': 'Specifications'},
    'product_specs_hint': {'uz': 'Yozing', 'ru': 'Напишите', 'en': 'Write'},
    'product_description_label': {'uz': 'Mahsulot tavsifi', 'ru': 'Описание товара', 'en': 'Product Description'},
    'product_delete_button': {'uz': 'Mahsulotni o\'chirish', 'ru': 'Удалить товар', 'en': 'Delete Product'},

    // Cart
    'cart_confirm_clear_all': {'uz': 'Barcha mahsulotlarni tozalamoqchimisiz?', 'ru': 'Хотите очистить все товары?', 'en': 'Clear all items?'},
    'cart_title': {'uz': 'Savat', 'ru': 'Корзина', 'en': 'Cart'},
    'cart_returns_section': {'uz': 'Xaridlar bo\'yicha qaytarish', 'ru': 'Возврат по закупам', 'en': 'Returns by Purchase'},
    'cart_items': {'uz': 'Mahsulotlar', 'ru': 'Товары', 'en': 'Items'},
    'cart_total_amount': {'uz': 'Jami to\'lov', 'ru': 'Итого к оплате', 'en': 'Total to Pay'},
    'cart_postpone': {'uz': 'Keyinga qoldirish', 'ru': 'Отложить', 'en': 'Postpone'},
    'cart_checkout': {'uz': 'To\'lov', 'ru': 'Оплата', 'en': 'Payment'},

    // Checkout
    'checkout_received_amount_label': {'uz': 'Qabul qilingan summa', 'ru': 'Полученная сумма', 'en': 'Received Amount'},
    'checkout_amount_hint': {'uz': 'Summani kiriting', 'ru': 'Введите сумму', 'en': 'Enter amount'},
    'checkout_payment_method': {'uz': 'To\'lov usuli', 'ru': 'Способ оплаты', 'en': 'Payment Method'},
    'checkout_cash': {'uz': 'Naqd', 'ru': 'Наличные', 'en': 'Cash'},
    'checkout_customer_name_label': {'uz': 'Mijoz ismi (ixtiyoriy)', 'ru': 'Имя клиента (необязательно)', 'en': 'Customer Name (optional)'},
    'checkout_customer_hint': {'uz': 'Masalan: Akbar', 'ru': 'Напр. Акбар', 'en': 'E.g. Akbar'},
    'checkout_description_label': {'uz': 'Tavsif (ixtiyoriy)', 'ru': 'Описание (необязательно)', 'en': 'Description (optional)'},
    'checkout_description_hint': {'uz': 'Tavsif...', 'ru': 'Описание...', 'en': 'Description...'},
    'checkout_pay_button': {'uz': 'To\'lash', 'ru': 'Оплатить', 'en': 'Pay'},

    // Transactions list
    'transactions_tab_completed': {'uz': 'Cheklar', 'ru': 'Чеки', 'en': 'Receipts'},
    'transactions_tab_postponed': {'uz': 'Keyinga qoldirilgan', 'ru': 'Отложенный', 'en': 'Postponed'},
    'transactions_empty_state': {'uz': 'Hozircha cheklar yo\'q', 'ru': 'Чеков пока нет', 'en': 'No receipts yet'},

    // Transaction card statuses
    'transaction_status_returned': {'uz': 'Qaytarildi', 'ru': 'Возвращен', 'en': 'Returned'},
    'transaction_status_postponed': {'uz': 'Keyinga qoldirilgan', 'ru': 'Отложенный', 'en': 'Postponed'},
    'transaction_status_sold': {'uz': 'Sotildi', 'ru': 'Продан', 'en': 'Sold'},
    'transaction_status_processing': {'uz': 'Jarayonda', 'ru': 'В процессе', 'en': 'Processing'},
    'transaction_card_contact': {'uz': 'Kontakt', 'ru': 'Контакт', 'en': 'Contact'},
    'transaction_card_purchase_amount': {'uz': 'Xarid summasi', 'ru': 'Сумма покупки', 'en': 'Purchase amount'},

    // Receipt detail
    'receipt_not_found': {'uz': 'Chek topilmadi', 'ru': 'Чек не найден', 'en': 'Receipt not found'},
    'payment_failed_title': {'uz': 'To\'lov bajarilmadi', 'ru': 'Оплата не выполнена', 'en': 'Payment failed'},
    'payment_success_title': {'uz': 'To\'lov muvaffaqiyatli o\'tdi', 'ru': 'Оплата прошла успешно', 'en': 'Payment successful'},
    'receipt_detail_number': {'uz': 'Chek raqami', 'ru': 'Номер чека', 'en': 'Receipt number'},
    'receipt_detail_payment_method': {'uz': 'To\'lov usuli', 'ru': 'Способ оплаты', 'en': 'Payment method'},
    'receipt_detail_cashier': {'uz': 'Kassir', 'ru': 'Кассир', 'en': 'Cashier'},
    'receipt_detail_datetime': {'uz': 'Sana va vaqt', 'ru': 'Дата и время', 'en': 'Date and time'},
    'receipt_detail_product_count': {'uz': 'Mahsulotlar soni', 'ru': 'Количество товаров', 'en': 'Product count'},
    'receipt_detail_total_sum': {'uz': 'Yakuniy summa', 'ru': 'Итоговая сумма', 'en': 'Total sum'},
    'receipt_detail_change': {'uz': 'Qaytim', 'ru': 'Сдача', 'en': 'Change'},
    'receipt_detail_received_sum': {'uz': 'Olingan summa', 'ru': 'Полученная сумма', 'en': 'Received sum'},
    'payment_method_cash': {'uz': 'Naqd', 'ru': 'Наличные', 'en': 'Cash'},
    'receipt_share_status': {'uz': 'Holati', 'ru': 'Статус', 'en': 'Status'},
    'receipt_share_date': {'uz': 'Sana', 'ru': 'Дата', 'en': 'Date'},
    'receipt_share_total': {'uz': 'Jami', 'ru': 'Итого', 'en': 'Total'},
    'receipt_share_received': {'uz': 'Olingan', 'ru': 'Получено', 'en': 'Received'},

    // Account / profile
    'account_confirm_sign_out': {'uz': 'Hisobdan chiqmoqchimisiz?', 'ru': 'Хотите выйти из аккаунта?', 'en': 'Sign out?'},
    'account_sign_out': {'uz': 'Chiqish', 'ru': 'Выйти', 'en': 'Sign out'},
    'account_syncing_title': {'uz': 'Sinxronizatsiya ketmoqda', 'ru': 'Идёт синхронизация', 'en': 'Syncing'},
    'account_wait_sync': {'uz': 'Sinxronizatsiya tugashini kuting', 'ru': 'Дождитесь завершения синхронизации', 'en': 'Wait for sync to complete'},
    'account_x_report': {'uz': 'X Hisobot', 'ru': 'X Отчет', 'en': 'X Report'},
    'account_mutual_settlement': {'uz': 'O\'zaro hisob-kitob', 'ru': 'Взаиморасчет', 'en': 'Mutual settlement'},
    'account_currency_exchange': {'uz': 'Valyuta ayirboshlash', 'ru': 'Обмен валюты', 'en': 'Currency exchange'},
    'account_expenses': {'uz': 'Xarajatlar', 'ru': 'Затраты', 'en': 'Expenses'},
    'account_prices': {'uz': 'Narxlar', 'ru': 'Цены', 'en': 'Prices'},
    'account_notifications': {'uz': 'Bildirishnomalar', 'ru': 'Уведомления', 'en': 'Notifications'},
    'account_printer_settings': {'uz': 'Printer sozlamalari', 'ru': 'Настройки принтера', 'en': 'Printer settings'},
    'account_appearance': {'uz': 'Ko\'rinish', 'ru': 'Оформления', 'en': 'Appearance'},
    'account_about_app': {'uz': 'Ilova haqida', 'ru': 'О приложении', 'en': 'About app'},
    'account_no_name': {'uz': 'Nomsiz', 'ru': 'Без имени', 'en': 'No name'},
    'account_branch': {'uz': 'Filial', 'ru': 'Филиал', 'en': 'Branch'},
    'account_cashbox': {'uz': 'Kassa', 'ru': 'Касса', 'en': 'Cashbox'},

    'profile_edit_title': {'uz': 'Ma\'lumotlarni tahrirlash', 'ru': 'Изменить данные', 'en': 'Edit profile'},
    'profile_crop_photo': {'uz': 'Rasmni kesish', 'ru': 'Обрезать фото', 'en': 'Crop Photo'},
    'profile_data_updated': {'uz': 'Ma\'lumotlar yangilandi', 'ru': 'Данные обновлены', 'en': 'Data updated'},
    'profile_name_label': {'uz': 'Ism', 'ru': 'Имя', 'en': 'Name'},
    'profile_name_hint': {'uz': 'Ismingiz', 'ru': 'Ваше имя', 'en': 'Your name'},
    'profile_email_label': {'uz': 'Pochta', 'ru': 'Почта', 'en': 'Email'},
    'profile_email_hint': {'uz': 'Pochtangiz', 'ru': 'Ваша почта', 'en': 'Your email'},
    'profile_phone_label': {'uz': 'Telefon raqami', 'ru': 'Телефон номер', 'en': 'Phone number'},
    'profile_phone_hint': {'uz': 'Telefon raqami', 'ru': 'Номер телефона', 'en': 'Phone number'},
    'profile_branch_hint': {'uz': 'Filial nomi', 'ru': 'Название вашего филиала', 'en': 'Your branch name'},
    'profile_cashbox_hint': {'uz': 'Kassa nomi', 'ru': 'Название кассы', 'en': 'Cashbox name'},

    // Appearance
    'appearance_title': {'uz': 'Ko\'rinish mavzusi', 'ru': 'Тема оформления', 'en': 'Appearance theme'},
    'appearance_saved': {'uz': 'Saqlandi', 'ru': 'Сохранено', 'en': 'Saved'},
    'appearance_settings_updated': {'uz': 'Sozlamalar yangilandi', 'ru': 'Настройки обновлены', 'en': 'Settings updated'},
    'appearance_language_label': {'uz': 'Til', 'ru': 'Язык', 'en': 'Language'},
    'appearance_theme_label': {'uz': 'Mavzu', 'ru': 'Тема оформления', 'en': 'Theme'},
    'appearance_theme_system': {'uz': 'Tizim', 'ru': 'Системный', 'en': 'System'},

    // Printer
    'printer_title': {'uz': 'Printer sozlamalari', 'ru': 'Настройки принтера', 'en': 'Printer settings'},
    'printer_paper_size_label': {'uz': 'Qog\'oz o\'lchami', 'ru': 'Размер бумаги', 'en': 'Paper size'},
    'printer_paper_size_58mm': {'uz': '58 mm', 'ru': '58 мм', 'en': '58 mm'},
    'printer_paper_size_72mm': {'uz': '72 mm', 'ru': '72 мм', 'en': '72 mm'},
    'printer_paper_size_80mm': {'uz': '80 mm', 'ru': '80 мм', 'en': '80 mm'},
    'printer_connection_types_label': {'uz': 'Ulanish turlari', 'ru': 'Типы подключения', 'en': 'Connection types'},
    'printer_connection_types_hint': {'uz': 'Turlarni tanlang', 'ru': 'Выберите типы', 'en': 'Select types'},
    'printer_all_types': {'uz': 'Barcha turlar', 'ru': 'Все типы', 'en': 'All types'},
    'printer_available_devices_header': {'uz': 'Mavjud qurilmalar', 'ru': 'Доступные устройства', 'en': 'Available devices'},
    'printer_scan_button': {'uz': 'Skanerlash', 'ru': 'Сканировать', 'en': 'Scan'},
    'printer_searching_empty_state': {'uz': 'Printerlar qidirilmoqda...', 'ru': 'Поиск принтеров...', 'en': 'Searching for printers...'},
    'printer_not_found_empty_state': {'uz': 'Printerlar topilmadi', 'ru': 'Принтеры не найдены', 'en': 'No printers found'},
    'printer_disconnect_button': {'uz': 'Uzish', 'ru': 'Отключить', 'en': 'Disconnect'},
    'printer_connect_button': {'uz': 'Ulash', 'ru': 'Подключить', 'en': 'Connect'},

    // About
    'about_title': {'uz': 'Ilova haqida', 'ru': 'О приложении', 'en': 'About the app'},
    'about_description_1': {
      'uz': 'Flutter-da ishlab chiqilgan POS ilova (savdo nuqtasi), Toza arxitektura (Clean Architecture) va offline-first yondashuvini namoyish etadi.',
      'ru': 'POS-приложение (точка продаж), разработанное на Flutter и демонстрирующее принципы чистой архитектуры (Clean Architecture) и подход offline-first в проектировании.',
      'en': 'A POS application (point of sale) built with Flutter, demonstrating Clean Architecture principles and an offline-first design approach.',
    },
    'about_description_2': {
      'uz': 'Ushbu loyiha to\'g\'ri arxitektura va mahalliy xotira (SQLite) bilan bulutli baza (Firestore) o\'rtasidagi avtomatik sinxronizatsiyaga ega o\'quv resursi va namunaviy implementatsiya bo\'lib xizmat qiladi.',
      'ru': 'Этот проект служит учебным ресурсом и эталонной реализацией с правильной архитектурой и автоматической синхронизацией данных между локальным хранилищем (SQLite) и облачной базой данных (Firestore).',
      'en': 'This project serves as a learning resource and reference implementation with proper architecture and automatic data synchronization between local storage (SQLite) and a cloud database (Firestore).',
    },
    'about_description_3': {
      'uz': 'Ilova local-first tamoyili bo\'yicha ishlaydi: barcha ma\'lumotlar SQLite-da saqlanadi va internet bo\'lganda Firestore bilan avtomatik sinxronlanadi. Oflayn rejimda foydalanuvchi harakatlari (yaratish, yangilash, o\'chirish) QueuedActions sifatida mahalliy bazaga yoziladi va internet tiklangach navbat bilan bajariladi.',
      'ru': 'Приложение работает по принципу local-first: все данные хранятся в SQLite и автоматически синхронизируются с Firestore при наличии интернет-соединения. В офлайн-режиме все действия пользователя (создание, обновление, удаление) записываются как QueuedActions в локальную базу данных и автоматически выполняются по очереди после восстановления интернет-соединения.',
      'en': 'The app works local-first: all data is stored in SQLite and automatically synced with Firestore when online. Offline, all user actions (create, update, delete) are recorded as QueuedActions in the local database and executed in order once connectivity is restored.',
    },

    // Soon
    'soon_title': {'uz': 'Tez orada', 'ru': 'Скоро будет доступно', 'en': 'Coming soon'},
    'soon_message': {'uz': 'Funksiya tez orada mavjud bo\'ladi. Sabringiz uchun rahmat', 'ru': 'Функция скоро станет доступна. Спасибо за ваше терпение', 'en': 'This feature will be available soon. Thank you for your patience'},

    // Scan
    'scan_title': {'uz': 'Skanerlash', 'ru': 'Сканировать', 'en': 'Scan'},
    'scan_instruction': {'uz': 'Shtrix-kod yoki mahsulotni skanerlang', 'ru': 'Отсканируйте штрих-код или товар', 'en': 'Scan barcode or product'},
    'scan_button': {'uz': 'Skaner', 'ru': 'Сканер', 'en': 'Scanner'},
    'scan_manual_button': {'uz': 'Qo\'lda', 'ru': 'Вручную', 'en': 'Manual'},
    'scan_camera_instruction': {'uz': 'Shtrix-kodni skanerlang', 'ru': 'Просканируйте штрих-код', 'en': 'Scan barcode'},
    'scan_camera_unavailable': {'uz': 'Kamera mavjud emas', 'ru': 'Камера недоступна', 'en': 'Camera unavailable'},
    'scan_camera_permission_message': {'uz': 'Sozlamalarda kameraga ruxsat bering, so\'ng qayta urinib ko\'ring.', 'ru': 'Разрешите доступ к камере в настройках, затем попробуйте снова.', 'en': 'Allow camera access in settings, then try again.'},

    // Auth — sign in
    'auth_sign_in_title': {'uz': 'Avtorizatsiya', 'ru': 'Авторизация', 'en': 'Authorization'},
    'auth_login_label': {'uz': 'Login', 'ru': 'Логин', 'en': 'Login'},
    'auth_password_label': {'uz': 'Parol', 'ru': 'Пароль', 'en': 'Password'},
    'auth_password_hint': {'uz': 'Kiriting', 'ru': 'Введите', 'en': 'Enter'},
    'auth_sign_in_button': {'uz': 'Kirish', 'ru': 'Войти', 'en': 'Sign In'},
    'auth_no_account_text': {'uz': 'Hisobingiz yo\'qmi?', 'ru': 'Нет аккаунта?', 'en': 'Don\'t have an account?'},
    'auth_register_link': {'uz': 'Ro\'yxatdan o\'tish', 'ru': 'Регистрация', 'en': 'Sign Up'},
    'auth_invalid_credentials_error': {'uz': 'Login yoki parol noto\'g\'ri, qayta urinib ko\'ring.', 'ru': 'Неверный логин или пароль, попробуйте ещё раз.', 'en': 'Invalid login or password, please try again.'},

    // Auth — register
    'auth_register_title': {'uz': 'Ma\'lumotlaringizni kiriting', 'ru': 'Введите свои данные', 'en': 'Enter Your Details'},
    'auth_name_label': {'uz': 'Ism', 'ru': 'Имя', 'en': 'Name'},
    'auth_password_hint_long': {'uz': 'Parolni kiriting', 'ru': 'Введите пароль', 'en': 'Enter password'},
    'auth_confirm_password_label': {'uz': 'Parolni tasdiqlang', 'ru': 'Подтвердите пароль', 'en': 'Confirm Password'},
    'auth_repeat_password_hint': {'uz': 'Parolni takrorlang', 'ru': 'Повторите пароль', 'en': 'Repeat password'},
    'auth_enter_name_error': {'uz': 'Ismingizni kiriting', 'ru': 'Введите имя', 'en': 'Please enter your name'},
    'auth_enter_phone_error': {'uz': 'Telefon raqamini kiriting', 'ru': 'Введите номер телефона', 'en': 'Please enter phone number'},
    'auth_password_length_error': {'uz': 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak', 'ru': 'Пароль должен содержать не менее 6 символов', 'en': 'Password must be at least 6 characters'},
    'auth_passwords_mismatch_error': {'uz': 'Parollar mos kelmadi', 'ru': 'Пароли не совпадают', 'en': 'Passwords do not match'},
    'auth_confirm_button': {'uz': 'Tasdiqlash', 'ru': 'Подтвердить', 'en': 'Confirm'},
    'auth_registration_error': {'uz': 'Ro\'yxatdan o\'tib bo\'lmadi. Qayta urinib ko\'ring.', 'ru': 'Не удалось зарегистрироваться. Попробуйте ещё раз.', 'en': 'Failed to register. Please try again.'},

    // Auth — phone
    'auth_phone_number_title': {'uz': 'Telefon raqamingiz', 'ru': 'Ваш номер телефона', 'en': 'Your Phone Number'},
    'auth_confirmation_code_telegram': {'uz': 'Tasdiqlash kodini Telegramingizga yuboramiz', 'ru': 'Мы отправим код подтверждения на ваш Телеграм', 'en': 'We\'ll send a confirmation code to your Telegram'},
    'auth_phone_number_label': {'uz': 'Telefon raqami', 'ru': 'Номер телефона', 'en': 'Phone Number'},
  };

  static String _lookup(String key, String lang) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['ru'] ?? key;
  }

  /// Context-bound lookup (reactive).
  static String of(BuildContext context, String key) {
    return _lookup(key, Localizations.localeOf(context).languageCode);
  }

  /// Context-free lookup (uses [currentLanguageCode]).
  static String trc(String key) => _lookup(key, currentLanguageCode);
}

extension L10nX on BuildContext {
  /// Translate [key] for the current locale. Falls back to Russian, then the key.
  String tr(String key) => L10n.of(this, key);
}
