import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../theme/app_theme.dart';
import 'account_details_screen.dart';
import 'meter_lookup_screen.dart';
import 'sign_in_screen.dart';

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
  bool _isSyncing = false;
  String? _lastSynced;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _loadSyncTime();
  }

  void _loadSyncTime() async {
    final time = await OfflineStorageService.getLastSyncedAt();
    if (!mounted) return;
    setState(() {
      if (time != null) {
        final dt = DateTime.parse(time).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        _lastSynced = '${dt.month}/${dt.day} $hour:$min';
      } else {
        _lastSynced = 'Never';
      }
    });
  }

  void _handleSyncNow() async {
    setState(() {
      _isSyncing = true;
    });

    final res = await widget.apiService.syncOfflineMeters();

    if (!mounted) return;
    setState(() {
      _isSyncing = false;
    });

    _loadSyncTime();

    final message = res.isSuccess
        ? 'Synced ${res.data} meters successfully.'
        : (res.errorMessage ?? 'Sync failed.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandWhite),
        ),
        backgroundColor: AppTheme.brandBlack,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout() async {
    // Logout removes the token and the stored list per Section 10.F
    await OfflineStorageService.clearAuth();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SignInScreen(apiService: widget.apiService),
      ),
      (route) => false,
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

    // Trigger haptic vibration and sound on a read per Section 10.C.2
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    setState(() {
      _isProcessing = true;
    });

    // Pause the camera while verifying
    await _scannerController.stop();

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
          _scannerController.start();
          _loadSyncTime();
        }
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.brandWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x26000000), width: 1),
          ),
          title: const Text(
            'Meter not recognized',
            style: TextStyle(
              fontSize: AppTheme.uniformFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandBlack,
            ),
          ),
          content: Text(
            result.errorMessage ?? 'The scanned code does not match any registered meter.',
            style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _isProcessing = false;
                });
                _scannerController.start();
              },
              child: const Text('Try again'),
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
                ).then((_) {
                  if (mounted) {
                    _scannerController.start();
                    _loadSyncTime();
                  }
                });
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
              size: 20,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle Flashlight',
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.brandBlack, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                ),
              ).then((_) => _loadSyncTime());
            },
            tooltip: 'Manual Lookup',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.brandBlack, size: 20),
            onPressed: _handleLogout,
            tooltip: 'Log out',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Sync status & Sync now control bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.brandWhite,
                border: Border(
                  bottom: BorderSide(color: Color(0x1A000000), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_outlined, size: 16, color: AppTheme.brandBlue),
                      const SizedBox(width: 6),
                      Text(
                        'Last sync: ${_lastSynced ?? "Loading..."}',
                        style: const TextStyle(
                          fontSize: AppTheme.uniformFontSize,
                          color: AppTheme.brandBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _isSyncing ? null : _handleSyncNow,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlueLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.brandBlue, width: 1),
                      ),
                      child: Row(
                        children: [
                          if (_isSyncing)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.brandBlue,
                              ),
                            )
                          else
                            const Icon(Icons.refresh, size: 13, color: AppTheme.brandBlue),
                          const SizedBox(width: 4),
                          const Text(
                            'Sync now',
                            style: TextStyle(
                              fontSize: AppTheme.uniformFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brandBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera Viewfinder Area with dark overlay and cutout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cutoutWidth = 240.0;
                  final cutoutHeight = 240.0;
                  final left = (constraints.maxWidth - cutoutWidth) / 2;
                  final top = (constraints.maxHeight - cutoutHeight) / 2;
                  final cutoutRect = Rect.fromLTWH(left, top, cutoutWidth, cutoutHeight);

                  return Stack(
                    fit: StackFit.expand,
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
                                const Icon(Icons.videocam_off_outlined, size: 44, color: AppTheme.brandBlack),
                                const SizedBox(height: 12),
                                const Text(
                                  'Camera Permission Needed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppTheme.uniformFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brandBlack,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Camera access is required to scan water meter QR tags. Please allow camera permissions in app settings, or enter the meter number manually.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppTheme.uniformFontSize,
                                    color: AppTheme.brandBlack,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.keyboard, size: 14),
                                  label: const Text('Enter Meter Number'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                                      ),
                                    ).then((_) => _loadSyncTime());
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Dark overlay with transparent cutout viewfinder
                      CustomPaint(
                        painter: QrOverlayPainter(cutoutRect: cutoutRect),
                      ),

                      // Processing Indicator
                      if (_isProcessing)
                        Center(
                          child: Container(
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
                                  'Identifying meter...',
                                  style: TextStyle(
                                    fontSize: AppTheme.uniformFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brandWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Action Drawer: Manual Entry Button
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
                    icon: const Icon(Icons.keyboard, size: 16, color: AppTheme.brandBlack),
                    label: const Text('Enter Meter Number Manually'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MeterLookupScreen(apiService: widget.apiService),
                        ),
                      ).then((_) => _loadSyncTime());
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

/// Custom painter that draws a dark semi-transparent overlay with a transparent rounded cutout
class QrOverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  final double borderRadius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  QrOverlayPainter({
    required this.cutoutRect,
    this.borderRadius = 16.0,
    this.overlayColor = const Color(0x99000000),
    this.borderColor = AppTheme.brandBlue,
    this.borderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = overlayColor;
    final fullRect = Offset.zero & size;
    final cutoutRRect = RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius));

    // Outer dark mask with cutout hole
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cutoutRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Frame border around the cutout
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(cutoutRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant QrOverlayPainter oldDelegate) {
    return oldDelegate.cutoutRect != cutoutRect;
  }
}
