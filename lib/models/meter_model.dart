class CustomerData {
  final int id;
  final String? accountNumber;
  final String name;
  final String? address;
  final String? barangay;
  final String? mobileNumber;

  CustomerData({
    required this.id,
    this.accountNumber,
    required this.name,
    this.address,
    this.barangay,
    this.mobileNumber,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['id'] as int,
      accountNumber: json['account_number'] as String?,
      name: json['name'] as String? ?? 'Unknown Customer',
      address: json['address'] as String?,
      barangay: json['barangay'] as String?,
      mobileNumber: json['mobile_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_number': accountNumber,
      'name': name,
      'address': address,
      'barangay': barangay,
      'mobile_number': mobileNumber,
    };
  }
}

class MeterData {
  final int meterId;
  final String meterNumber;
  final String qrToken;
  final String status;
  final String? barangay;
  final CustomerData? customer;

  MeterData({
    required this.meterId,
    required this.meterNumber,
    required this.qrToken,
    required this.status,
    this.barangay,
    this.customer,
  });

  factory MeterData.fromJson(Map<String, dynamic> json) {
    return MeterData(
      meterId: json['meter_id'] as int,
      meterNumber: json['meter_number'] as String,
      qrToken: json['qr_token'] as String,
      status: json['status'] as String? ?? 'unassigned',
      barangay: json['barangay'] as String?,
      customer: json['customer'] != null
          ? CustomerData.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meter_id': meterId,
      'meter_number': meterNumber,
      'qr_token': qrToken,
      'status': status,
      'barangay': barangay,
      'customer': customer?.toJson(),
    };
  }
}

