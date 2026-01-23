import 'package:hive_flutter/hive_flutter.dart';

class AppPrefs {
  static const String _boxName = 'prefs';
  static const String _didOnboardKey = 'didOnboard';
  static const String _didShowHomeHintKey = 'didShowHomeHint';
  static const String _didShowCustomerFabHintKey = 'didShowCustomerFabHint';

  static Future<void>? _initFuture;

  static Future<void> init() async {
    _initFuture ??= _doInit();
    await _initFuture;
  }

  static Future<void> _doInit() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box? get _boxOrNull {
    if (!Hive.isBoxOpen(_boxName)) return null;
    return Hive.box(_boxName);
  }

  static bool get didOnboard =>
      (_boxOrNull?.get(_didOnboardKey, defaultValue: false) as bool?) ?? false;

  static Future<void> setDidOnboard(bool value) async {
    await init();
    await Hive.box(_boxName).put(_didOnboardKey, value);
  }

  static bool get didShowHomeHint =>
      (_boxOrNull?.get(_didShowHomeHintKey, defaultValue: false) as bool?) ?? false;

  static Future<void> setDidShowHomeHint(bool value) async {
    await init();
    await Hive.box(_boxName).put(_didShowHomeHintKey, value);
  }

  static bool get didShowCustomerFabHint =>
      (_boxOrNull?.get(_didShowCustomerFabHintKey, defaultValue: false) as bool?) ?? false;

  static Future<void> setDidShowCustomerFabHint(bool value) async {
    await init();
    await Hive.box(_boxName).put(_didShowCustomerFabHintKey, value);
  }
}
