import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/models/meter_model.dart';

void main() {
  group('MeterData JSON Deserialization', () {
    test('parses active meter with assigned customer correctly', () {
      final json = {
        'meter_id': 101,
        'meter_number': 'MTR-SIN-0042',
        'qr_token': 'b1c3e4f5-9988-7766-5544-33221100aabb',
        'status': 'active',
        'barangay': 'Poblacion',
        'customer': {
          'id': 15,
          'account_number': 'ACC-2026-0042',
          'name': 'Maria Santos',
          'address': 'Purok 2, Near Public Market',
          'barangay': 'Poblacion',
          'mobile_number': '09171234567',
        },
      };

      final meter = MeterData.fromJson(json);

      expect(meter.meterId, equals(101));
      expect(meter.meterNumber, equals('MTR-SIN-0042'));
      expect(meter.qrToken, equals('b1c3e4f5-9988-7766-5544-33221100aabb'));
      expect(meter.status, equals('active'));
      expect(meter.barangay, equals('Poblacion'));

      expect(meter.customer, isNotNull);
      expect(meter.customer!.id, equals(15));
      expect(meter.customer!.accountNumber, equals('ACC-2026-0042'));
      expect(meter.customer!.name, equals('Maria Santos'));
      expect(meter.customer!.mobileNumber, equals('09171234567'));
      expect(meter.customer!.address, equals('Purok 2, Near Public Market'));
    });

    test('parses unassigned inventory meter with null customer', () {
      final json = {
        'meter_id': 202,
        'meter_number': 'MTR-SIN-0099',
        'qr_token': 'c2d3e4f5-1122-3344-5566-77889900aabb',
        'status': 'unassigned',
        'barangay': 'San Isidro',
        'customer': null,
      };

      final meter = MeterData.fromJson(json);

      expect(meter.meterId, equals(202));
      expect(meter.meterNumber, equals('MTR-SIN-0099'));
      expect(meter.status, equals('unassigned'));
      expect(meter.customer, isNull);
    });

    test('serializes back to JSON preserving fields', () {
      final customer = CustomerData(
        id: 7,
        accountNumber: 'ACC-2026-0007',
        name: 'Pedro Cruz',
        barangay: 'San Jose',
        address: 'Sitio Riverside',
        mobileNumber: '09189998877',
      );

      final meter = MeterData(
        meterId: 55,
        meterNumber: 'MTR-SIN-0055',
        qrToken: 'test-token-1234',
        status: 'active',
        barangay: 'San Jose',
        customer: customer,
      );

      final map = meter.toJson();
      expect(map['meter_id'], equals(55));
      expect(map['meter_number'], equals('MTR-SIN-0055'));
      expect(map['customer']['name'], equals('Pedro Cruz'));
    });
  });
}

