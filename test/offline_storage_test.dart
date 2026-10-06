import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_app/models/meter_model.dart';
import 'package:staff_app/services/offline_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineStorageService', () {
    test('persists and retrieves auth token', () async {
      expect(await OfflineStorageService.getToken(), isNull);

      await OfflineStorageService.saveToken('test_sanctum_token_123');
      expect(await OfflineStorageService.getToken(), equals('test_sanctum_token_123'));

      await OfflineStorageService.clearAuth();
      expect(await OfflineStorageService.getToken(), isNull);
    });

    test('persists terms acceptance state', () async {
      expect(await OfflineStorageService.isTermsAccepted(), isFalse);

      await OfflineStorageService.setTermsAccepted(true);
      expect(await OfflineStorageService.isTermsAccepted(), isTrue);
    });

    test('caches meters and resolves offline lookups by QR token and meter number', () async {
      final meters = [
        MeterData(
          meterId: 1,
          meterNumber: 'MTR-SIN-0001',
          qrToken: 'qr-uuid-001',
          status: 'active',
          barangay: 'Poblacion',
          customer: CustomerData(
            id: 10,
            accountNumber: 'ACC-2026-0010',
            name: 'Juan Dela Cruz',
            address: 'Poblacion Proper',
          ),
        ),
        MeterData(
          meterId: 2,
          meterNumber: 'MTR-SIN-0002',
          qrToken: 'qr-uuid-002',
          status: 'unassigned',
          barangay: 'San Isidro',
        ),
      ];

      await OfflineStorageService.saveOfflineMeters(meters);

      // Verify list retrieval
      final cachedList = await OfflineStorageService.getOfflineMeters();
      expect(cachedList.length, equals(2));

      // Verify QR token lookup
      final foundByQr = await OfflineStorageService.findMeterByQrToken('qr-uuid-001');
      expect(foundByQr, isNotNull);
      expect(foundByQr!.meterNumber, equals('MTR-SIN-0001'));
      expect(foundByQr.customer?.name, equals('Juan Dela Cruz'));

      // Verify manual meter number lookup
      final foundByNum = await OfflineStorageService.findMeterByNumber('MTR-SIN-0002');
      expect(foundByNum, isNotNull);
      expect(foundByNum!.qrToken, equals('qr-uuid-002'));
      expect(foundByNum.status, equals('unassigned'));

      // Verify manual lookup by account number
      final foundByAcc = await OfflineStorageService.findMeterByNumber('ACC-2026-0010');
      expect(foundByAcc, isNotNull);
      expect(foundByAcc!.meterNumber, equals('MTR-SIN-0001'));

      // Non-existent lookup returns null
      final notFound = await OfflineStorageService.findMeterByNumber('MTR-NONEXISTENT');
      expect(notFound, isNull);
    });
  });
}

