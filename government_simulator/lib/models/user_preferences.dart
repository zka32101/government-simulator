/// ユーザー設定・プリファレンス
/// ゲーム内設定：音声、アニメーション、テーマなど

/// ユーザー設定モデル
class UserPreferences {
  /// サウンド有効化フラグ
  final bool soundEnabled;

  /// サウンド音量（0.0-1.0）
  final double soundVolume;

  /// アニメーション有効化フラグ
  final bool animationsEnabled;

  /// アニメーション速度（0.5-2.0、1.0が標準）
  final double animationSpeed;

  /// テーマモード（'light'、'dark'、'auto'）
  final String themeMode;

  /// モーション削減モード（WCAG アクセシビリティ）
  final bool reduceMotion;

  /// 日本語テキスト有効化
  final bool japaneseTextEnabled;

  /// 効果音のみ有効化（背景音楽は無効）
  final bool sfxOnlyMode;

  const UserPreferences({
    this.soundEnabled = true,
    this.soundVolume = 0.7,
    this.animationsEnabled = true,
    this.animationSpeed = 1.0,
    this.themeMode = 'auto',
    this.reduceMotion = false,
    this.japaneseTextEnabled = true,
    this.sfxOnlyMode = false,
  });

  /// コピー・変更用メソッド
  UserPreferences copyWith({
    bool? soundEnabled,
    double? soundVolume,
    bool? animationsEnabled,
    double? animationSpeed,
    String? themeMode,
    bool? reduceMotion,
    bool? japaneseTextEnabled,
    bool? sfxOnlyMode,
  }) {
    return UserPreferences(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      themeMode: themeMode ?? this.themeMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      japaneseTextEnabled: japaneseTextEnabled ?? this.japaneseTextEnabled,
      sfxOnlyMode: sfxOnlyMode ?? this.sfxOnlyMode,
    );
  }

  /// 辞書に変換
  Map<String, dynamic> toMap() {
    return {
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
      'animationsEnabled': animationsEnabled,
      'animationSpeed': animationSpeed,
      'themeMode': themeMode,
      'reduceMotion': reduceMotion,
      'japaneseTextEnabled': japaneseTextEnabled,
      'sfxOnlyMode': sfxOnlyMode,
    };
  }

  /// 辞書から生成
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      soundVolume: (map['soundVolume'] as num?)?.toDouble() ?? 0.7,
      animationsEnabled: map['animationsEnabled'] as bool? ?? true,
      animationSpeed: (map['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      themeMode: map['themeMode'] as String? ?? 'auto',
      reduceMotion: map['reduceMotion'] as bool? ?? false,
      japaneseTextEnabled: map['japaneseTextEnabled'] as bool? ?? true,
      sfxOnlyMode: map['sfxOnlyMode'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          soundEnabled == other.soundEnabled &&
          soundVolume == other.soundVolume &&
          animationsEnabled == other.animationsEnabled &&
          animationSpeed == other.animationSpeed &&
          themeMode == other.themeMode &&
          reduceMotion == other.reduceMotion &&
          japaneseTextEnabled == other.japaneseTextEnabled &&
          sfxOnlyMode == other.sfxOnlyMode;

  @override
  int get hashCode =>
      soundEnabled.hashCode ^
      soundVolume.hashCode ^
      animationsEnabled.hashCode ^
      animationSpeed.hashCode ^
      themeMode.hashCode ^
      reduceMotion.hashCode ^
      japaneseTextEnabled.hashCode ^
      sfxOnlyMode.hashCode;

  @override
  String toString() {
    return 'UserPreferences('
        'soundEnabled: $soundEnabled, '
        'soundVolume: $soundVolume, '
        'animationsEnabled: $animationsEnabled, '
        'animationSpeed: $animationSpeed, '
        'themeMode: $themeMode, '
        'reduceMotion: $reduceMotion, '
        'japaneseTextEnabled: $japaneseTextEnabled, '
        'sfxOnlyMode: $sfxOnlyMode'
        ')';
  }
}
