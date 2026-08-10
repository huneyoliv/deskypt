import '../../core/cdn/cdn_resolver.dart';

class StudiconItemModel {
  final int id;
  final String name;
  final String category;
  final int priceFlames;
  final bool isOwned;
  final bool isEquipped;

  const StudiconItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.priceFlames,
    this.isOwned = false,
    this.isEquipped = false,
  });

  String get previewUrl => CdnResolver.studiconUrl(id, StudiconPose.normal1);

  factory StudiconItemModel.fromJson(Map<String, dynamic> json) {
    return StudiconItemModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Studicon',
      category: json['category'] as String? ?? 'Geral',
      priceFlames: json['price'] as int? ?? 100,
      isOwned: json['isOwned'] as bool? ?? false,
      isEquipped: json['isEquipped'] as bool? ?? false,
    );
  }

  StudiconItemModel copyWith({
    int? id,
    String? name,
    String? category,
    int? priceFlames,
    bool? isOwned,
    bool? isEquipped,
  }) {
    return StudiconItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      priceFlames: priceFlames ?? this.priceFlames,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
