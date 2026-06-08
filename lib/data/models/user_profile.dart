class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.avatarEmoji,
    required this.themeMode,
    required this.passwordHash,
    required this.isLoggedIn,
    required this.createdAt,
    required this.updatedAt,
  });

  static const String defaultThemeMode = 'system';

  final int? id;
  final String displayName;
  final String email;
  final String bio;
  final String avatarEmoji;
  final String themeMode;
  final String passwordHash;
  final bool isLoggedIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRegistered {
    return id != null && email.trim().isNotEmpty && passwordHash.isNotEmpty;
  }

  factory UserProfile.guest() {
    final now = DateTime.now();

    return UserProfile(
      id: null,
      displayName: 'Guest',
      email: '',
      bio: '',
      avatarEmoji: '🌱',
      themeMode: defaultThemeMode,
      passwordHash: '',
      isLoggedIn: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.defaults() {
    return UserProfile.guest();
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email.trim().toLowerCase(),
      'bio': bio,
      'avatar_emoji': avatarEmoji,
      'theme_mode': themeMode,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(
    Map<String, Object?> map, {
    bool isLoggedIn = false,
  }) {
    final now = DateTime.now();

    return UserProfile(
      id: map['id'] as int?,
      displayName: map['display_name']?.toString() ?? 'Plant Lover',
      email: map['email']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      avatarEmoji: map['avatar_emoji']?.toString() ?? '🌱',
      themeMode: map['theme_mode']?.toString() ?? defaultThemeMode,
      passwordHash: map['password_hash']?.toString() ?? '',
      isLoggedIn: isLoggedIn,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? now,
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? now,
    );
  }

  UserProfile copyWith({
    int? id,
    String? displayName,
    String? email,
    String? bio,
    String? avatarEmoji,
    String? themeMode,
    String? passwordHash,
    bool? isLoggedIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      themeMode: themeMode ?? this.themeMode,
      passwordHash: passwordHash ?? this.passwordHash,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}