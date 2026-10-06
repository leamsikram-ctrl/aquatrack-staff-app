import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../theme/app_theme.dart';
import 'qr_scan_screen.dart';

class TermsScreen extends StatefulWidget {
  final ApiService apiService;

  const TermsScreen({super.key, required this.apiService});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  void _handleAccept() async {
    if (!_accepted) return;

    await OfflineStorageService.setTermsAccepted(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QrScanScreen(apiService: widget.apiService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandWhite,
      appBar: AppBar(
        title: const Text('STAFF OPERATIONAL TERMS & CONSENT'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.brandBlueLight,
                  border: Border.all(color: const Color(0x33000000), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SIWASS Municipal Utility · Statutory Field Service Agreement (v1.0)',
                  style: TextStyle(
                    fontSize: AppTheme.uniformFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandBlack,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.brandWhite,
                    border: Border.all(color: const Color(0x26000000), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Purpose of the Application',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'This handheld scanning tool is issued exclusively to authorized SIWASS Sinacaban municipal technicians and administrative staff. It is designed solely for inspecting meter installations, validating encrypted QR tokens, and conducting offline account verification in the field.',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            color: AppTheme.brandBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '2. Data Privacy & Customer Confidentiality',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Customer personal data, mobile numbers, service coordinates, and billing statements accessed via this app are strictly confidential under the Philippine Data Privacy Act of 2012. Personnel must never disclose or store consumer information outside the official system.',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            color: AppTheme.brandBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '3. Physical Meter Tag Integrity',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Meters are tagged with secure cryptographically generated QR tokens. If a physical tag is compromised, damaged, or unreadable, staff must utilize the manual lookup fallback and report the tag for re-tagging.',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            color: AppTheme.brandBlack,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  setState(() {
                    _accepted = !_accepted;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _accepted,
                      activeColor: AppTheme.brandBlue,
                      checkColor: AppTheme.brandWhite,
                      onChanged: (val) {
                        setState(() {
                          _accepted = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I accept the SIWASS Staff Field Service Terms and Privacy Obligations (v1.0)',
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _accepted ? _handleAccept : null,
                child: const Text('Proceed to Meter Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

