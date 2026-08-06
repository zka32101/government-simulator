import 'package:flutter/material.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 大臣の裏切り・公約の結末など、物語上の出来事を知らせる汎用トースト。
class StoryBanner {
  static void show(BuildContext context, List<String> narratives) {
    if (narratives.isEmpty) return;
    _showOne(context, narratives, 0);
  }

  static void _showOne(BuildContext context, List<String> list, int index) {
    if (index >= list.length) return;
    if (!context.mounted) return; // 表示中に呼び出し元が破棄された場合の保険
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _StoryBannerCard(
        message: list[index],
        onDone: () {
          entry.remove();
          _showOne(context, list, index + 1);
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _StoryBannerCard extends StatefulWidget {
  final String message;
  final VoidCallback onDone;

  const _StoryBannerCard({required this.message, required this.onDone});

  @override
  State<_StoryBannerCard> createState() => _StoryBannerCardState();
}

class _StoryBannerCardState extends State<_StoryBannerCard>
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
    Future.delayed(const Duration(milliseconds: 3400), () async {
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
                colors: [Color(0xFF3A1212), AppTheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.danger, width: 1.4),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.danger.withOpacity(0.3),
                    blurRadius: 18,
                    spreadRadius: 1),
              ],
            ),
            child: Row(
              children: [
                const Text('📰', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
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
