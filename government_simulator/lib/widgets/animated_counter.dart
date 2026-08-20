import 'package:flutter/material.dart';

/// 数値が滑らかにカウントアップ/ダウンするテキスト。
class AnimatedCounter extends StatefulWidget {
  final double value;
  final int decimals;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 700),
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  // 現在画面に表示されている値。アニメーション中も毎フレーム更新される。
  // TweenAnimationBuilder ベースの旧実装は、アニメーション完了前に value が
  // 再び変化すると begin を「直前の目標値」(oldWidget.value) にしていたため、
  // アニメーションが実際に到達していた中間地点を無視してそこへ一瞬で
  // 飛んでから改めてアニメーションし直す、という視覚的な "ジャンプ" が
  // 起きていた（700ms未満の間隔で2回更新されると再現する）。
  // ここでは実際に表示中の値から常に滑らかに継続するようにする。
  late double _displayValue = widget.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = AlwaysStoppedAnimation(widget.value);
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateTo(widget.value);
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _displayValue, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        _displayValue = _animation.value;
        return Text(
          '${widget.prefix}${_displayValue.toStringAsFixed(widget.decimals)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// 旧値→新値へカウントアニメーションする（明示的に begin を指定）。
class TransitionCounter extends StatelessWidget {
  final double from;
  final double to;
  final int decimals;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  const TransitionCounter({
    Key? key,
    required this.from,
    required this.to,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from, end: to),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) => Text(
        '$prefix${val.toStringAsFixed(decimals)}$suffix',
        style: style,
      ),
    );
  }
}
