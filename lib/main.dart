import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/offline_storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/sign_in_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/terms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StaffApp());
}

class StaffApp extends StatefulWidget {
  const StaffApp({super.key});

  @override
  State<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends State<StaffApp> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Widget _initialScreen = const Scaffold();

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
  }

  void _checkInitialAuthState() async {
    final token = await OfflineStorageService.getToken();
    final termsAccepted = await OfflineStorageService.isTermsAccepted();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      if (termsAccepted) {
        _initialScreen = QrScanScreen(apiService: _apiService);
      } else {
        _initialScreen = TermsScreen(apiService: _apiService);
      }
    } else {
      _initialScreen = SignInScreen(apiService: _apiService);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaTrack Staff Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoading
          ? const Scaffold(
              backgroundColor: AppTheme.brandWhite,
              body: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.brandBlue,
                  ),
                ),
              ),
            )
          : _initialScreen,
    );
  }
}
