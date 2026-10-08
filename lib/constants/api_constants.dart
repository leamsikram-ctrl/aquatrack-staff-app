import 'package:flutter/foundation.dart';

class ApiConstants {
  // 10.0.2.2 maps to host machine localhost in Android Emulator
  // localhost maps to host machine in Web / Desktop browser
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String webBaseUrl = 'http://localhost:8000/api/v1';

  static String get defaultBaseUrl => kIsWeb ? webBaseUrl : emulatorBaseUrl;

  static const String loginEndpoint = '/auth/login';
  static const String termsEndpoint = '/auth/consent';
  static const String offlineMetersEndpoint = '/meters/offline';
  static const String qrScanEndpoint = '/meters/qr/';
  static const String meterNumberEndpoint = '/meters/';
}

