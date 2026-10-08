import 'package:flutter/material.dart';
import '../models/meter_model.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../theme/app_theme.dart';

class AccountDetailsScreen extends StatefulWidget {
  final MeterData meter;
  final ApiService apiService;
  final bool isOfflineResult;

  const AccountDetailsScreen({
    super.key,
    required this.meter,
    required this.apiService,
    this.isOfflineResult = false,
  });

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isSyncing = false;
  String? _syncMessage;
  String? _lastSynced;

  @override
  void initState() {
    super.initState();
    _loadSyncTime();
  }

  void _loadSyncTime() async {
    final time = await OfflineStorageService.getLastSyncedAt();
    if (mounted) {
      setState(() {
        _lastSynced = time != null
            ? DateTime.parse(time).toLocal().toString().split('.')[0]
            : 'Never';
      });
    }
  }

  void _handleSyncOfflineDatabase() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    final res = await widget.apiService.syncOfflineMeters();

    if (!mounted) return;

    setState(() {
      _isSyncing = false;
      if (res.isSuccess) {
        _syncMessage = 'Successfully synced ${res.data} meters into offline cache!';
      } else {
        _syncMessage = res.errorMessage ?? 'Sync failed.';
      }
    });

    _loadSyncTime();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.meter;
    final c = m.customer;

    return Scaffold(
      backgroundColor: AppTheme.brandWhite,
      appBar: AppBar(
        title: const Text('METER ACCOUNT DETAILS'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.brandBlack,
                    ),
                  )
                : const Icon(Icons.sync, color: AppTheme.brandBlack, size: 18),
            onPressed: _isSyncing ? null : _handleSyncOfflineDatabase,
            tooltip: 'Sync Offline Cache',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Offline Origin Banner if applicable
              if (widget.isOfflineResult) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.brandBlueLight,
                    border: Border.all(color: AppTheme.brandBlue, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off, size: 16, color: AppTheme.brandBlue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OFFLINE RECORD: Retrieved from local device cache without active cellular signal.',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_syncMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.brandWhite,
                    border: Border.all(color: AppTheme.brandBlack, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _syncMessage!,
                    style: const TextStyle(
                      fontSize: AppTheme.uniformFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandBlack,
                    ),
                  ),
                ),
              ],

              // Meter Hardware Card with Hard Shadow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m.meterNumber,
                          style: const TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: m.status == 'active' ? AppTheme.brandBlue : AppTheme.brandWhite,
                            border: Border.all(color: AppTheme.brandBlack, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: AppTheme.uniformFontSize,
                              fontWeight: FontWeight.bold,
                              color: m.status == 'active' ? AppTheme.brandWhite : AppTheme.brandBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRow('Meter System ID', '#${m.meterId}'),
                    _buildRow('Barangay Jurisdiction', m.barangay ?? 'Sinacaban General'),
                    _buildRow('Encrypted QR Token', '${m.qrToken.substring(0, m.qrToken.length > 20 ? 20 : m.qrToken.length)}...'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Consumer & Service Account Card with Hard Shadow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Linked Consumer Account',
                      style: TextStyle(
                        fontSize: AppTheme.uniformFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (c != null) ...[
                      _buildRow('Account Number', c.accountNumber ?? 'Pending Account Generation'),
                      _buildRow('Customer Name', c.name),
                      _buildRow('Contact Number', c.mobileNumber ?? 'N/A'),
                      _buildRow('Barangay', c.barangay ?? 'Sinacaban'),
                      _buildRow('Service Address', c.address ?? 'Customer Residence'),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.brandBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Unassigned Hardware: This meter is currently available in the Sinacaban inventory. It has not yet been linked to a customer property.',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            color: AppTheme.brandBlack,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Offline Sync Manager Card with Hard Shadow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Offline Cache Status',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                        Text(
                          'Last Synced: ${_lastSynced ?? "..."}',
                          style: const TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            color: Color(0x99000000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cloud_download_outlined, size: 16),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync Full Sinacaban Meter Registry'),
                      onPressed: _isSyncing ? null : _handleSyncOfflineDatabase,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, size: 14),
                label: const Text('Scan Next Meter Tag'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.uniformFontSize,
                fontWeight: FontWeight.bold,
                color: Color(0x99000000),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTheme.uniformFontSize,
                fontWeight: FontWeight.w500,
                color: AppTheme.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

