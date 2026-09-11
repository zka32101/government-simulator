import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/providers/game_provider.dart';

/// 討論会サマリー画面
/// 最終的な討論会結果と名声・キャンペーン効果を表示
class DebateSummaryScreen extends ConsumerStatefulWidget {
  final Debate debate;

  const DebateSummaryScreen({
    required this.debate,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DebateSummaryScreen> createState() =>
      _DebateSummaryScreenState();
}

class _DebateSummaryScreenState extends ConsumerState<DebateSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);

    if (session.session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final outcome = widget.debate.outcome ?? DebateOutcome.tie;
    final playerScore = widget.debate.playerScore;
    final rivalScore = widget.debate.rivalScore;
    final playerWon = playerScore > rivalScore;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('討論会終了'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 最終スコア
              Padding(
                padding: const EdgeInsets.all(16),
                child: _FinalScoreDisplay(
                  playerScore: playerScore,
                  rivalScore: rivalScore,
                  opponentName: widget.debate.opponentName,
                ),
              ),

              const SizedBox(height: 24),

              // 勝利タイプインジケーター
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _VictoryTypeIndicator(
                  outcome: outcome,
                  playerWon: playerWon,
                ),
              ),

              const SizedBox(height: 24),

              // メディア見出し
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MediaHeadlineWidget(
                  outcome: outcome,
                  playerWon: playerWon,
                  opponentName: widget.debate.opponentName,
                ),
              ),

              const SizedBox(height: 24),

              // 効果パネル
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _EffectsPanel(
                  outcome: outcome,
                  playerReputation: session.session!.playerReputation,
                ),
              ),

              const SizedBox(height: 32),

              // ゲーム続行ボタン
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ゲームに戻る',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 最終スコア表示
class _FinalScoreDisplay extends StatelessWidget {
  final double playerScore;
  final double rivalScore;
  final String opponentName;

  const _FinalScoreDisplay({
    required this.playerScore,
    required this.rivalScore,
    required this.opponentName,
  });

  @override
  Widget build(BuildContext context) {
    final playerWon = playerScore > rivalScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最終スコア',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // プレイヤー
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: playerWon ? Colors.blue : Colors.grey[300]!,
                    width: playerWon ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: playerWon ? Colors.blue[50] : Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (playerWon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '勝利',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (playerWon) const SizedBox(height: 8) else const SizedBox.shrink(),
                    Text(
                      'あなた',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      playerScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 対戦相手
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: !playerWon ? Colors.red : Colors.grey[300]!,
                    width: !playerWon ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: !playerWon ? Colors.red[50] : Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (!playerWon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '勝利',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (!playerWon) const SizedBox(height: 8) else const SizedBox.shrink(),
                    Text(
                      opponentName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      rivalScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 勝利タイプインジケーター
class _VictoryTypeIndicator extends StatelessWidget {
  final DebateOutcome outcome;
  final bool playerWon;

  const _VictoryTypeIndicator({
    required this.outcome,
    required this.playerWon,
  });

  @override
  Widget build(BuildContext context) {
    final outcomeLabel = _getOutcomeLabel();
    final emoji = _getEmoji();
    final color = _getColor();

    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              outcomeLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOutcomeLabel() {
    switch (outcome) {
      case DebateOutcome.dominantVictory:
        return '圧倒的勝利';
      case DebateOutcome.clearVictory:
        return '明確な勝利';
      case DebateOutcome.narrowVictory:
        return '僅かな勝利';
      case DebateOutcome.tie:
        return '互角';
      case DebateOutcome.narrowLoss:
        return '僅かな敗北';
      case DebateOutcome.clearLoss:
        return '明確な敗北';
      case DebateOutcome.dominantLoss:
        return '圧倒的敗北';
    }
  }

  String _getEmoji() {
    if (playerWon) {
      return switch (outcome) {
        DebateOutcome.dominantVictory => '🎯',
        DebateOutcome.clearVictory => '✨',
        DebateOutcome.narrowVictory => '⚖️',
        _ => '👏',
      };
    } else {
      return switch (outcome) {
        DebateOutcome.narrowLoss => '📉',
        DebateOutcome.clearLoss => '❌',
        DebateOutcome.dominantLoss => '💔',
        _ => '🤐',
      };
    }
  }

  Color _getColor() {
    if (playerWon) {
      return switch (outcome) {
        DebateOutcome.dominantVictory => Colors.green[700]!,
        DebateOutcome.clearVictory => Colors.green[600]!,
        DebateOutcome.narrowVictory => Colors.green[500]!,
        _ => Colors.blue,
      };
    } else {
      return switch (outcome) {
        DebateOutcome.narrowLoss => Colors.orange[600]!,
        DebateOutcome.clearLoss => Colors.red[600]!,
        DebateOutcome.dominantLoss => Colors.red[800]!,
        _ => Colors.grey,
      };
    }
  }
}

/// メディア見出しウィジェット
class _MediaHeadlineWidget extends StatelessWidget {
  final DebateOutcome outcome;
  final bool playerWon;
  final String opponentName;

  const _MediaHeadlineWidget({
    required this.outcome,
    required this.playerWon,
    required this.opponentName,
  });

  @override
  Widget build(BuildContext context) {
    final headline = _generateHeadline();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.newspaper,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'メディア反応',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              headline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateHeadline() {
    if (playerWon) {
      return switch (outcome) {
        DebateOutcome.dominantVictory =>
          '🎯 "明確なリーダーシップ: あなたが討論会で圧倒"\n📰 "対戦相手は政策論争で後手に回った"',
        DebateOutcome.clearVictory =>
          '✨ "説得力のある主張: あなたが有権者を獲得"\n📰 "接戦も、経験の差が明確"',
        DebateOutcome.narrowVictory =>
          '⚖️ "一歩リード: 精密な討論会となった"\n📰 "視聴者の評価が分かれる"',
        _ => '👏 "接戦の結果: 両候補とも見どころあり"\n📰 "第二回目の討論会が決定打となるか"',
      };
    } else {
      return switch (outcome) {
        DebateOutcome.narrowLoss =>
          '📉 "攻撃に耐えられず: あなたが後退"\n📰 "$opponentNameが討論会を支配"',
        DebateOutcome.clearLoss =>
          '❌ "決定的な敗北: 政策の差が露出"\n📰 "$opponentNameが圧倒的リード"',
        DebateOutcome.dominantLoss =>
          '💔 "完全な敗北: 観客が$opponentNameを支持"\n📰 "次の選挙投票は危機的な状況へ"',
        _ => '🤐 "互角の討論: 決着がつかず"\n📰 "次回の討論が関鍵となるか"',
      };
    }
  }
}

/// 効果パネル
class _EffectsPanel extends StatelessWidget {
  final DebateOutcome outcome;
  final int playerReputation;

  const _EffectsPanel({
    required this.outcome,
    required this.playerReputation,
  });

  @override
  Widget build(BuildContext context) {
    final reputationChange = outcome.reputationChange;
    final campaignMultiplier = outcome.campaignMultiplier;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ゲーム効果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _EffectRow(
              icon: Icons.star,
              label: '名声変化',
              value: reputationChange >= 0
                  ? '+${reputationChange.toStringAsFixed(0)}'
                  : reputationChange.toStringAsFixed(0),
              color: reputationChange >= 0 ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _EffectRow(
              icon: Icons.trending_up,
              label: 'キャンペーン効果',
              value: '${campaignMultiplier.toStringAsFixed(2)}x',
              color: campaignMultiplier >= 1.0 ? Colors.blue : Colors.orange,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '📌 4週間にわたってキャンペーン効果が継続します',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 効果行
class _EffectRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EffectRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
