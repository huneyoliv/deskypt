import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String? iconAsset;
  final bool isSvg;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset,
    this.isSvg = false,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.isLoading = false,
  });

  factory SocialButton.google({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      key: key,
      label: 'Continuar com o Google',
      onPressed: onPressed,
      iconAsset: 'assets/icons/google_icon.png',
      isSvg: false,
      backgroundColor: Colors.white,
      textColor: const Color(0xFF1F1F1F),
      isLoading: isLoading,
    );
  }

  factory SocialButton.kakao({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      key: key,
      label: 'Continuar com o Kakao',
      onPressed: onPressed,
      iconAsset: 'assets/icons/kakao_icon.png',
      isSvg: false,
      backgroundColor: const Color(0xFFFEE500),
      textColor: const Color(0xFF191919),
      isLoading: isLoading,
    );
  }

  factory SocialButton.naver({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      key: key,
      label: 'Continuar com o Naver',
      onPressed: onPressed,
      iconAsset: 'assets/icons/naver_icon.png',
      isSvg: false,
      backgroundColor: const Color(0xFF03C75A),
      textColor: Colors.white,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: textColor.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.2)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconAsset != null) ...[
                    if (isSvg)
                      SvgPicture.asset(
                        iconAsset!,
                        width: 22,
                        height: 22,
                      )
                    else
                      Image.asset(
                        iconAsset!,
                        width: 22,
                        height: 22,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.login,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
