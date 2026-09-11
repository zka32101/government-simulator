import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/rival_candidate.dart';
import 'package:government_simulator/providers/game_provider.dart';

/// 討論会準備画面
/// 対戦相手のプロフィール、トピックのプレビュー、戦略のヒントを表示
class DebatePreparationScreen extends ConsumerStatefulWidget {
  final Debate debate;

  const DebatePreparationScreen({
    required this.debate,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DebatePreparationScreen> createState() =>
      _DebatePreparationScreenState();
}

class _DebatePreparationScreenState
    extends ConsumerState<DebatePreparationScreen> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);

    if (session.session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gameSession = session.session!;
    final opponent = gameSession.rivalCandidates.firstWhere(
      (r) => r.id == widget.debate.opponentId,
      orElse: () => RivalCandidate(
        id: widget.debate.opponentId,
        name: widget.debate.opponentName,
        supportRating: 40,
        economicPolicy: 50,
        socialPolicy: 50,
        militaryPolicy: 50,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('討論会準備'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 対戦相手プロフィールカード
            _OpponentProfileCard(opponent: opponent),
            const SizedBox(height: 24),

            // トピックプレビュー
            _DebateTopicsPreview(debate: widget.debate),
            const SizedBox(height: 24),

            // 戦略ヒント
            _StrategyTipsWidget(
              session: gameSession,
              opponent: opponent,
            ),
            const SizedBox(height: 32),

            // ボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('中止する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/debate_round',
                        arguments: widget.debate,
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('討論会を開始'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 対戦相手プロフィールカード
class _OpponentProfileCard extends StatelessWidget {
  final RivalCandidate opponent;

  const _OpponentProfileCard({required this.opponent});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名前と支持率
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponent.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '対戦相手の支持率',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getSupportColor(opponent.supportRating),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${opponent.supportRating.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 政策スタンス
            Text(
              '政策スタンス',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _PolicyStanceRow(
              label: '経済',
              value: opponent.economicPolicy,
            ),
            const SizedBox(height: 8),
            _PolicyStanceRow(
              label: '社会',
              value: opponent.socialPolicy,
            ),
            const SizedBox(height: 8),
            _PolicyStanceRow(
              label: '軍事',
              value: opponent.militaryPolicy,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSupportColor(double support) {
    if (support >= 45) return Colors.red[600]!;
    if (support >= 35) return Colors.orange[600]!;
    return Colors.green[600]!;
  }
}

/// 政策スタンス表示行
class _PolicyStanceRow extends StatelessWidget {
  final String label;
  final double value;

  const _PolicyStanceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForValue(value),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 60) return Colors.blue;
    if (value >= 40) return Colors.purple;
    return Colors.orange;
  }
}

/// 討論会トピックプレビュー
class _DebateTopicsPreview extends StatelessWidget {
  final Debate debate;

  const _DebateTopicsPreview({required this.debate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '討論会のトピック',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (debate.rounds.isNotEmpty)
                  ...debate.rounds
                      .asMap()
                      .entries
                      .map(
                        (entry) => _TopicItem(
                          roundNumber: entry.key + 1,
                          topic: entry.value.topic,
                          isLast: entry.key == debate.rounds.length - 1,
                        ),
                      )
                      .toList()
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'トピックがまだ決定されていません',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// トピックアイテム
class _TopicItem extends StatelessWidget {
  final int roundNumber;
  final DebateTopic topic;
  final bool isLast;

  const _TopicItem({
    required this.roundNumber,
    required this.topic,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  'R$roundNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topic.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 0),
      ],
    );
  }
}

/// 戦略ヒントウィジェット
class _StrategyTipsWidget extends StatelessWidget {
  final GameSession session;
  final RivalCandidate opponent;

  const _StrategyTipsWidget({
    required this.session,
    required this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    final tips = _generateTips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '戦略のヒント',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...tips.asMap().entries.map(
          (entry) => _TipItem(
            icon: entry.value['icon'] as IconData,
            title: entry.value['title'] as String,
            description: entry.value['description'] as String,
            color: entry.value['color'] as Color,
            isLast: entry.key == tips.length - 1,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateTips() {
    final tips = <Map<String, dynamic>>[];

    // 満足度がある場合のヒント
    if (session.status.satisfaction > 70) {
      tips.add({
        'icon': Icons.trending_up,
        'title': '支持率が高い',
        'description': '防御的な主張で現状維持を狙うのが得策です',
        'color': Colors.green,
      });
    } else if (session.status.satisfaction < 40) {
      tips.add({
        'icon': Icons.trending_down,
        'title': '支持率が低い',
        'description': 'より攻撃的な主張で逆転を狙いましょう',
        'color': Colors.red,
      });
    }

    // 対戦相手の強さに関するヒント
    if (opponent.supportRating >= 45) {
      tips.add({
        'icon': Icons.warning,
        'title': '相手は強敵です',
        'description': 'テレキャストが起きやすいので慎重に戦いましょう',
        'color': Colors.orange,
      });
    } else {
      tips.add({
        'icon': Icons.check_circle,
        'title': '有利な状況',
        'description': '積極的に攻撃して差を広げましょう',
        'color': Colors.green,
      });
    }

    // 名声に関するヒント
    if (session.playerReputation < 40) {
      tips.add({
        'icon': Icons.info,
        'title': '名声が低い',
        'description': '正直で誠実な発言が効果的です',
        'color': Colors.blue,
      });
    }

    return tips;
  }
}

/// ヒントアイテム
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLast;

  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
