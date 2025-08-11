import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _locationKey = 'location_enabled';

  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;

  static PreferencesService? _instance;
  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  PreferencesService._();

  /// Initialize preferences service and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _locationEnabled = prefs.getBool(_locationKey) ?? true;

    notifyListeners();
  }

  /// Toggle notification preferences
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  /// Toggle location preferences
  Future<void> setLocationEnabled(bool enabled) async {
    _locationEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, enabled);
  }

  /// Get all preferences as a map for debugging
  Map<String, dynamic> getAllPreferences() {
    return {
      'notifications_enabled': _notificationsEnabled,
      'location_enabled': _locationEnabled,
    };
  }
}
