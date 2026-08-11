import '../../core/api/api_client.dart';
import '../models/focus_music_track.dart';

class MusicRepository {
  final ApiClient _apiClient;

  MusicRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<FocusMusicTrack>> fetchFocusTracks() async {
    try {
      final response = await _apiClient.get('/music/ranks?type=musicPlay');
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['rs'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => FocusMusicTrack.fromJson(item))
              .where((track) => track.audioUrl.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}

    // Secondary endpoint
    try {
      final response = await _apiClient.get('/musics/recent?page=1&page_size=20');
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['rs'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => FocusMusicTrack.fromJson(item))
              .where((track) => track.audioUrl.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}

    // Faixas oficiais do YPT APK
    return const [
      FocusMusicTrack(
        id: 101,
        title: 'Bossa Nova Foco',
        description: 'Bossa Nova suave para aumentar o ritmo de estudos',
        artist: 'YPT Official',
        durationSeconds: 210,
        audioUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Bossa%20Nova/Bossa%20Nova.mp3',
        coverUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Bossa%20Nova/Bossa%20Nova.png',
      ),
      FocusMusicTrack(
        id: 102,
        title: 'Sunset Beach Lo-Fi',
        description: 'Melodias relaxantes de pôr do sol na praia',
        artist: 'YPT Lo-Fi',
        durationSeconds: 180,
        audioUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Sunset%20beach/Sunset%20beach.mp3',
        coverUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Sunset%20beach/Sunset%20beach.png',
      ),
      FocusMusicTrack(
        id: 103,
        title: 'Calm Piano Composition',
        description: 'Piano acústico suave e meditativo para concentração',
        artist: 'YPT Piano',
        durationSeconds: 240,
        audioUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Calm%20Piano%20Composition/Calm%20Piano%20Composition.mp3',
        coverUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Calm%20Piano%20Composition/Calm%20Piano%20Composition.png',
      ),
      FocusMusicTrack(
        id: 104,
        title: 'Groovy Beats Lo-Fi',
        description: 'Batidas Lo-Fi moderadas para estimular o estudo ativo',
        artist: 'YPT Beats',
        durationSeconds: 195,
        audioUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Groovy%20Beats%20lo-fi/Groovy%20Beats%20lo-fi.mp3',
        coverUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Groovy%20Beats%20lo-fi/Groovy%20Beats%20lo-fi.png',
      ),
      FocusMusicTrack(
        id: 105,
        title: 'Jazz Bar Ambience',
        description: 'Ambiente aconchegante de Jazz Bar para noites de estudo',
        artist: 'YPT Jazz',
        durationSeconds: 260,
        audioUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Jazz%20Bar/Jazz%20Bar.mp3',
        coverUrl: 'https://ypt-ko.oss-ap-northeast-2.aliyuncs.com/music/Jazz%20Bar/Jazz%20Bar.png',
      ),
      FocusMusicTrack(
        id: 106,
        title: 'Chuva e Trovões 🌧️',
        description: 'Ruído branco de tempestade para bloquear barulhos externos',
        artist: 'Ruído Branco',
        durationSeconds: 300,
        audioUrl: 'https://alicdn.pallo.cn/music/rain.mp3',
      ),
      FocusMusicTrack(
        id: 107,
        title: 'Cafeteria & Lofi ☕',
        description: 'Ambiente de cafeteria com murmúrio suave e xícaras',
        artist: 'Ruído Branco',
        durationSeconds: 300,
        audioUrl: 'https://alicdn.pallo.cn/music/lofi.mp3',
      ),
      FocusMusicTrack(
        id: 108,
        title: 'Ondas do Mar 🌊',
        description: 'Som contínuo de ondas para acalmar a mente',
        artist: 'Ruído Branco',
        durationSeconds: 300,
        audioUrl: 'https://alicdn.pallo.cn/music/ocean.mp3',
      ),
    ];
  }
}
