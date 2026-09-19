/// スキャンダルイベント
/// スキャンダル発見時のプレイヤー選択肢を定義

library;

import 'package:government_simulator/models/scandal.dart';

/// スキャンダル応答選択肢
class ScandalEventOption {
  final ScandalResponse response;
  final String title;
  final String description;
  final double successProbability;
  final String consequence;
  final double riskyFactor; // 0=安全、1=危険

  const ScandalEventOption({
    required this.response,
    required this.title,
    required this.description,
    required this.successProbability,
    required this.consequence,
    required this.riskyFactor,
  });
}

/// スキャンダルイベント
class ScandalEvent {
  final String scandalId;
  final Scandal scandal;
  final String headline;
  final String detailedDescription;
  final DateTime eventTime;
  final List<ScandalEventOption> options;

  const ScandalEvent({
    required this.scandalId,
    required this.scandal,
    required this.headline,
    required this.detailedDescription,
    required this.eventTime,
    required this.options,
  });

  /// デフォルトの応答選択肢を生成
  static List<ScandalEventOption> getDefaultOptions(Scandal scandal) {
    return [
      ScandalEventOption(
        response: ScandalResponse.apologize,
        title: '公開謝罪',
        description: 'メディアの前で公式に謝罪し、責任を認める。短期的な支持率低下は大きいが、信頼度は回復する。',
        successProbability: 0.85,
        consequence: '支持率 -15%, 政治的信頼度 -5%（3週間で回復開始）',
        riskyFactor: 0.3,
      ),
      ScandalEventOption(
        response: ScandalResponse.deny,
        title: '否定・話題転換',
        description: 'スキャンダルを否定し、他の政策の成功を強調して注目をそらす。政治的信頼度へのリスクがある。',
        successProbability: 0.65,
        consequence: '支持率 -8%, 政治的信頼度 -12%',
        riskyFactor: 0.6,
      ),
      ScandalEventOption(
        response: ScandalResponse.counterattack,
        title: '反論・証拠提示',
        description: 'スキャンダルの根拠を反論し、証拠を示して疑いを払拭する。成功時のダメージが小さい。',
        successProbability: 0.55,
        consequence: '成功: 支持率 -5% / 失敗: 支持率 -20%, 信頼度 -15%',
        riskyFactor: 0.7,
      ),
      ScandalEventOption(
        response: ScandalResponse.coverup,
        title: '隠蔽工作',
        description: '情報源を追跡し、スキャンダルの流出を防ぐ。成功すればダメージはないが、暴露されると致命的。',
        successProbability: _calculateCoverupSuccess(scandal),
        consequence: '成功時: ダメージなし / 失敗時: 支持率 -30%, 信頼度 -40%（致命的）',
        riskyFactor: 0.95,
      ),
      ScandalEventOption(
        response: ScandalResponse.ignore,
        title: '無視・職務継続',
        description: 'スキャンダルに対応せず、通常業務を続ける。時間が経てば自然に忘れられる可能性もある。',
        successProbability: 0.5,
        consequence: '週数による自然減衰。ただし長期的影響あり',
        riskyFactor: 0.5,
      ),
    ];
  }

  static double _calculateCoverupSuccess(Scandal scandal) {
    return switch (scandal.severity) {
      ScandalSeverity.minor => 0.95,
      ScandalSeverity.moderate => 0.80,
      ScandalSeverity.serious => 0.50,
      ScandalSeverity.critical => 0.20,
    };
  }

  /// 次のスキャンダル（フォローアップ）を生成するか
  bool shouldGenerateFollowUp(ScandalResponse response) {
    return switch (response) {
      ScandalResponse.deny => true, // 否定は追加報道の可能性
      ScandalResponse.apologize => false, // 謝罪は決着
      ScandalResponse.counterattack => true, // 反論は議論継続
      ScandalResponse.coverup => true, // 隠蔽は暴露のリスク
      ScandalResponse.ignore => true, // 無視は長期化
    };
  }
}
