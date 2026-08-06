import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/weekly_poll.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 週替わり全国民投票。全プレイヤーが同じ週は同じ設問に投票し、
/// 全国の選択割合をリアルタイムに近い形で確認できる。
class WeeklyPollScreen extends ConsumerStatefulWidget {
  const WeeklyPollScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WeeklyPollScreen> createState() => _WeeklyPollScreenState();
}

class _WeeklyPollScreenState extends ConsumerState<WeeklyPollScreen> {
  late final String _weekId;
  late final WeeklyPollQuestion _question;
  bool _loading = true;
  String? _myVote;
  Map<String, int> _counts = {'A': 0, 'B': 0};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final current = WeeklyPollQuestion.current();
    _weekId = current.weekId;
    _question = current.question;
    _load();
  }

  Future<void> _load() async {
    final firestore = ref.read(firestoreServiceProvider);
    final userId = ref.read(authServiceProvider).userId ?? 'demo';
    final vote = await firestore.getUserVote(_weekId, userId);
    final counts = await firestore.getPollCounts(_weekId);
    if (!mounted) return;
    setState(() {
      _myVote = vote;
      _counts = counts;
      _loading = false;
    });
  }

  Future<void> _vote(String choice) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final firestore = ref.read(firestoreServiceProvider);
    final userId = ref.read(authServiceProvider).userId ?? 'demo';
    final ok = await firestore.submitVote(_weekId, userId, choice);
    final counts = await firestore.getPollCounts(_weekId);
    if (!mounted) return;
    setState(() {
      if (ok) _myVote = choice;
      _counts = counts;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('🗳️ 今週の全国民投票')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(_question.emoji,
                        style: const TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _question.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _question.description,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '週ID: $_weekId ・ 全プレイヤー共通の設問です',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_myVote == null)
                    ..._buildVoteButtons()
                  else
                    _buildResults(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildVoteButtons() {
    return [
      _VoteButton(
        label: _question.choiceALabel,
        onTap: _submitting ? null : () => _vote('A'),
      ),
      const SizedBox(height: 12),
      _VoteButton(
        label: _question.choiceBLabel,
        onTap: _submitting ? null : () => _vote('B'),
      ),
    ];
  }

  Widget _buildResults() {
    final total = _counts['A']! + _counts['B']!;
    final pctA = total == 0 ? 0.0 : _counts['A']! / total * 100;
    final pctB = total == 0 ? 0.0 : _counts['B']! / total * 100;
    final myLabel =
        _myVote == 'A' ? _question.choiceALabel : _question.choiceBLabel;
    final myPct = _myVote == 'A' ? pctA : pctB;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3A2E10), AppTheme.surface],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
          ),
          child: Text(
            'あなたは「$myLabel」を選びました。\n'
            '全国の${myPct.toStringAsFixed(0)}%が同じ選択をしています。',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        _ResultBar(
          label: _question.choiceALabel,
          percent: pctA,
          count: _counts['A']!,
          highlight: _myVote == 'A',
        ),
        const SizedBox(height: 12),
        _ResultBar(
          label: _question.choiceBLabel,
          percent: pctB,
          count: _counts['B']!,
          highlight: _myVote == 'B',
        ),
        const SizedBox(height: 16),
        Text('総投票数: $total',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _VoteButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPrimary,
        side: BorderSide(color: AppTheme.gold.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}

class _ResultBar extends StatelessWidget {
  final String label;
  final double percent;
  final int count;
  final bool highlight;

  const _ResultBar({
    required this.label,
    required this.percent,
    required this.count,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppTheme.gold : AppTheme.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: highlight ? color : AppTheme.textPrimary)),
            ),
            Text('${percent.toStringAsFixed(0)}% ($count票)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (context, frac, _) => LinearProgressIndicator(
              value: frac,
              minHeight: 10,
              backgroundColor: Colors.black.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}
