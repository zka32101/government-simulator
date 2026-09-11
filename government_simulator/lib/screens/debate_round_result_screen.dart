import 'package:flutter/material.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/debate_choice.dart';

/// 討論会ラウンド結果画面
/// ラウンドのスコア、コメンタリー、モメンタムを表示
class DebateRoundResultScreen extends StatelessWidget {
  final Debate debate;
  final int currentRoundIndex;
  final ArgumentTone selectedTone;
  final EmphasisType selectedEmphasis;
  final bool isLastRound;

  const DebateRoundResultScreen({
    required this.debate,
    required this.currentRoundIndex,
    required this.selectedTone,
    required this.selectedEmphasis,
    required this.isLastRound,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final round = debate.rounds[currentRoundIndex];

    // スコア計算（簡略版：トーンと強調による補正）
    final playerScore = _calculatePlayerScore(round);
    final opponentScore = _calculateOpponentScore(round);
    final momentum = playerScore - opponentScore;

    return WillPopScope(
      onWillPop: () async => false, // 戻るボタンを無効化
      child: Scaffold(
        appBar: AppBar(
          title: Text('ラウンド ${currentRoundIndex + 1} 結果'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // スコア比較
              Padding(
                padding: const EdgeInsets.all(16),
                child: _ScoreComparison(
                  playerScore: playerScore,
                  opponentScore: opponentScore,
                  opponentName: debate.opponentName,
                ),
              ),

              const SizedBox(height: 24),

              // ラウンドコメンタリー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RoundCommentary(
                  playerScore: playerScore,
                  opponentScore: opponentScore,
                  selectedTone: selectedTone,
                  selectedEmphasis: selectedEmphasis,
                  topic: round.topic,
                ),
              ),

              const SizedBox(height: 24),

              // モメンタムインジケーター
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MomentumIndicator(
                  momentum: momentum,
                ),
              ),

              const SizedBox(height: 32),

              // 次へボタン
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _continueDebate(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isLastRound ? '討論会結果を表示' : '次のラウンドへ',
                      style: const TextStyle(fontSize: 16),
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

  double _calculatePlayerScore(DebateRound round) {
    double score = 50.0; // ベーススコア

    // トーンのボーナス
    score += selectedTone.getScoreModifier(
      isPlayerWinning: round.playerRoundScore > round.rivalRoundScore,
      isPlayerStrong: round.playerRoundScore > 60,
      isOpponentWeak: round.rivalRoundScore < 40,
    );

    // 強調のボーナス
    score += selectedEmphasis.getScoreModifier(
      isTopicMatch: true, // 実際の実装では政策マッチを確認
      isPlayerWeak: round.playerRoundScore < 40,
      isOpponentWeak: round.rivalRoundScore < 40,
    );

    // ランダム要素 (±5)
    score += (DateTime.now().microsecond % 11 - 5).toDouble();

    return score.clamp(0.0, 100.0);
  }

  double _calculateOpponentScore(DebateRound round) {
    double score = 50.0; // ベーススコア

    // ランダム要素 (±15)
    score += (DateTime.now().millisecond % 31 - 15).toDouble();

    return score.clamp(0.0, 100.0);
  }

  void _continueDebate(BuildContext context) {
    if (isLastRound) {
      Navigator.pushNamed(
        context,
        '/debate_summary',
        arguments: debate,
      );
    } else {
      Navigator.pushNamed(
        context,
        '/debate_round',
        arguments: {
          'debate': debate,
          'currentRoundIndex': currentRoundIndex + 1,
        },
      );
    }
  }
}

/// スコア比較ウィジェット
class _ScoreComparison extends StatelessWidget {
  final double playerScore;
  final double opponentScore;
  final String opponentName;

  const _ScoreComparison({
    required this.playerScore,
    required this.opponentScore,
    required this.opponentName,
  });

  @override
  Widget build(BuildContext context) {
    final playerWon = playerScore > opponentScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ラウンドスコア',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // プレイヤースコア
            Expanded(
              child: _ScoreCard(
                title: 'あなた',
                score: playerScore,
                isWinner: playerWon,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            // 対戦相手スコア
            Expanded(
              child: _ScoreCard(
                title: opponentName,
                score: opponentScore,
                isWinner: !playerWon,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// スコアカード
class _ScoreCard extends StatelessWidget {
  final String title;
  final double score;
  final bool isWinner;
  final Color color;

  const _ScoreCard({
    required this.title,
    required this.score,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isWinner ? color : Colors.grey[300]!,
          width: isWinner ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isWinner ? color.withOpacity(0.1) : Colors.grey[50],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isWinner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ラウンド勝利',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (isWinner) const SizedBox(height: 8) else const SizedBox.shrink(),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ラウンドコメンタリー
class _RoundCommentary extends StatelessWidget {
  final double playerScore;
  final double opponentScore;
  final ArgumentTone selectedTone;
  final EmphasisType selectedEmphasis;
  final DebateTopic topic;

  const _RoundCommentary({
    required this.playerScore,
    required this.opponentScore,
    required this.selectedTone,
    required this.selectedEmphasis,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final commentary = _generateCommentary();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ラウンド分析',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              commentary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _ChoiceSummary(
              selectedTone: selectedTone,
              selectedEmphasis: selectedEmphasis,
            ),
          ],
        ),
      ),
    );
  }

  String _generateCommentary() {
    final scoreDiff = playerScore - opponentScore;

    if (scoreDiff > 20) {
      return 'あなたは${selectedTone.label}で圧倒的に${selectedEmphasis.label}で攻めた。'
          '視聴者からの評判は非常に高い。';
    } else if (scoreDiff > 10) {
      return 'あなたは${selectedTone.label}でこのラウンドを制した。'
          '${selectedEmphasis.label}の選択が効果的だった。';
    } else if (scoreDiff > 0) {
      return 'わずかな差でこのラウンドを勝ち越した。'
          '${selectedEmphasis.label}はうまく機能したが、さらに強い主張が必要かもしれない。';
    } else if (scoreDiff > -10) {
      return 'このラウンドはほぼ互角だった。'
          'どちらの候補も見どころのある主張をした。';
    } else if (scoreDiff > -20) {
      return '相手がこのラウンドを制した。'
          '${selectedTone.label}の戦略が十分ではなかったようだ。';
    } else {
      return 'あなたはこのラウンドで大きく劣勢に置かれた。'
          '相手の${topic.label}に関する主張が強かった。';
    }
  }
}

/// 選択肢サマリー
class _ChoiceSummary extends StatelessWidget {
  final ArgumentTone selectedTone;
  final EmphasisType selectedEmphasis;

  const _ChoiceSummary({
    required this.selectedTone,
    required this.selectedEmphasis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの選択',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ChoiceTag(
                label: 'トーン',
                value: selectedTone.label,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ChoiceTag(
                label: '強調',
                value: selectedEmphasis.label,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 選択タグ
class _ChoiceTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ChoiceTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// モメンタムインジケーター
class _MomentumIndicator extends StatelessWidget {
  final double momentum;

  const _MomentumIndicator({required this.momentum});

  @override
  Widget build(BuildContext context) {
    final normalizedMomentum = momentum.clamp(-30.0, 30.0) / 30;
    final isPlayerAhead = momentum > 0;
    final momentumLabel = isPlayerAhead ? 'あなたが優勢' : 'あなたが劣勢';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ラウンドモメンタム',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (normalizedMomentum + 1) / 2,
            minHeight: 12,
            backgroundColor: Colors.red[100],
            valueColor: AlwaysStoppedAnimation<Color>(
              isPlayerAhead ? Colors.blue[400] : Colors.red[400],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              momentumLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isPlayerAhead ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              momentum.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
