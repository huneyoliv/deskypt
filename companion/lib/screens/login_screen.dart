import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/google_sign_in_service.dart';
import '../core/ypt_auth_service.dart';
import '../widgets/social_button.dart';
import 'success_screen.dart';

class LoginScreen extends StatefulWidget {
  final GoogleSignInService? googleSignInService;
  final YptAuthService? yptAuthService;

  const LoginScreen({
    super.key,
    this.googleSignInService,
    this.yptAuthService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GoogleSignInService _googleSignInService;
  late final YptAuthService _yptAuthService;

  bool _isLoading = false;
  String? _loadingMessage;

  @override
  void initState() {
    super.initState();
    _googleSignInService = widget.googleSignInService ?? GoogleSignInService();
    _yptAuthService = widget.yptAuthService ?? YptAuthService();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Autenticando com o Google...';
    });

    try {
      final googleAuth = await _googleSignInService.signIn();

      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Conectando ao Yeolpumta...';
      });

      final yptResult = await _yptAuthService.signInWithGoogle(
        idToken: googleAuth.idToken,
        email: googleAuth.email,
        name: googleAuth.displayName,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SuccessScreen(authResult: yptResult),
        ),
      );
    } on GoogleSignInException catch (e) {
      if (!e.isCancelled && mounted) {
        _showErrorSnackBar(e.message);
      }
    } on YptAuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: CompanionConstants.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CompanionConstants.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: CompanionConstants.primaryOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CompanionConstants.primaryOrange.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/icons/icon_flame.png',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_fire_department,
                      color: CompanionConstants.primaryOrange,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  CompanionConstants.appName,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: CompanionConstants.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Faça login no Yeolpumta pelo celular para sincronizar instantaneamente com o seu computador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: CompanionConstants.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CompanionConstants.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      SocialButton.google(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        isLoading: _isLoading,
                      ),
                      if (_isLoading && _loadingMessage != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          _loadingMessage!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: CompanionConstants.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CompanionConstants.primaryOrange.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CompanionConstants.primaryOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: CompanionConstants.primaryOrange,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ao entrar, este app detectará automaticamente o DeskYPT aberto na mesma rede Wi-Fi e concluirá o login no seu computador.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12.5,
                            color: CompanionConstants.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
