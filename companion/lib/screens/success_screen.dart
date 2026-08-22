import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants.dart';
import '../core/google_sign_in_service.dart';
import '../core/udp_broadcaster.dart';
import '../core/ypt_auth_service.dart';
import 'login_screen.dart';

class SuccessScreen extends StatefulWidget {
  final YptAuthResult authResult;
  final UdpBroadcaster? broadcaster;
  final GoogleSignInService? googleSignInService;

  const SuccessScreen({
    super.key,
    required this.authResult,
    this.broadcaster,
    this.googleSignInService,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final UdpBroadcaster _broadcaster;
  late final GoogleSignInService _googleSignInService;
  StreamSubscription<BroadcasterStatus>? _statusSubscription;
  BroadcasterStatus _status = BroadcasterStatus.idle;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _broadcaster = widget.broadcaster ?? UdpBroadcaster();
    _googleSignInService = widget.googleSignInService ?? GoogleSignInService();

    _status = _broadcaster.currentStatus;
    _statusSubscription = _broadcaster.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });

    _startSync();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _broadcaster.stop();
    if (widget.broadcaster == null) {
      _broadcaster.dispose();
    }
    super.dispose();
  }

  void _startSync() {
    _broadcaster.startBroadcast(
      jwt: widget.authResult.jwt,
      email: widget.authResult.email,
      name: widget.authResult.name,
    );
  }

  Future<void> _copyJwt() async {
    await Clipboard.setData(ClipboardData(text: widget.authResult.jwt));
    if (mounted) {
      setState(() {
        _copied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Token copiado para a área de transferência!',
            style: TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: CompanionConstants.primaryOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  Future<void> _shareJwt() async {
    await Share.share(
      widget.authResult.jwt,
      subject: 'Token de Autenticação DeskYPT',
    );
  }

  Future<void> _handleLogout() async {
    await _broadcaster.stop();
    await _googleSignInService.signOut();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildSyncStatusCard() {
    final isConnected = _status == BroadcasterStatus.connected;
    final isBroadcasting = _status == BroadcasterStatus.broadcasting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isConnected
            ? CompanionConstants.successGreen.withValues(alpha: 0.12)
            : CompanionConstants.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConnected
              ? CompanionConstants.successGreen.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isConnected
                      ? CompanionConstants.successGreen.withValues(alpha: 0.2)
                      : CompanionConstants.primaryOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isConnected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: CompanionConstants.successGreen,
                          size: 26,
                        )
                      : isBroadcasting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  CompanionConstants.primaryOrange,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.wifi_tethering_error_rounded,
                              color: CompanionConstants.textMuted,
                              size: 24,
                            ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? 'DeskYPT Conectado!'
                          : isBroadcasting
                              ? 'Sincronizando com o Desktop...'
                              : 'Busca encerrada',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isConnected
                            ? CompanionConstants.successGreen
                            : CompanionConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isConnected
                          ? 'Sessão enviada com sucesso para o seu PC.'
                          : isBroadcasting
                              ? 'Procurando o DeskYPT aberto na mesma rede Wi-Fi...'
                              : 'Abra a tela de pareamento no DeskYPT ou use o QR Code abaixo.',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.5,
                        color: CompanionConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isConnected && !isBroadcasting) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: _startSync,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Tentar sincronizar novamente',
                  style: TextStyle(fontFamily: 'Pretendard', fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CompanionConstants.primaryOrange,
                  side: const BorderSide(color: CompanionConstants.primaryOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.authResult.name.isNotEmpty
        ? widget.authResult.name
        : 'Estudante YPT';
    final email = widget.authResult.email;

    return Scaffold(
      backgroundColor: CompanionConstants.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sessão Autenticada',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CompanionConstants.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: CompanionConstants.textSecondary),
            tooltip: 'Sair',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CompanionConstants.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: CompanionConstants.primaryOrange,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'Y',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CompanionConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: CompanionConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSyncStatusCard(),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CompanionConstants.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Código de Pareamento QR Code',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CompanionConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aponte a câmera ou use o token para pareamento manual:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12.5,
                        color: CompanionConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: widget.authResult.jwt,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _copyJwt,
                            icon: Icon(
                              _copied ? Icons.check : Icons.copy_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _copied ? 'Copiado!' : 'Copiar Token',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CompanionConstants.primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareJwt,
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text(
                              'Compartilhar',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
