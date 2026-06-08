class Plant {
  const Plant({
    this.id,
    this.userId,
    required this.name,
    required this.species,
    required this.notes,
    required this.wateringIntervalDays,
    required this.lastWateredAt,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String name;
  final String species;
  final String notes;
  final int wateringIntervalDays;
  final DateTime lastWateredAt;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get nextWateringDate {
    return lastWateredAt.add(Duration(days: wateringIntervalDays));
  }

  bool get needsWaterToday {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final nextWatering = DateTime(
      nextWateringDate.year,
      nextWateringDate.month,
      nextWateringDate.day,
    );

    return nextWatering.isBefore(today) || nextWatering.isAtSameMomentAs(today);
  }

  String get nextWateringLabel {
    final date = nextWateringDate;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  String get lastWateredLabel {
    final date = lastWateredAt;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      'notes': notes,
      'watering_interval_days': wateringIntervalDays,
      'last_watered_at': lastWateredAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Plant.fromMap(Map<String, Object?> map) {
    final now = DateTime.now();

    return Plant(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      name: map['name']?.toString() ?? '',
      species: map['species']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      wateringIntervalDays: (map['watering_interval_days'] as int?) ?? 7,
      lastWateredAt: DateTime.tryParse(
            map['last_watered_at']?.toString() ?? '',
          ) ??
          now,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          ) ??
          now,
      updatedAt: DateTime.tryParse(
            map['updated_at']?.toString() ?? '',
          ) ??
          now,
    );
  }

  Plant copyWith({
    int? id,
    int? userId,
    String? name,
    String? species,
    String? notes,
    int? wateringIntervalDays,
    DateTime? lastWateredAt,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      notes: notes ?? this.notes,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Plant.demo({
    int? userId,
    required String name,
    required String species,
    required String notes,
    required int wateringIntervalDays,
    bool isFavorite = false,
  }) {
    final now = DateTime.now();

    return Plant(
      userId: userId,
      name: name,
      species: species,
      notes: notes,
      wateringIntervalDays: wateringIntervalDays,
      lastWateredAt: now.subtract(Duration(days: wateringIntervalDays)),
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );
  }
}