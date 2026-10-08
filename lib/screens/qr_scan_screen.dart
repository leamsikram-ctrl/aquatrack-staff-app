import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'account_details_screen.dart';
import 'meter_lookup_screen.dart';

class QrScanScreen extends StatefulWidget {
  final ApiService apiService;

  const QrScanScreen({super.key, required this.apiService});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final token = code.trim();
    final result = await widget.apiService.lookupByQrToken(token);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccountDetailsScreen(
            meter: result.data!,
            apiService: widget.apiService,
            isOfflineResult: result.isOffline,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.brandWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x26000000), width: 1),
          ),
          title: const Text(
            'QR Token Not Recognized',
            style: TextStyle(
              fontSize: AppTheme.uniformFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandBlack,
            ),
          ),
          content: Text(
            result.errorMessage ??
                'No water meter matching this token could be located in SIWASS records or offline cache.',
            style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _isProcessing = false;
                });
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _isProcessing = false;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                  ),
                );
              },
              child: const Text('Manual Lookup'),
            ),
          ],
        ),
      );
    }
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandWhite,
      appBar: AppBar(
        title: const Text('METER QR SCANNER'),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: AppTheme.brandBlack,
              size: 18,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle Flashlight',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.brandBlack, size: 18),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                ),
              );
            },
            tooltip: 'Manual Lookup Fallback',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top instructions bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.brandBlueLight,
              child: const Text(
                'Point camera directly at physical SIWASS meter tag QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTheme.uniformFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandBlack,
                ),
              ),
            ),

            // Camera Viewfinder Area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Container(
                        color: AppTheme.brandWhite,
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_off_outlined, size: 40, color: AppTheme.brandBlack),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera feed unavailable or permissions required.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppTheme.uniformFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.brandBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You can use the manual lookup button below for quick browser testing.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppTheme.uniformFontSize,
                                color: AppTheme.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Viewfinder Reticle Overlay
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.brandBlue, width: 2.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Processing Banner
                  if (_isProcessing)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.brandWhite,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Verifying Meter Token...',
                            style: TextStyle(
                              fontSize: AppTheme.uniformFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brandWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Action Drawer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.brandWhite,
                border: Border(
                  top: BorderSide(color: Color(0x1A000000), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.keyboard, size: 14, color: AppTheme.brandBlack),
                    label: const Text('Enter Meter Number Manually (Fallback)'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

