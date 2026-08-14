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
    final safeId = studiconId <= 0 ? -1 : studiconId;
    return '${ApiConstants.mediaCdnUrl}/sc.v2/$safeId/${pose.fileName}';
  }

  static String userAvatarUrl({
    required int userId,
    required bool hasCustomAvatar,
    required int studiconId,
    required bool isStudying,
    bool isPaused = false,
    required int studyMs,
    int dailyGoalMs = 0,
  }) {
    if (hasCustomAvatar) {
      return '${ApiConstants.mediaCdnUrl}/user/profile/$userId.jpg';
    }

    final StudiconPose pose;
    if (isStudying && !isPaused) {
      if (dailyGoalMs > 0 && studyMs >= dailyGoalMs) {
        pose = StudiconPose.fire1;
      } else if (studyMs >= 10800000) {
        pose = StudiconPose.sweat2;
      } else if (studyMs > 7200000) {
        pose = StudiconPose.ignite1;
      } else {
        pose = StudiconPose.sweat1;
      }
    } else if (isPaused) {
      pose = StudiconPose.smoke1;
    } else {
      pose = StudiconPose.normal1;
    }

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
