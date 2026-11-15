import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  Locale _locale = const Locale('uz');
  String _userName = '';
  bool _pinEnabled = false;
  String _pinCode = '';
  DateTime? _lastBackup;

  Locale get locale => _locale;
  String get userName => _userName;
  bool get pinEnabled => _pinEnabled;
  DateTime? get lastBackup => _lastBackup;
  bool get isUz => _locale.languageCode != 'ru';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    final code = p.getString('locale') ?? 'uz';
    _locale = Locale(code == 'ru' ? 'ru' : 'uz');
    _userName = p.getString('user_name') ?? '';
    _pinEnabled = p.getBool('pin_enabled') ?? false;
    _pinCode = p.getString('pin_code') ?? '';
    final ms = p.getInt('last_backup');
    _lastBackup = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs?.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    await _prefs?.setString('user_name', _userName);
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    _pinCode = pin;
    _pinEnabled = true;
    await _prefs?.setString('pin_code', pin);
    await _prefs?.setBool('pin_enabled', true);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pinEnabled = false;
    _pinCode = '';
    await _prefs?.setBool('pin_enabled', false);
    await _prefs?.remove('pin_code');
    notifyListeners();
  }

  bool verifyPin(String input) => _pinEnabled && input == _pinCode;

  Future<void> setLastBackup(DateTime time) async {
    _lastBackup = time;
    await _prefs?.setInt('last_backup', time.millisecondsSinceEpoch);
    notifyListeners();
  }
}
