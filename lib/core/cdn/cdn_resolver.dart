import '../constants/api_constants.dart';

enum StudiconPose {
  mini('mini.png'),
  normal1('normal1.png'),
  sweat1('sweat1.png'),
  sweat2('sweat2.png'),
  ignite1('ignite1.png'),
  smoke1('smoke1.png'),
  fire1('fire1.png'),
  app('app.png');

  final String fileName;
  const StudiconPose(this.fileName);
}

class CdnResolver {
  CdnResolver._();

  static String studiconUrl(int studiconId, StudiconPose pose) {
    final safeId = studiconId < 0 ? 0 : studiconId;
    return '${ApiConstants.mediaCdnUrl}/sc.v2/$safeId/${pose.fileName}';
  }

  static String userAvatarUrl({
    required int userId,
    required bool hasCustomAvatar,
    required int studiconId,
    required bool isStudying,
    required int studyMs,
  }) {
    if (hasCustomAvatar) {
      return '${ApiConstants.mediaCdnUrl}/user/profile/$userId.jpg';
    }

    final pose = isStudying
        ? (studyMs > 7200000 ? StudiconPose.ignite1 : StudiconPose.sweat1)
        : StudiconPose.normal1;

    return studiconUrl(studiconId, pose);
  }

  static String camStudyUrl(String dateYmd, int userId) {
    return '${ApiConstants.mediaCdnUrl}/cam/$dateYmd/$userId';
  }

  static String chatPhotoUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '${ApiConstants.mediaCdnUrl}$path';
  }

  static String audioUrl(String path) {
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiConstants.audioCdnUrl}/$cleanPath';
  }
}
