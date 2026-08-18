import 'package:flutter/material.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/utils/constants.dart';

class YearEndScreen extends StatelessWidget {
  final GameSession session;
  final List<Decision> decisions;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  /// 自ら引退し、分岐エンディングを見る。null なら「引退する」選択肢は表示しない。
  final VoidCallback? onRetire;

  const YearEndScreen({
    Key? key,
    required this.session,
    required this.decisions,
    required this.onContinue,
    required this.onRestart,
    this.onRetire,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = session.status;
    final history = DecisionHistory(decisions);
    final avgScore = history.averageImpactScore;
    final successRate = session.successRate;

    final evaluation = _getYearEvaluation(status.healthScore, successRate);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // 年度ヘッダー
              Center(
                child: Column(
                  children: [
                    Text(
                      evaluation.emoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${status.year}年目 終了',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: evaluation.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: evaluation.color),
                      ),
                      child: Text(
                        evaluation.label,
                        style: TextStyle(
                          color: evaluation.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 年間実績カード
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 ${status.year}年度 実績',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _StatRow(
                          label: '意思決定数',
                          value: '${session.totalDecisions}件',
                          icon: '🎯'),
                      _StatRow(
                          label: '成功率',
                          value: '${successRate.toStringAsFixed(1)}%',
                          icon: '✅'),
                      _StatRow(
                          label: '平均スコア',
                          value: avgScore.toStringAsFixed(1),
                          icon: '📈'),
                      _StatRow(
                          label: '国家健全度',
                          value: '${status.healthScore.toStringAsFixed(0)}/100',
                          icon: '🏛️'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingM),

              // 最終ステータス
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌍 ${session.countryName} 現況',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _StatusGrid(status: status),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingM),

              // 評価メッセージ
              Card(
                color: evaluation.color.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💬 ${evaluation.label}の評価',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: evaluation.color),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        evaluation.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 来年の選択
              Text(
                '次のステップを選択してください',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingM),

              // 続行ボタン
              ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.arrow_forward),
                label: Text('${status.year + 1}年目に進む'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(VisualConstants.colorGood),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusM),
                  ),
                ),
              ),

              if (onRetire != null) ...[
                const SizedBox(height: AppConstants.paddingM),
                // 引退ボタン（分岐エンディングへ）
                OutlinedButton.icon(
                  onPressed: () => _showRetireDialog(context),
                  icon: const Icon(Icons.flag),
                  label: const Text('引退し、統治の結末を見る'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC9A227),
                    side: const BorderSide(color: Color(0xFFC9A227)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusM),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.paddingM),

              // 再スタートボタン
              OutlinedButton.icon(
                onPressed: () => _showRestartDialog(context),
                icon: const Icon(Icons.refresh),
                label: const Text('新しい国家で再スタート'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(VisualConstants.colorDanger),
                  side:
                      BorderSide(color: Color(VisualConstants.colorDanger)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusM),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showRetireDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('引退しますか？'),
        content: const Text('これまでの統治を締めくくり、結末を確認します。'
            'この国家の記録はそこで確定します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRetire?.call();
            },
            child: const Text('引退する'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('再スタートしますか？'),
        content: const Text('現在のゲームは終了します。新しい国家で最初からスタートします。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRestart();
            },
            child: const Text(
              '再スタート',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  _YearEvaluation _getYearEvaluation(double healthScore, double successRate) {
    final combined = healthScore * 0.6 + successRate * 0.4;
    if (combined >= 75) {
      return _YearEvaluation(
        emoji: '🌟',
        label: '卓越した統治',
        color: const Color(0xFF4CAF50),
        message: '素晴らしい指導力でした。国民はあなたを歴史的な名君として記憶するでしょう。'
            '国家の各指標はいずれも健全で、次年度の展望も明るい。',
      );
    } else if (combined >= 60) {
      return _YearEvaluation(
        emoji: '👍',
        label: '良好な統治',
        color: const Color(0xFF8BC34A),
        message: '安定した国家運営でした。いくつかの課題は残りますが、全体として良い方向に'
            '進んでいます。次年度さらなる改善を目指しましょう。',
      );
    } else if (combined >= 45) {
      return _YearEvaluation(
        emoji: '😐',
        label: '平凡な統治',
        color: const Color(0xFFFFC107),
        message: '無難な一年でした。しかし多くの課題が積み残されています。'
            '次年度は優先順位を定め、重要な問題から取り組む必要があります。',
      );
    } else if (combined >= 30) {
      return _YearEvaluation(
        emoji: '⚠️',
        label: '不安定な統治',
        color: const Color(0xFFFF9800),
        message: '国家は多くの困難に直面しています。国民の不満が高まっており、'
            '次年度の対応を誤れば国家の存続も危うくなります。',
      );
    } else {
      return _YearEvaluation(
        emoji: '🚨',
        label: '危機的な統治',
        color: const Color(0xFFF44336),
        message: '国家は深刻な危機に陥っています。国民の信頼は失われ、'
            '経済は崩壊の瀬戸際にあります。抜本的な改革が必要です。',
      );
    }
  }
}

class _YearEvaluation {
  final String emoji;
  final String label;
  final Color color;
  final String message;

  const _YearEvaluation({
    required this.emoji,
    required this.label,
    required this.color,
    required this.message,
  });
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label),
          ]),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  final dynamic status;

  const _StatusGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _Cell(
                  '💰', 'GDP', '\$${status.gdp.toStringAsFixed(0)}B',
                  good: status.gdp > 1000)),
          const SizedBox(width: 8),
          Expanded(
              child: _Cell(
                  '👷', '失業率', '${status.unemployment.toStringAsFixed(1)}%',
                  good: status.unemployment < 7)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _Cell(
                  '😊', '満足度', '${status.satisfaction.toStringAsFixed(0)}/100',
                  good: status.satisfaction > 50)),
          const SizedBox(width: 8),
          Expanded(
              child: _Cell(
                  '⚔️', '国力', '${status.nationalPower.toStringAsFixed(0)}/100',
                  good: status.nationalPower > 50)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _Cell(
                  '📈', 'インフレ', '${status.inflationRate.toStringAsFixed(1)}%',
                  good: status.inflationRate < 3)),
          const SizedBox(width: 8),
          Expanded(
              child: _Cell(
                  '🏛️', '安定度', '${status.stability.toStringAsFixed(0)}/100',
                  good: status.stability > 60)),
        ]),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool good;

  const _Cell(this.icon, this.label, this.value, {required this.good});

  @override
  Widget build(BuildContext context) {
    final color = good ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon $label',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
