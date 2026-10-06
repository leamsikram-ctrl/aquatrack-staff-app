class ApiConstants {
  // 10.0.2.2 maps to host machine localhost in Android Emulator
  // Can be configured to custom LAN IP or domain
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';

  static const String loginEndpoint = '/auth/login';
  static const String termsEndpoint = '/auth/consent';
  static const String offlineMetersEndpoint = '/meters/offline';
  static const String qrScanEndpoint = '/meters/qr/';
  static const String meterNumberEndpoint = '/meters/';
}

