import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_translation.dart';
import '../../../core/theme/app_colors.dart';
import '../update_notifier.dart';
import 'update_dialog.dart';

class UpdateButton extends ConsumerStatefulWidget {
  final double size;

  const UpdateButton({
    super.key,
    this.size = 38,
  });

  @override
  ConsumerState<UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends ConsumerState<UpdateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateNotifierProvider);
    final t = ref.watch(appTranslationProvider);

    if (updateState.hasUpdate && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!updateState.hasUpdate && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    if (!updateState.hasUpdate && !updateState.isChecking) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Tooltip(
        message: updateState.hasUpdate
            ? '${t.tr('new_version_available', fallback: 'Nova versão disponível')}: ${updateState.latestRelease?.cleanVersion ?? ''}'
            : t.tr('checking_updates', fallback: 'Verificando atualizações...'),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  if (updateState.latestRelease != null) {
                    UpdateDialog.show(context, updateState.latestRelease!);
                  } else {
                    ref.read(updateNotifierProvider.notifier).checkForUpdates();
                  }
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: updateState.hasUpdate
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.surface,
                    border: Border.all(
                      color: updateState.hasUpdate
                          ? AppColors.success.withValues(alpha: 0.6)
                          : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: updateState.hasUpdate ? _scaleAnimation.value : 1.0,
                          child: child,
                        );
                      },
                      child: Icon(
                        updateState.hasUpdate
                            ? Icons.download_rounded
                            : Icons.sync_rounded,
                        color: updateState.hasUpdate
                            ? AppColors.success
                            : Colors.white70,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (updateState.hasUpdate)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
