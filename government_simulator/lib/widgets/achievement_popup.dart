import 'package:flutter/material.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 実績解除トースト。複数を順番に表示する。
class AchievementPopup {
  static void show(BuildContext context, List<Achievement> achievements) {
    if (achievements.isEmpty) return;
    _showOne(context, achievements, 0);
  }

  static void _showOne(
      BuildContext context, List<Achievement> list, int index) {
    if (index >= list.length) return;
    // 複数の実績を順番に表示している間に、呼び出し元の画面が
    // 破棄される（遷移等）と、この context は無効になる。story_banner.dart
    // の _showOne は元々このチェックを持っていたが、こちらには無く、
    // Overlay.of(context) が deactivated widget に対して呼ばれ例外に
    // なることがあった。
    if (!context.mounted) return;
    final a = list[index];
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _AchievementBanner(
        achievement: a,
        onDone: () {
          entry.remove();
          _showOne(context, list, index + 1);
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _AchievementBanner extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDone;

  const _AchievementBanner({
    required this.achievement,
    required this.onDone,
  });

  @override
  State<_AchievementBanner> createState() => _AchievementBannerState();
}

class _AchievementBannerState extends State<_AchievementBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A2E10), AppTheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.gold, width: 1.4),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.gold.withOpacity(0.3),
                    blurRadius: 18,
                    spreadRadius: 1),
              ],
            ),
            child: Row(
              children: [
                Text(a.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏆 実績解除！',
                          style: TextStyle(
                              color: AppTheme.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(a.title,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(a.description,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
