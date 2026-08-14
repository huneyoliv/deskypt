import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/cdn/cdn_resolver.dart';

class StudiconAvatar extends StatelessWidget {
  final int studiconId;
  final StudiconPose pose;
  final double size;

  const StudiconAvatar({
    super.key,
    required this.studiconId,
    this.pose = StudiconPose.normal1,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final primaryUrl = CdnResolver.studiconUrl(studiconId, pose);
    final fallbackUrl = CdnResolver.studiconUrl(-1, pose);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: CachedNetworkImage(
        key: ValueKey(primaryUrl),
        imageUrl: primaryUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          if (studiconId > 0) {
            return CachedNetworkImage(
              key: ValueKey(fallbackUrl),
              imageUrl: fallbackUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Image.asset(
                'assets/icons/icon.png',
                width: size,
                height: size,
              ),
            );
          }
          return Image.asset(
            'assets/icons/icon.png',
            width: size,
            height: size,
          );
        },
      ),
    );
  }
}
