import '../../core/cdn/cdn_resolver.dart';

class FocusMusicTrack {
  final int id;
  final String title;
  final String description;
  final String artist;
  final int durationSeconds;
  final String audioUrl;
  final String? coverUrl;
  final bool isPlaying;
  final double volume;

  const FocusMusicTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.artist,
    required this.durationSeconds,
    required this.audioUrl,
    this.coverUrl,
    this.isPlaying = false,
    this.volume = 0.5,
  });

  factory FocusMusicTrack.fromJson(Map<String, dynamic> json) {
    final musicData = json['m'] is Map<String, dynamic> ? json['m'] as Map<String, dynamic> : json;

    final rawUrl = musicData['mu'] as String? ?? musicData['audioUrl'] as String? ?? '';
    final formattedAudioUrl = CdnResolver.audioUrl(rawUrl);

    return FocusMusicTrack(
      id: musicData['id'] as int? ?? json['id'] as int? ?? 0,
      title: musicData['t'] as String? ?? musicData['title'] as String? ?? 'Música de Foco',
      description: musicData['dc'] as String? ?? musicData['description'] as String? ?? '',
      artist: musicData['a'] as String? ?? musicData['artist'] as String? ?? 'YPT Studio',
      durationSeconds: musicData['d'] as int? ?? musicData['duration'] as int? ?? 180,
      audioUrl: formattedAudioUrl,
      coverUrl: musicData['tu'] as String? ?? musicData['img'] as String?,
    );
  }

  FocusMusicTrack copyWith({
    int? id,
    String? title,
    String? description,
    String? artist,
    int? durationSeconds,
    String? audioUrl,
    String? coverUrl,
    bool? isPlaying,
    double? volume,
  }) {
    return FocusMusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      artist: artist ?? this.artist,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}
