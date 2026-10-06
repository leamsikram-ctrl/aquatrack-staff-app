import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meter_model.dart';

class OfflineStorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyOfflineMeters = 'offline_meters_cache';
  static const String _keyLastSyncedAt = 'last_synced_at';
  static const String _keyTermsAccepted = 'terms_accepted';

  // Token & Auth Persistence
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // Terms Acceptance State
  static Future<void> setTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTermsAccepted, accepted);
  }

  static Future<bool> isTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTermsAccepted) ?? false;
  }

  // Offline Meters Cache
  static Future<void> saveOfflineMeters(List<MeterData> meters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = meters.map((m) => m.toJson()).toList();
    await prefs.setString(_keyOfflineMeters, jsonEncode(jsonList));
    await prefs.setString(_keyLastSyncedAt, DateTime.now().toIso8601String());
  }

  static Future<List<MeterData>> getOfflineMeters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyOfflineMeters);
    if (raw == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => MeterData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSyncedAt);
  }

  // Offline Query Helpers
  static Future<MeterData?> findMeterByQrToken(String token) async {
    final meters = await getOfflineMeters();
    try {
      return meters.firstWhere((m) => m.qrToken == token);
    } catch (_) {
      return null;
    }
  }

  static Future<MeterData?> findMeterByNumber(String meterNumber) async {
    final meters = await getOfflineMeters();
    final cleanInput = meterNumber.trim().toUpperCase();
    try {
      return meters.firstWhere((m) =>
          m.meterNumber.trim().toUpperCase() == cleanInput ||
          (m.customer?.accountNumber?.trim().toUpperCase() == cleanInput));
    } catch (_) {
      return null;
    }
  }
}

