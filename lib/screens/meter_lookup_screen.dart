import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'account_details_screen.dart';

class MeterLookupScreen extends StatefulWidget {
  final ApiService apiService;

  const MeterLookupScreen({super.key, required this.apiService});

  @override
  State<MeterLookupScreen> createState() => _MeterLookupScreenState();
}

class _MeterLookupScreenState extends State<MeterLookupScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _handleLookup() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Please input a meter number or customer account number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.apiService.lookupByMeterNumber(query);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess && result.data != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccountDetailsScreen(
            meter: result.data!,
            apiService: widget.apiService,
            isOfflineResult: result.isOffline,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.errorMessage ??
            'Meter "$query" could not be found in active records or offline cache.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandWhite,
      appBar: AppBar(
        title: const Text('MANUAL METER LOOKUP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.brandBlueLight,
                  border: Border.all(color: const Color(0x26000000), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Hardware Tag Fallback: Use this search when the physical meter QR sticker is weathered, obscured, or damaged.',
                  style: TextStyle(
                    fontSize: AppTheme.uniformFontSize,
                    color: AppTheme.brandBlack,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.brandWhite,
                    border: Border.all(color: AppTheme.brandBlack, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: AppTheme.uniformFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _queryController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: AppTheme.uniformFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandBlack,
                ),
                decoration: const InputDecoration(
                  labelText: 'Meter Number or Account ID',
                  hintText: 'e.g. MTR-SIN-0001 or ACC-2026-0001',
                  prefixIcon: Icon(Icons.confirmation_number_outlined, size: 16, color: AppTheme.brandBlack),
                ),
                onSubmitted: (_) => _handleLookup(),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.brandWhite,
                        ),
                      )
                    : const Icon(Icons.search, size: 16),
                label: const Text('Search Meter Registry'),
                onPressed: _isLoading ? null : _handleLookup,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Quick Test: ', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text('MTR-SIN-0001', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                    backgroundColor: AppTheme.brandWhite,
                    side: const BorderSide(color: Color(0x26000000)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onPressed: () {
                      _queryController.text = 'MTR-SIN-0001';
                      _handleLookup();
                    },
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text('MTR-SIN-0002', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                    backgroundColor: AppTheme.brandWhite,
                    side: const BorderSide(color: Color(0x26000000)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onPressed: () {
                      _queryController.text = 'MTR-SIN-0002';
                      _handleLookup();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sinacaban Utility Quick Reference:',
                      style: TextStyle(
                        fontSize: AppTheme.uniformFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Standard Sinacaban physical meters format: MTR-SIN-####\n'
                      '• Customer account numbers: ACC-YYYY-####\n'
                      '• Lookups will automatically search both online API and local offline cached storage.',
                      style: TextStyle(
                        fontSize: AppTheme.uniformFontSize,
                        color: Color(0x99000000),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

