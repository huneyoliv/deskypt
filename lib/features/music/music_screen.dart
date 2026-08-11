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
  double _masterVolume = 0.8;
  bool _isMasterPlaying = true;

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

    if (isPlaying && _isMasterPlaying) {
      try {
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(track.volume * _masterVolume);
        await player.setUrl(track.audioUrl);
        await player.play();
      } catch (_) {}
    } else {
      await player.pause();
    }
  }

  void _changeTrackVolume(FocusMusicTrack track, double newVolume) {
    setState(() {
      _tracks = _tracks.map((t) {
        if (t.id == track.id) {
          return t.copyWith(volume: newVolume);
        }
        return t;
      }).toList();
    });

    final player = _players[track.id];
    if (player != null && track.isPlaying && _isMasterPlaying) {
      player.setVolume(newVolume * _masterVolume);
    }
  }

  void _changeMasterVolume(double val) {
    setState(() => _masterVolume = val);
    for (final t in _tracks) {
      if (t.isPlaying) {
        final player = _players[t.id];
        if (player != null) {
          player.setVolume(t.volume * _masterVolume);
        }
      }
    }
  }

  void _toggleMasterPlay() {
    setState(() => _isMasterPlaying = !_isMasterPlaying);
    for (final t in _tracks) {
      final player = _players[t.id];
      if (player != null && t.isPlaying) {
        if (_isMasterPlaying) {
          player.play();
        } else {
          player.pause();
        }
      }
    }
  }

  IconData _getTrackIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('chuva') || lower.contains('rain')) return Icons.water_drop_outlined;
    if (lower.contains('biblioteca') || lower.contains('library')) return Icons.menu_book_rounded;
    if (lower.contains('café') || lower.contains('cafe')) return Icons.local_cafe_outlined;
    if (lower.contains('floresta') || lower.contains('forest')) return Icons.forest_outlined;
    if (lower.contains('fogo') || lower.contains('fire')) return Icons.local_fire_department_outlined;
    if (lower.contains('onda') || lower.contains('sea')) return Icons.waves_rounded;
    if (lower.contains('vento') || lower.contains('wind')) return Icons.air_rounded;
    return Icons.graphic_eq_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _tracks.where((t) => t.isPlaying).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ruído Branco & Sons de Foco', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTracks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Ambient Equalizer Circle Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GridView.builder(
                    padding: const EdgeInsets.all(32),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) {
                      final track = _tracks[index];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleTrack(track),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: track.isPlaying
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.card,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: track.isPlaying ? AppColors.primary : AppColors.border,
                                  width: track.isPlaying ? 3 : 1.5,
                                ),
                                boxShadow: track.isPlaying
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  _getTrackIcon(track.title),
                                  size: 44,
                                  color: track.isPlaying ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            track.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: track.isPlaying ? Colors.white : AppColors.textSecondary,
                              fontWeight: track.isPlaying ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (track.isPlaying)
                            SizedBox(
                              width: 140,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: AppColors.surface,
                                  thumbColor: AppColors.primary,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: track.volume,
                                  onChanged: (val) => _changeTrackVolume(track, val),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),

          // Bottom Bar - Master Volume & Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  iconSize: 36,
                  icon: Icon(
                    _isMasterPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: AppColors.primary,
                  ),
                  onPressed: _toggleMasterPlay,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isMasterPlaying ? 'Mix Ativo ($activeCount sons)' : 'Pausado',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Text('Sons ambiente simultâneos', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.volume_down, color: AppColors.textMuted, size: 20),
                SizedBox(
                  width: 180,
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surface,
                      thumbColor: AppColors.primary,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _masterVolume,
                      onChanged: _changeMasterVolume,
                    ),
                  ),
                ),
                Text(
                  '${(_masterVolume * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
