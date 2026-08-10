import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/white_noise_track.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final Map<String, AudioPlayer> _players = {};

  List<WhiteNoiseTrack> _tracks = const [
    WhiteNoiseTrack(
      id: 'rain',
      title: 'Chuva Suave 🌧️',
      relativePath: 'music/rain.mp3',
      volume: 0.6,
    ),
    WhiteNoiseTrack(
      id: 'cafe',
      title: 'Cafeteria ☕',
      relativePath: 'music/cafe.mp3',
      volume: 0.5,
    ),
    WhiteNoiseTrack(
      id: 'fireplace',
      title: 'Lareira 🔥',
      relativePath: 'music/fireplace.mp3',
      volume: 0.5,
    ),
    WhiteNoiseTrack(
      id: 'wind',
      title: 'Vento na Floresta 🍃',
      relativePath: 'music/wind.mp3',
      volume: 0.5,
    ),
    WhiteNoiseTrack(
      id: 'ocean',
      title: 'Ondas do Mar 🌊',
      relativePath: 'music/ocean.mp3',
      volume: 0.5,
    ),
    WhiteNoiseTrack(
      id: 'library',
      title: 'Biblioteca Silenciosa 📚',
      relativePath: 'music/library.mp3',
      volume: 0.4,
    ),
  ];

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleTrack(WhiteNoiseTrack track) async {
    final isPlaying = !track.isPlaying;

    setState(() {
      _tracks = _tracks.map((t) {
        if (t.id == track.id) {
          return t.copyWith(isPlaying: isPlaying);
        }
        return t;
      }).toList();
    });

    AudioPlayer player = _players[track.id] ??= AudioPlayer();

    if (isPlaying) {
      try {
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(track.volume);
        await player.setUrl(track.audioUrl);
        await player.play();
      } catch (_) {
        // Fallback em ambiente de teste ou desconectado
      }
    } else {
      await player.pause();
    }
  }

  void _changeVolume(WhiteNoiseTrack track, double newVolume) {
    setState(() {
      _tracks = _tracks.map((t) {
        if (t.id == track.id) {
          return t.copyWith(volume: newVolume);
        }
        return t;
      }).toList();
    });

    final player = _players[track.id];
    if (player != null) {
      player.setVolume(newVolume);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ruído Branco & Foco', style: AppTextStyles.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sons de Foco e Ruído Branco',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Combine múltiplos sons e ajuste os volumes individuais para criar seu ambiente perfeito de estudo.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Tracks Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: track.isPlaying
                            ? AppColors.primary
                            : AppColors.border,
                        width: track.isPlaying ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                track.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _toggleTrack(track),
                              icon: Icon(
                                track.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: track.isPlaying
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Volume',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12)),
                                Text('${(track.volume * 100).toInt()}%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.surface,
                                thumbColor: AppColors.primary,
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: track.volume,
                                onChanged: (val) => _changeVolume(track, val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
