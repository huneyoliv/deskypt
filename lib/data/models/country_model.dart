class CountryModel {
  final int id;
  final String name;
  final String code;
  final String timezone;
  final String continent;

  const CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.timezone,
    required this.continent,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int? ?? 0,
      name: json['t'] as String? ?? '',
      code: json['c'] as String? ?? 'BR',
      timezone: json['tz'] as String? ?? 'America/Sao_Paulo',
      continent: json['con'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        't': name,
        'c': code,
        'tz': timezone,
        'con': continent,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code;

  @override
  int get hashCode => id.hashCode ^ code.hashCode;
}
