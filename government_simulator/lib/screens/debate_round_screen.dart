import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/debate.dart';
import 'package:government_simulator/models/debate_choice.dart';
import 'package:government_simulator/utils/animation_configs.dart';
import 'debate_round_result_screen.dart';

/// 討論会ラウンド画面
/// プレイヤーがトーンと強調を選択してラウンドを進める（アニメーション付き）
class DebateRoundScreen extends ConsumerStatefulWidget {
  final Debate debate;
  final int currentRoundIndex;

  const DebateRoundScreen({
    required this.debate,
    required this.currentRoundIndex,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DebateRoundScreen> createState() =>
      _DebateRoundScreenState();
}

class _DebateRoundScreenState extends ConsumerState<DebateRoundScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _staggeredAnimations;

  ArgumentTone? selectedTone;
  EmphasisType? selectedEmphasis;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // 複数要素のスタガーアニメーション（4要素）
    _staggeredAnimations =
        StaggeredAnimations.buildStaggeredFadeAnimations(
      _controller,
      itemCount: 4,
      staggerDelay: const Duration(milliseconds: 150),
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
    final round = widget.debate.rounds[widget.currentRoundIndex];
    final totalRounds = widget.debate.rounds.length;
    final isLastRound = widget.currentRoundIndex == totalRounds - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${round.topic.label} - ラウンド ${widget.currentRoundIndex + 1}/$totalRounds'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 進行状況インジケーター（フェード）
            FadeTransition(
              opacity: _staggeredAnimations[0],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _RoundProgressIndicator(
                  currentRound: widget.currentRoundIndex + 1,
                  totalRounds: totalRounds,
                ),
              ),
            ),

            // 声明文表示（スライドアップ + フェード）
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: _staggeredAnimations[0],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _StatementDisplayCard(
                    playerStatement: round.playerStatement,
                    rivalStatement: round.rivalStatement,
                    opponentName: widget.debate.opponentName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // トーン選択（スタガー + スライド）
            FadeTransition(
              opacity: _staggeredAnimations[1],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.3, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ArgumentToneSelector(
                    selectedTone: selectedTone,
                    onToneSelected: (tone) {
                      setState(() => selectedTone = tone);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 強調選択（スタガー + スライド）
            FadeTransition(
              opacity: _staggeredAnimations[2],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EmphasisSelector(
                    selectedEmphasis: selectedEmphasis,
                    onEmphasisSelected: (emphasis) {
                      setState(() => selectedEmphasis = emphasis);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ボタン（最後にフェード）
            FadeTransition(
              opacity: _staggeredAnimations[3],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedTone != null && selectedEmphasis != null
                        ? () => _submitRound(context, isLastRound)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isLastRound ? '討論会を終了' : '次のラウンドへ',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRound(BuildContext context, bool isLastRound) {
    // ここでラウンド結果画面へ遷移
    if (selectedTone == null || selectedEmphasis == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DebateRoundResultScreen(
          debate: widget.debate,
          currentRoundIndex: widget.currentRoundIndex,
          selectedTone: selectedTone!,
          selectedEmphasis: selectedEmphasis!,
          isLastRound: isLastRound,
        ),
      ),
    );
  }
}

/// ラウンド進行状況インジケーター
class _RoundProgressIndicator extends StatelessWidget {
  final int currentRound;
  final int totalRounds;

  const _RoundProgressIndicator({
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ラウンド進行状況',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '$currentRound/$totalRounds',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentRound / totalRounds,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// 声明文表示カード
class _StatementDisplayCard extends StatelessWidget {
  final String playerStatement;
  final String rivalStatement;
  final String opponentName;

  const _StatementDisplayCard({
    required this.playerStatement,
    required this.rivalStatement,
    required this.opponentName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // プレイヤーの主張
        Card(
          elevation: 2,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'あなたの主張',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  playerStatement,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 対戦相手の主張
        Card(
          elevation: 2,
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$opponentNameの主張',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  rivalStatement,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 議論トーンセレクター
class _ArgumentToneSelector extends StatelessWidget {
  final ArgumentTone? selectedTone;
  final Function(ArgumentTone) onToneSelected;

  const _ArgumentToneSelector({
    required this.selectedTone,
    required this.onToneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの議論スタイルを選択',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...ArgumentTone.values.map(
          (tone) => _ToneOption(
            tone: tone,
            isSelected: selectedTone == tone,
            onSelected: () => onToneSelected(tone),
          ),
        ),
      ],
    );
  }
}

/// トーンオプション
class _ToneOption extends StatelessWidget {
  final ArgumentTone tone;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ToneOption({
    required this.tone,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue[50] : Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tone.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tone.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 強調セレクター
class _EmphasisSelector extends StatelessWidget {
  final EmphasisType? selectedEmphasis;
  final Function(EmphasisType) onEmphasisSelected;

  const _EmphasisSelector({
    required this.selectedEmphasis,
    required this.onEmphasisSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あなたの強調ポイントを選択',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...EmphasisType.values.map(
          (emphasis) => _EmphasisOption(
            emphasis: emphasis,
            isSelected: selectedEmphasis == emphasis,
            onSelected: () => onEmphasisSelected(emphasis),
          ),
        ),
      ],
    );
  }
}

/// 強調オプション
class _EmphasisOption extends StatelessWidget {
  final EmphasisType emphasis;
  final bool isSelected;
  final VoidCallback onSelected;

  const _EmphasisOption({
    required this.emphasis,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.purple[50] : Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emphasis.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emphasis.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
