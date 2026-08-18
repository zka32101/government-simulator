import 'package:flutter/material.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// Reigns 式のスワイプ政策カード。
/// 左右スワイプで choices[0]/choices[1] を選択。3択以上は下部ボタン。
class PolicyCard extends StatefulWidget {
  final GameEvent event;
  final String advisorEmoji;
  final void Function(Choice choice) onChoose;

  const PolicyCard({
    Key? key,
    required this.event,
    required this.advisorEmoji,
    required this.onChoose,
  }) : super(key: key);

  @override
  State<PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<PolicyCard>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _dismissing = false;

  static const double _threshold = 110;

  Choice? get _leftChoice =>
      widget.event.choices.isNotEmpty ? widget.event.choices[0] : null;
  Choice? get _rightChoice =>
      widget.event.choices.length > 1 ? widget.event.choices[1] : null;

  // 派閥への公約となる選択肢には目印を付ける（二枚舌外交システム）。
  String _label(Choice? c) {
    if (c == null) return '';
    return c.promiseTarget != null ? '🤝 ${c.text}' : c.text;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dismissing) return;
    setState(() => _dx += d.delta.dx);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_dx.abs() > _threshold) {
      final choice = _dx < 0 ? _leftChoice : _rightChoice;
      if (choice != null) {
        _commit(choice, _dx < 0 ? -1 : 1);
        return;
      }
    }
    setState(() => _dx = 0); // 戻す
  }

  void _commit(Choice choice, int dir) {
    setState(() {
      _dismissing = true;
      _dx = dir * 600.0;
    });
    Future.delayed(const Duration(milliseconds: 220), () {
      widget.onChoose(choice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rot = (_dx / 1400).clamp(-0.18, 0.18);
    final leftActive = _dx < -30;
    final rightActive = _dx > 30;
    final progress = (_dx.abs() / _threshold).clamp(0.0, 1.0);

    return Column(
      children: [
        // スワイプ方向のヒントラベル
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: _SwipeHint(
                  text: _label(_leftChoice),
                  icon: Icons.arrow_back,
                  active: leftActive,
                  opacity: leftActive ? progress : 0.35,
                  align: TextAlign.left,
                ),
              ),
              Expanded(
                child: _SwipeHint(
                  text: _label(_rightChoice),
                  icon: Icons.arrow_forward,
                  active: rightActive,
                  opacity: rightActive ? progress : 0.35,
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // カード本体
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: AnimatedContainer(
            duration: _dismissing
                ? const Duration(milliseconds: 220)
                : (_dx == 0
                    ? const Duration(milliseconds: 280)
                    : Duration.zero),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(_dx)
              ..rotateZ(rot),
            transformAlignment: Alignment.center,
            child: _CardFace(
              event: widget.event,
              advisorEmoji: widget.advisorEmoji,
              tintLeft: leftActive ? progress : 0,
              tintRight: rightActive ? progress : 0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 操作ヒント
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              'カードを左右にスワイプして決断',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),

        // 3択以上：追加選択肢ボタン
        if (widget.event.choices.length > 2) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 4),
          Text('その他の選択肢',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 8),
          ...widget.event.choices.skip(2).map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.onChoose(c),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.15)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_label(c),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          if (c.shortDescription.isNotEmpty)
                            Text(c.shortDescription,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool active;
  final double opacity;
  final TextAlign align;

  const _SwipeHint({
    required this.text,
    required this.icon,
    required this.active,
    required this.opacity,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final color = active ? AppTheme.gold : AppTheme.textSecondary;
    final left = align == TextAlign.left;
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment:
            left ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (left) Icon(icon, size: 16, color: color),
          if (left) const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              textAlign: align,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (!left) const SizedBox(width: 4),
          if (!left) Icon(icon, size: 16, color: color),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final GameEvent event;
  final String advisorEmoji;
  final double tintLeft;
  final double tintRight;

  const _CardFace({
    required this.event,
    required this.advisorEmoji,
    required this.tintLeft,
    required this.tintRight,
  });

  @override
  Widget build(BuildContext context) {
    final tint = tintLeft > 0
        ? AppTheme.danger.withOpacity(tintLeft * 0.25)
        : tintRight > 0
            ? AppTheme.good.withOpacity(tintRight * 0.25)
            : Colors.transparent;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceLight, AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // スワイプ色付け
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // カテゴリバッジ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '📋 ${event.category.label}',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 大臣アバター + タイトル
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.gold.withOpacity(0.4)),
                      ),
                      child: Text(advisorEmoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 本文（吹き出し風）
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
