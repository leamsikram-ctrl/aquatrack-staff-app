import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_app/models/meter_model.dart';
import 'package:staff_app/services/api_service.dart';
import 'package:staff_app/services/offline_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Mobile Scanner App Slice Acceptance Tests', () {
    test('a scan works with no connection after one login (uses stored list with offline badge)', () async {
      // 1. Simulate meter list downloaded and stored after login
      final storedMeters = [
        MeterData(
          meterId: 101,
          meterNumber: 'MTR-SIN-1001',
          qrToken: 'QR-TAG-SIN-1001',
          status: 'active',
          barangay: 'Poblacion',
          customer: CustomerData(
            id: 201,
            accountNumber: 'ACC-2026-0001',
            name: 'Elena Ramos',
            barangay: 'Poblacion',
            address: 'Poblacion Sector 1, Sinacaban',
            mobileNumber: '09171234567',
          ),
        ),
      ];

      await OfflineStorageService.saveToken('mock_sanctum_token');
      await OfflineStorageService.saveOfflineMeters(storedMeters);

      // Verify stored on device
      expect(await OfflineStorageService.hasOfflineMeters(), isTrue);

      // 2. Perform QR lookup with no connection (pointing to non-existent host)
      final apiService = ApiService()..baseUrl = 'http://127.0.0.1:54321/api/v1';
      final scanResult = await apiService.lookupByQrToken('QR-TAG-SIN-1001');

      // Acceptance: a scan works with no connection after one login
      expect(scanResult.isSuccess, isTrue);
      expect(scanResult.isOffline, isTrue);
      expect(scanResult.data, isNotNull);
      expect(scanResult.data!.meterNumber, equals('MTR-SIN-1001'));
      expect(scanResult.data!.customer?.name, equals('Elena Ramos'));
      expect(scanResult.data!.customer?.barangay, equals('Poblacion'));
      expect(scanResult.data!.customer?.address, equals('Poblacion Sector 1, Sinacaban'));

      // 3. Perform manual number lookup with no connection
      final manualResult = await apiService.lookupByMeterNumber('MTR-SIN-1001');
      expect(manualResult.isSuccess, isTrue);
      expect(manualResult.isOffline, isTrue);
      expect(manualResult.data!.meterNumber, equals('MTR-SIN-1001'));
    });

    test('a wrong code shows "Meter not recognized"', () async {
      // Store some valid meters
      await OfflineStorageService.saveOfflineMeters([
        MeterData(
          meterId: 101,
          meterNumber: 'MTR-SIN-1001',
          qrToken: 'QR-VALID-1001',
          status: 'active',
        ),
      ]);

      final apiService = ApiService()..baseUrl = 'http://127.0.0.1:54321/api/v1';

      // Scan wrong/invalid QR code
      final wrongQrResult = await apiService.lookupByQrToken('QR-INVALID-9999');
      expect(wrongQrResult.isSuccess, isFalse);
      expect(wrongQrResult.errorMessage, equals('Meter not recognized'));

      // Enter wrong/invalid manual meter number
      final wrongNumberResult = await apiService.lookupByMeterNumber('MTR-UNKNOWN-8888');
      expect(wrongNumberResult.isSuccess, isFalse);
      expect(wrongNumberResult.errorMessage, equals('Meter not recognized'));
    });

    test('shows message if nothing is stored yet on first offline attempt', () async {
      // Cache is completely empty
      expect(await OfflineStorageService.hasOfflineMeters(), isFalse);

      final apiService = ApiService()..baseUrl = 'http://127.0.0.1:54321/api/v1';
      final result = await apiService.lookupByQrToken('ANY-QR');

      expect(result.isSuccess, isFalse);
      expect(
        result.errorMessage,
        equals('No meters stored on device. Connect to the internet once to sync the meter list.'),
      );
    });

    test('logout removes the token and the stored list', () async {
      await OfflineStorageService.saveToken('active_token');
      await OfflineStorageService.saveOfflineMeters([
        MeterData(
          meterId: 1,
          meterNumber: 'MTR-001',
          qrToken: 'QR-001',
          status: 'active',
        ),
      ]);
      await OfflineStorageService.setTermsAccepted(true);

      expect(await OfflineStorageService.getToken(), isNotNull);
      expect(await OfflineStorageService.hasOfflineMeters(), isTrue);
      expect(await OfflineStorageService.getLastSyncedAt(), isNotNull);

      // Perform logout
      await OfflineStorageService.clearAuth();

      // Token and stored list must be completely removed
      expect(await OfflineStorageService.getToken(), isNull);
      expect(await OfflineStorageService.hasOfflineMeters(), isFalse);
      expect(await OfflineStorageService.getOfflineMeters(), isEmpty);
      expect(await OfflineStorageService.getLastSyncedAt(), isNull);
    });

    test('no task, reading, or photo feature exists in the app codebase', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync().toLowerCase();

        // Tasks / work orders must not exist
        expect(
          content.contains('task_list') ||
              content.contains('myservicerequests') ||
              content.contains('startwork') ||
              content.contains('completerepair'),
          isFalse,
          reason: 'File ${file.path} must not contain task workflow actions',
        );

        // Meter readings (dial readings, consumption) must not exist
        expect(
          content.contains('dialreading') ||
              content.contains('logreading') ||
              content.contains('consumption_m3') ||
              content.contains('previous_reading'),
          isFalse,
          reason: 'File ${file.path} must not contain meter reading logic',
        );

        // Photo capture/upload must not exist
        expect(
          content.contains('image_picker') ||
              content.contains('takephoto') ||
              content.contains('evidencephoto'),
          isFalse,
          reason: 'File ${file.path} must not contain photo capture features',
        );

        // Terminology: customer, never consumer
        expect(
          content.contains('consumer'),
          isFalse,
          reason: 'File ${file.path} must use "customer" and never "consumer"',
        );
      }
    });
  });
}

