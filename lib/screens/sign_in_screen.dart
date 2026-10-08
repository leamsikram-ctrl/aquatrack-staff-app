import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../theme/app_theme.dart';
import 'qr_scan_screen.dart';
import 'terms_screen.dart';

class SignInScreen extends StatefulWidget {
  final ApiService apiService;

  const SignInScreen({super.key, required this.apiService});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both your mobile/email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.apiService.login(login, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final termsAccepted = await OfflineStorageService.isTermsAccepted();
      if (!mounted) return;

      if (!termsAccepted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TermsScreen(apiService: widget.apiService),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QrScanScreen(apiService: widget.apiService),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Sign-in failed.';
      });
    }
  }

  void _showServerSettings() {
    final urlController = TextEditingController(text: widget.apiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.brandWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x26000000), width: 1),
        ),
        title: const Text(
          'API Server Connection',
          style: TextStyle(
            fontSize: AppTheme.uniformFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.brandBlack,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set backend endpoint URL for your network:',
              style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
              decoration: const InputDecoration(
                labelText: 'Base URL',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: AppTheme.uniformFontSize, fontWeight: FontWeight.bold, color: AppTheme.brandBlack),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Localhost (localhost:8000)', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                  backgroundColor: AppTheme.brandWhite,
                  side: const BorderSide(color: Color(0x26000000)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () => urlController.text = 'http://localhost:8000/api/v1',
                ),
                ActionChip(
                  label: const Text('Wi-Fi LAN (10.22.83.119)', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                  backgroundColor: AppTheme.brandWhite,
                  side: const BorderSide(color: Color(0x26000000)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () => urlController.text = 'http://10.22.83.119:8000/api/v1',
                ),
                ActionChip(
                  label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack)),
                  backgroundColor: AppTheme.brandWhite,
                  side: const BorderSide(color: Color(0x26000000)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () => urlController.text = 'http://10.0.2.2:8000/api/v1',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              if (newUrl.isNotEmpty) {
                await OfflineStorageService.saveBaseUrl(newUrl);
                setState(() {
                  widget.apiService.baseUrl = newUrl;
                });
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save Endpoint'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brandWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Mark
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.brandBlack, width: 1),
                      ),
                      child: const Center(
                        child: Text(
                          'AT',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AQUATRACK FIELD SCANNER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTheme.uniformFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.brandBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SIWASS Sinacaban Municipal Staff & Technician Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTheme.uniformFontSize,
                      color: Color(0x99000000),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  // Sign-in Fields Card with Hard Shadow
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Staff Authentication',
                          style: TextStyle(
                            fontSize: AppTheme.uniformFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _loginController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number or Email',
                            hintText: 'e.g. 09171234567 or staff@siwass.gov',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: AppTheme.uniformFontSize, color: AppTheme.brandBlack),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.brandWhite,
                                  ),
                                )
                              : const Text('Sign In as Staff'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _loginController.text = 'staff@siwass.gov';
                              _passwordController.text = 'password123';
                              _errorMessage = null;
                            });
                          },
                          child: const Text('Quick Fill Demo Credentials'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _showServerSettings,
                      child: Text(
                        'Configure Server: ${widget.apiService.baseUrl}',
                        style: const TextStyle(
                          fontSize: AppTheme.uniformFontSize,
                          color: Color(0x99000000),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
