import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/meter_model.dart';
import 'offline_storage_service.dart';

class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isOffline;

  ApiResult({this.data, this.errorMessage, this.isOffline = false});

  bool get isSuccess => errorMessage == null && data != null;
}

class ApiService {
  String baseUrl = ApiConstants.defaultBaseUrl;

  Future<ApiResult<Map<String, dynamic>>> login(
      String login, String password) async {
    final url = Uri.parse('$baseUrl${ApiConstants.loginEndpoint}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'login': login.trim(),
          'password': password,
          'device_name': 'SIWASS Staff Handheld Scanner',
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = body['token'] as String;
        final user = body['user'] as Map<String, dynamic>;
        final role = user['role'] as String;

        // Staff and Admin accounts only per spec
        if (role != 'staff' && role != 'admin') {
          return ApiResult(
            errorMessage: 'Access restricted: Account role ($role) is not authorized for staff field scanning.',
          );
        }

        await OfflineStorageService.saveToken(token);
        return ApiResult(data: body);
      } else if (response.statusCode == 403) {
        return ApiResult(
          errorMessage: body['message'] as String? ?? 'Forbidden: Inactive account or unauthorized role.',
        );
      } else {
        return ApiResult(
          errorMessage: body['message'] as String? ?? 'Login failed. Check your credentials.',
        );
      }
    } catch (e) {
      return ApiResult(
        errorMessage: 'Network connection failed. Verify server connectivity ($baseUrl).',
      );
    }
  }

  Future<ApiResult<MeterData>> lookupByQrToken(String token) async {
    final authToken = await OfflineStorageService.getToken();
    final url = Uri.parse('$baseUrl${ApiConstants.qrScanEndpoint}$token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final meter = MeterData.fromJson(body['data'] as Map<String, dynamic>);
        return ApiResult(data: meter);
      } else {
        // Fallback to offline cache
        final cached = await OfflineStorageService.findMeterByQrToken(token);
        if (cached != null) {
          return ApiResult(data: cached, isOffline: true);
        }
        return ApiResult(
          errorMessage: 'Meter not found on server or local offline cache for QR token.',
        );
      }
    } catch (_) {
      // Offline fallback
      final cached = await OfflineStorageService.findMeterByQrToken(token);
      if (cached != null) {
        return ApiResult(data: cached, isOffline: true);
      }
      return ApiResult(
        errorMessage: 'Network offline. QR token was not found in the local offline cache.',
        isOffline: true,
      );
    }
  }

  Future<ApiResult<MeterData>> lookupByMeterNumber(String meterNumber) async {
    final authToken = await OfflineStorageService.getToken();
    final url = Uri.parse('$baseUrl${ApiConstants.meterNumberEndpoint}$meterNumber');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final meter = MeterData.fromJson(body['data'] as Map<String, dynamic>);
        return ApiResult(data: meter);
      } else {
        // Fallback to offline cache
        final cached = await OfflineStorageService.findMeterByNumber(meterNumber);
        if (cached != null) {
          return ApiResult(data: cached, isOffline: true);
        }
        return ApiResult(
          errorMessage: 'Meter number "$meterNumber" not found on server or local cache.',
        );
      }
    } catch (_) {
      // Offline fallback
      final cached = await OfflineStorageService.findMeterByNumber(meterNumber);
      if (cached != null) {
        return ApiResult(data: cached, isOffline: true);
      }
      return ApiResult(
        errorMessage: 'Network offline. Meter "$meterNumber" is not in local offline storage.',
        isOffline: true,
      );
    }
  }

  Future<ApiResult<int>> syncOfflineMeters() async {
    final authToken = await OfflineStorageService.getToken();
    final url = Uri.parse('$baseUrl${ApiConstants.offlineMetersEndpoint}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> list = body['data'] as List<dynamic>;
        final meters = list
            .map((item) => MeterData.fromJson(item as Map<String, dynamic>))
            .toList();

        await OfflineStorageService.saveOfflineMeters(meters);
        return ApiResult(data: meters.length);
      } else {
        return ApiResult(
          errorMessage: 'Offline sync failed (HTTP ${response.statusCode}).',
        );
      }
    } catch (e) {
      return ApiResult(
        errorMessage: 'Cannot connect to server to sync offline meters: $e',
      );
    }
  }
}

