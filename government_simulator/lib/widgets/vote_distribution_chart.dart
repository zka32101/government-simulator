/// 投票分布の可視化ウィジェット
/// 円グラフと棒グラフで投票分布をアニメーション表示
library;

import 'package:flutter/material.dart';

/// 投票分布チャートウィジェット
class VoteDistributionChart extends StatefulWidget {
  /// 投票分布データ（候補者名 → 投票率）
  final Map<String, double> voteDistribution;

  /// 候補者別の色
  final Map<String, Color>? candidateColors;

  /// アニメーション継続時間
  final Duration animationDuration;

  const VoteDistributionChart({
    required this.voteDistribution,
    this.candidateColors,
    this.animationDuration = const Duration(milliseconds: 1200),
    Key? key,
  }) : super(key: key);

  @override
  State<VoteDistributionChart> createState() => _VoteDistributionChartState();
}

class _VoteDistributionChartState extends State<VoteDistributionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '投票分布',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Column(
                  children: [
                    // 棒グラフ
                    _AnimatedBarChart(
                      voteDistribution: widget.voteDistribution,
                      candidateColors: widget.candidateColors,
                      animation: _animation,
                    ),
                    const SizedBox(height: 24),
                    // 凡例
                    _VoteLegend(
                      voteDistribution: widget.voteDistribution,
                      candidateColors: widget.candidateColors,
                      animation: _animation,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// アニメーション付き棒グラフ
class _AnimatedBarChart extends StatelessWidget {
  final Map<String, double> voteDistribution;
  final Map<String, Color>? candidateColors;
  final Animation<double> animation;

  const _AnimatedBarChart({
    required this.voteDistribution,
    required this.candidateColors,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // 投票率でソート（高い順）
    final sortedEntries = voteDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: List.generate(
        sortedEntries.length,
        (index) {
          final entry = sortedEntries[index];
          final percent = entry.value;
          final color = _getColor(entry.key, index);

          // 各バーのアニメーション開始時間をずらす
          final barDelay = index * 0.15; // 150ms stagger
          final barAnimationValue = (animation.value - barDelay).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        // カウントアップアニメーション
                        final displayValue = (percent * animation.value)
                            .toStringAsFixed(1);
                        return Text(
                          '$displayValue%',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: barAnimationValue,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String candidateName, int index) {
    if (candidateColors != null && candidateColors!.containsKey(candidateName)) {
      return candidateColors![candidateName]!;
    }

    // デフォルト色
    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.green[600]!,
    ];

    return colors[index % colors.length];
  }
}

/// 投票分布の凡例
class _VoteLegend extends StatelessWidget {
  final Map<String, double> voteDistribution;
  final Map<String, Color>? candidateColors;
  final Animation<double> animation;

  const _VoteLegend({
    required this.voteDistribution,
    required this.candidateColors,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // 投票率でソート（高い順）
    final sortedEntries = voteDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(
        sortedEntries.length,
        (index) {
          final entry = sortedEntries[index];
          final color = _getColor(entry.key, index);

          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.5 + (index * 0.1),
                  1.0,
                  curve: Curves.easeOutBack,
                ),
              ),
            ),
            child: _LegendItem(
              label: entry.key,
              color: color,
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String candidateName, int index) {
    if (candidateColors != null && candidateColors!.containsKey(candidateName)) {
      return candidateColors![candidateName]!;
    }

    // デフォルト色
    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.green[600]!,
    ];

    return colors[index % colors.length];
  }
}

/// 凡例アイテム
class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// シンプルな投票分布表示ウィジェット（アニメーションなし）
class SimpleVoteDistribution extends StatelessWidget {
  final Map<String, double> voteDistribution;
  final Map<String, Color>? candidateColors;

  const SimpleVoteDistribution({
    required this.voteDistribution,
    this.candidateColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 投票率でソート（高い順）
    final sortedEntries = voteDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        sortedEntries.length,
        (index) {
          final entry = sortedEntries[index];
          final percent = entry.value;
          final color = _getColor(entry.key, index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 20,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String candidateName, int index) {
    if (candidateColors != null && candidateColors!.containsKey(candidateName)) {
      return candidateColors![candidateName]!;
    }

    // デフォルト色
    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.green[600]!,
    ];

    return colors[index % colors.length];
  }
}
