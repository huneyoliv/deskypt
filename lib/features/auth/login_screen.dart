import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/cdn/cdn_resolver.dart';
import 'auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: '\$3');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() == true) {
      ref.read(authStateProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    int step = 1; // 1: Send Code, 2: Verify Code, 3: Reset Password
    final emailController = TextEditingController(text: _emailController.text);
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              step == 1
                  ? 'Esqueci minha Senha'
                  : step == 2
                      ? 'Digite o Código'
                      : 'Nova Senha',
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (step == 1) ...[
                    const Text(
                      'Insira seu e-mail para receber um código de 6 dígitos de redefinição de senha:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Seu e-mail cadastrado',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ] else if (step == 2) ...[
                    Text(
                      'Enviamos um código de verificação para ${emailController.text}. Digite abaixo:',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, letterSpacing: 6),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '123456',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Crie uma nova senha segura para sua conta:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nova senha',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final authRepo = ref.read(authRepositoryProvider);
                        setState(() {
                          isLoading = true;
                          errorText = null;
                        });

                        try {
                          if (step == 1) {
                            final email = emailController.text.trim();
                            if (email.isEmpty) throw Exception('Digite um e-mail válido');
                            await authRepo.sendPasswordResetCode(email);
                            setState(() {
                              step = 2;
                              isLoading = false;
                            });
                          } else if (step == 2) {
                            final code = codeController.text.trim();
                            if (code.length < 6) throw Exception('Digite o código de 6 dígitos');
                            await authRepo.verifyPasswordResetCode(
                              emailController.text.trim(),
                              code,
                            );
                            setState(() {
                              step = 3;
                              isLoading = false;
                            });
                          } else {
                            final pass = newPasswordController.text.trim();
                            if (pass.length < 6) {
                              throw Exception('A senha deve ter pelo menos 6 caracteres');
                            }
                            await authRepo.resetPassword(
                              email: emailController.text.trim(),
                              password: pass,
                              code: codeController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Senha redefinida com sucesso!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                            errorText = e.toString().replaceAll('Exception: ', '');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        step == 1
                            ? 'Enviar Código'
                            : step == 2
                                ? 'Verificar'
                                : 'Redefinir Senha',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Decorative Branding & Mascot
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF141418),
                    Color(0xFF1E1E26),
                    Color(0xFF2A2A38),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          CdnResolver.studiconUrl(377, StudiconPose.normal1),
                          width: 180,
                          height: 180,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/icons/icon.png',
                            width: 140,
                            height: 140,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'DeskYPT',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontPretendard,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Foco, Disciplina & Comunidade no seu Desktop',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Panel - Login Form
          Expanded(
            flex: 6,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App Logo
                          Image.asset(
                            'assets/icons/splash_logo.png',
                            height: 56,
                            alignment: Alignment.centerLeft,
                            errorBuilder: (_, __, ___) => const Text(
                              'YPT',
                              style: AppTextStyles.displayLarge,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Entrar na sua conta',
                            style: AppTextStyles.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Insira suas credenciais para continuar',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 28),

                          // Error Banner if authentication failed
                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surface,
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: AppColors.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor digite o e-mail';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surface,
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor digite a senha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Submit Button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _submitLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: const [
                              Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('ou entre com', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          OutlinedButton.icon(
                            icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                            label: const Text('Entrar com Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    ref.read(authStateProvider.notifier).signInWithGoogle();
                                  },
                          ),
                          const SizedBox(height: 24),

                          // Social Logins Separator
                          const Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('ou entre com',
                                    style: AppTextStyles.labelSmall),
                              ),
                              Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Buttons Row
                          Row(
                            children: [
                              // Google Login Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () => ref
                                          .read(authStateProvider.notifier)
                                          .signInWithGoogle(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(44),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Image.asset(
                                    'assets/icons/google_icon.png',
                                    height: 20,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.white),
                                  ),
                                  label: const Text(
                                    'Google',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Apple Login Button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () => ref
                                          .read(authStateProvider.notifier)
                                          .signInWithApple(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(44),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: SvgPicture.asset(
                                    'assets/icons/apple_icon.svg',
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                  label: const Text(
                                    'Apple',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
