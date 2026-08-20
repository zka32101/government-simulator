import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 「卓越した決定！」のような特に良い結果の際に、絵文字が舞い散る
/// 軽量な自作コンフェッティ演出（外部パッケージ非依存）。
/// 一度だけ再生され、フェードアウトして消える。
class CelebrationBurst extends StatefulWidget {
  final int particleCount;

  const CelebrationBurst({Key? key, this.particleCount = 16}) : super(key: key);

  @override
  State<CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<CelebrationBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  static const _emojis = ['🎉', '✨', '🎊', '⭐', '👏'];

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(widget.particleCount, (i) {
      final angle =
          (i / widget.particleCount) * 2 * math.pi + rng.nextDouble() * 0.4;
      return _Particle(
        emoji: _emojis[rng.nextInt(_emojis.length)],
        angle: angle,
        distance: 60 + rng.nextDouble() * 90,
        size: 16 + rng.nextDouble() * 14,
        delay: rng.nextDouble() * 0.25,
      );
    });
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: _particles.map((p) {
              // delay 分だけ開始を遅らせ、粒子ごとに時間差をつける。
              final t =
                  ((_ctrl.value - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
              final eased = Curves.easeOutCubic.transform(t);
              final dx = math.cos(p.angle) * p.distance * eased;
              // わずかに弧を描きながら飛び散らせる。
              final dy = math.sin(p.angle) * p.distance * eased * 0.6 -
                  40 * eased * (1 - eased);
              final opacity = (1 - t).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Opacity(
                  opacity: opacity,
                  child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _Particle {
  final String emoji;
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _Particle({
    required this.emoji,
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

/// 「失敗した決定」のような特に悪い結果の際に、対象ウィジェットを
/// 一度だけ左右に揺らして衝撃を演出する。
class ShakeOnce extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ShakeOnce({Key? key, required this.child, this.trigger = true})
      : super(key: key);

  @override
  State<ShakeOnce> createState() => _ShakeOnceState();
}

class _ShakeOnceState extends State<ShakeOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.trigger) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        // 振幅が時間とともに減衰する正弦波で左右に揺れる。
        final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
