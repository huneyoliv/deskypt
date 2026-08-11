import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/focus_music_track.dart';
import '../../data/repositories/music_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepository();
});

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  final Map<int, AudioPlayer> _players = {};
  List<FocusMusicTrack> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);
    final repo = ref.read(musicRepositoryProvider);
    final list = await repo.fetchFocusTracks();
    if (mounted) {
      setState(() {
        _tracks = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTrack(FocusMusicTrack track) async {
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
      } catch (_) {}
    } else {
      await player.pause();
    }
  }

  void _changeVolume(FocusMusicTrack track, double newVolume) {
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

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ruído Branco & Foco', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTracks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Músicas de Foco & Ruído Branco YPT',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Faixas originais do ecossistema YPT para estimular o estado de flow durante o estudo.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Tracks Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        final track = _tracks[index];
                        final hasCover = track.coverUrl != null && track.coverUrl!.isNotEmpty;

                        return Container(
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
                            children: [
                              // Cover Art Header
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                      child: hasCover
                                          ? Image.network(
                                              track.coverUrl!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: AppColors.surface,
                                                child: const Icon(Icons.music_note,
                                                    color: AppColors.primary, size: 48),
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.surface,
                                              child: const Center(
                                                child: Icon(Icons.graphic_eq_rounded,
                                                    color: AppColors.primary, size: 48),
                                              ),
                                            ),
                                    ),

                                    // Play Overlay Button
                                    Positioned(
                                      right: 12,
                                      bottom: 12,
                                      child: FloatingActionButton.small(
                                        heroTag: 'play_music_${track.id}',
                                        backgroundColor: track.isPlaying
                                            ? AppColors.primary
                                            : Colors.black.withValues(alpha: 0.7),
                                        onPressed: () => _toggleTrack(track),
                                        child: Icon(
                                          track.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Info & Volume Control
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      track.description.isNotEmpty
                                          ? track.description
                                          : '${track.artist} • ${_formatDuration(track.durationSeconds)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.volume_down,
                                            size: 16, color: AppColors.textMuted),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              activeTrackColor: AppColors.primary,
                                              inactiveTrackColor: AppColors.surface,
                                              thumbColor: AppColors.primary,
                                              thumbShape: const RoundSliderThumbShape(
                                                  enabledThumbRadius: 6),
                                              trackHeight: 3,
                                            ),
                                            child: Slider(
                                              value: track.volume,
                                              onChanged: (val) =>
                                                  _changeVolume(track, val),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(track.volume * 100).toInt()}%',
                                          style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
