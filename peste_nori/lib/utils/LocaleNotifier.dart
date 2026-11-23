import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleNotifier extends ValueNotifier<Locale?> {
  LocaleNotifier() : super(null);

  static const _storage = FlutterSecureStorage();
  static const _key = 'APP_LOCALE';

  Future<void> load() async {
    try {
      final code = await _storage.read(key: _key);
      if (code == 'ro' || code == 'en') value = Locale(code!);
    } catch (error) {
      debugPrint('Could not load locale: $error');
    }
  }

  Future<void> select(Locale locale) async {
    await _storage.write(key: _key, value: locale.languageCode);
    value = locale;
  }
}
