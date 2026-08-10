import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final imageUrl = CdnResolver.studiconUrl(studiconId, pose);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: CachedNetworkImage(
        key: ValueKey(imageUrl),
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/icons/icon.png',
          width: size,
          height: size,
        ),
      ),
    );
  }
}
