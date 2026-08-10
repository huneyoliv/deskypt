import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/models/white_noise_track.dart';

void main() {
  group('WhiteNoiseTrack Tests', () {
    test('audioUrl formats CDN audio link correctly', () {
      const track = WhiteNoiseTrack(
        id: 'rain',
        title: 'Chuva',
        relativePath: 'music/rain.mp3',
        volume: 0.7,
      );

      expect(track.audioUrl, equals('https://alicdn.pallo.cn/music/rain.mp3'));
      expect(track.volume, equals(0.7));
    });
  });
}
