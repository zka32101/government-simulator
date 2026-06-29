// ゲーム全体の定数定義

class AppConstants {
  // アプリ基本情報
  static const String appName = '政府シミュレーター';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'Petit Works';

  // 価格
  static const double basePriceMBPJP = 600; // 買い切り価格（日本円）
  static const double dlcPriceJP = 400; // DLC価格

  // ゲーム設定
  static const int daysPerYear = 7; // ゲーム内で1年 = 現実 7日
  static const int initialDay = 1;
  static const int initialYear = 1;

  // 初期国家ステータス
  static const double initialGdp = 1000; // $1000B
  static const double initialUnemployment = 5.0; // 5%
  static const double initialSatisfaction = 50.0; // 50/100
  static const double initialNationalPower = 50.0; // 50/100
  static const double initialInflationRate = 2.0; // 2%
  static const double initialPublicDebt = 60.0; // 60% GDP比
  static const double initialStability = 70.0; // 70/100

  // ゲーム性パラメータ
  static const int maxDecisionsPerDay = 3; // 1日の最大選択肢数
  static const int minDecisionsPerDay = 3; // 1日の最小選択肢数

  // UI定数
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 16.0;

  // アニメーション
  static const Duration shortAnimDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimDuration = Duration(milliseconds: 500);
  static const Duration longAnimDuration = Duration(milliseconds: 800);

  // ローカライゼーション
  static const String defaultLocale = 'ja_JP';
}

class GameLevels {
  static const Map<String, double> difficultyMultiplier = {
    'easy': 0.8,
    'normal': 1.0,
    'hard': 1.3,
  };

  static const Map<String, String> difficultyLabel = {
    'easy': 'イージー - 初心者向け',
    'normal': 'ノーマル - 標準難易度',
    'hard': 'ハード - 上級者向け',
  };
}

class CrisisThresholds {
  // 危機レベルの判定基準
  static const double criticalUnemployment = 15.0;
  static const double criticalSatisfaction = 20.0;
  static const double criticalGdp = 200.0;

  static const double highUnemployment = 10.0;
  static const double highSatisfaction = 40.0;
  static const double highGdp = 400.0;

  static const double mediumUnemployment = 7.0;
  static const double mediumSatisfaction = 60.0;
  static const double mediumGdp = 700.0;
}

class ImpactRanges {
  // インパクト値の範囲（バランス調整用）
  static const double maxGdpChangePercent = 5.0;
  static const double maxUnemploymentChange = 5.0;
  static const double maxSatisfactionChange = 30.0;
  static const double maxNationalPowerChange = 15.0;
  static const double maxInflationChange = 3.0;
  static const double maxStabilityChange = 20.0;
}

class VisualConstants {
  // カラー定義
  static const int colorGood = 0xFF4CAF50; // 緑
  static const int colorWarning = 0xFFFFC107; // 黄
  static const int colorDanger = 0xFFF44336; // 赤
  static const int colorNeutral = 0xFF9E9E9E; // グレー
  static const int colorPrimary = 0xFF2196F3; // 青

  // アイコン・テキスト定義
  static const String economicIcon = '💰';
  static const String employmentIcon = '👥';
  static const String socialIcon = '🏛️';
  static const String stabilityIcon = '📈';
  static const String environmentIcon = '🌍';
  static const String militaryIcon = '🛡️';
}

// Firebase パス定義
class FirebaseCollections {
  static const String users = 'users';
  static const String gameSessions = 'game_sessions';
  static const String decisions = 'decisions';
  static const String events = 'events';
}

// 日本語ラベル定義
class JapaneseLabels {
  static const Map<String, String> months = {
    '1': '1月',
    '2': '2月',
    '3': '3月',
    '4': '4月',
    '5': '5月',
    '6': '6月',
    '7': '7月',
    '8': '8月',
    '9': '9月',
    '10': '10月',
    '11': '11月',
    '12': '12月',
  };

  static const Map<String, String> stats = {
    'gdp': '国内総生産 (GDP)',
    'unemployment': '失業率',
    'satisfaction': '国民満足度',
    'nationalPower': '国力',
    'inflation': 'インフレ率',
    'stability': '経済安定度',
  };
}
