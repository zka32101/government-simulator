/// オーディオ・サウンドエフェクト管理
/// ゲーム内の効果音とサウンドの再生を統一的に管理

/// サウンドエフェクトの種類
library;

enum SoundEffect {
  /// 討論会開始音
  debateStart,

  /// プレイヤー主張の効果音
  playerStatement,

  /// 対手主張の効果音
  opponentStatement,

  /// トーン選択時の効果音
  toneSelected,

  /// 強調選択時の効果音
  emphasisSelected,

  /// ラウンド送信音
  roundSubmit,

  /// ラウンド勝利音
  roundWin,

  /// ラウンド敗北音
  roundLoss,

  /// 討論会勝利（ファンファーレ）
  debateVictory,

  /// 討論会敗北（悲しい音）
  debateDefeat,
}

/// オーディオサービス
/// サウンドエフェクトの再生と音量管理を提供
class AudioService {
  static final AudioService _instance = AudioService._internal();

  bool _soundEnabled = true;
  double _volume = 0.7; // 0.0-1.0
  bool _isMuted = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  /// 単一のサウンドエフェクトを再生
  Future<void> playSound(SoundEffect effect) async {
    if (!_shouldPlaySound()) {
      return;
    }

    // 実装: 実際のオーディオ再生エンジンと連携
    // ここではプレースホルダー
    await _playAudioFile(_getSoundFilePath(effect));
  }

  /// サウンドエフェクトのシーケンスを再生
  Future<void> playSequence(List<SoundEffect> effects) async {
    for (final effect in effects) {
      await playSound(effect);
      // エフェクト間の遅延（エフェクトの長さに応じて調整可能）
      await Future.delayed(Duration(milliseconds: _getSoundDuration(effect)));
    }
  }

  /// サウンドエフェクトを並列再生
  Future<void> playSoundsParallel(List<SoundEffect> effects) async {
    await Future.wait(
      effects.map((effect) => playSound(effect)),
    );
  }

  /// 音量を設定（0.0-1.0）
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// 音量を取得
  double getVolume() => _volume;

  /// サウンドのオン/オフ
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// サウンドが有効か確認
  bool isSoundEnabled() => _soundEnabled;

  /// ミュートを切り替え
  void toggleMute() {
    _isMuted = !_isMuted;
  }

  /// ミュート状態を取得
  bool isMuted() => _isMuted;

  /// ミュートを設定
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// サウンドが再生されるべきか判定
  bool _shouldPlaySound() {
    return _soundEnabled && !_isMuted && _volume > 0.0;
  }

  /// サウンドファイルパスを取得
  String _getSoundFilePath(SoundEffect effect) {
    return switch (effect) {
      SoundEffect.debateStart => 'assets/sounds/debate/debate_start.wav',
      SoundEffect.playerStatement => 'assets/sounds/debate/player_statement.wav',
      SoundEffect.opponentStatement =>
        'assets/sounds/debate/opponent_statement.wav',
      SoundEffect.toneSelected => 'assets/sounds/debate/tone_selected.wav',
      SoundEffect.emphasisSelected =>
        'assets/sounds/debate/emphasis_selected.wav',
      SoundEffect.roundSubmit => 'assets/sounds/debate/round_submit.wav',
      SoundEffect.roundWin => 'assets/sounds/debate/round_win.wav',
      SoundEffect.roundLoss => 'assets/sounds/debate/round_loss.wav',
      SoundEffect.debateVictory => 'assets/sounds/debate/debate_victory.wav',
      SoundEffect.debateDefeat => 'assets/sounds/debate/debate_defeat.wav',
    };
  }

  /// サウンドの継続時間をミリ秒で取得
  int _getSoundDuration(SoundEffect effect) {
    return switch (effect) {
      SoundEffect.debateStart => 300,
      SoundEffect.playerStatement => 200,
      SoundEffect.opponentStatement => 200,
      SoundEffect.toneSelected => 100,
      SoundEffect.emphasisSelected => 150,
      SoundEffect.roundSubmit => 200,
      SoundEffect.roundWin => 400,
      SoundEffect.roundLoss => 400,
      SoundEffect.debateVictory => 2500,
      SoundEffect.debateDefeat => 1500,
    };
  }

  /// オーディオファイルを再生（プレースホルダー実装）
  Future<void> _playAudioFile(String filePath) async {
    // 実装ノート：
    // 実際の実装では、以下のような選択肢が考えられます：
    // 1. audioplayers パッケージを使用
    // 2. flutter_sound パッケージを使用
    // 3. just_audio パッケージを使用
    //
    // 例：audioplayers を使用した実装
    // final audioPlayer = AudioPlayer();
    // await audioPlayer.play(AssetSource(filePath));
    // await audioPlayer.setVolume(_volume);

    // プレースホルダー
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// すべてのオーディオをリセット
  void reset() {
    _soundEnabled = true;
    _volume = 0.7;
    _isMuted = false;
  }
}

/// グローバルオーディオサービスインスタンス
final audioService = AudioService();
