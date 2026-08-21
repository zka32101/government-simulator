import 'package:flutter/material.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/utils/constants.dart';

/// 実績ギャラリー画面：全実績を一覧表示し、解除済み/未解除を可視化する。
///
/// ポップアップ通知（AchievementPopup）はその場限りで消えてしまうため、
/// いつでも「あと何が残っているか」を見返せる場所を用意することで、
/// 達成感・収集欲・次の目標設定を後押しする。
class AchievementsScreen extends StatefulWidget {
  final GameSession session;

  const AchievementsScreen({Key? key, required this.session})
      : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 実績一覧を上から一括表示するのではなく、上から順に軽く時間差で
    // フェード＋スライドインさせ、トロフィーの棚をひとつずつ見渡すような
    // 感覚を演出する。
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _staggered(int index, int total) {
    final start = (index / total * 0.6).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = Achievements.all;
    final unlockedIds = widget.session.unlockedAchievements.toSet();
    final unlockedCount = all.where((a) => unlockedIds.contains(a.id)).length;
    final isComplete = unlockedCount == all.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 実績'),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProgressHeader(
                unlockedCount: unlockedCount,
                total: all.length,
                isComplete: isComplete,
              ),
              const SizedBox(height: AppConstants.paddingM),
              ...List.generate(all.length, (i) {
                final a = all[i];
                final anim = _staggered(i, all.length);
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.paddingS),
                  child: FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.12),
                        end: Offset.zero,
                      ).animate(anim),
                      child: _AchievementTile(
                        achievement: a,
                        unlocked: unlockedIds.contains(a.id),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppConstants.paddingM),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int unlockedCount;
  final int total;
  final bool isComplete;

  const _ProgressHeader({
    required this.unlockedCount,
    required this.total,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlockedCount / total;
    final color = isComplete
        ? const Color(0xFFD4AF37)
        : Color(VisualConstants.colorPrimary);

    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isComplete ? '🎉 全実績コンプリート！' : '実績の進捗',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
                Text(
                  '$unlockedCount / $total',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingS),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // 開いた瞬間に達成率へ向かってバーが伸びていくよう、
              // 0 から progress へアニメーションさせる
              // （以前は AlwaysStoppedAnimation で最初から満たされた
              // 状態が瞬時に表示されるだけだった）。
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementTile({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color =
        unlocked ? const Color(0xFFD4AF37) : Colors.grey.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFD4AF37).withOpacity(0.08)
            : Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        border: Border.all(color: color, width: unlocked ? 1.4 : 1),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.35,
            child: Text(achievement.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: unlocked ? null : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.emoji_events : Icons.lock_outline,
            color: color,
            size: 22,
          ),
        ],
      ),
    );
  }
}
