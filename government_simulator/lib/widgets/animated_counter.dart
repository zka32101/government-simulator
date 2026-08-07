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

class _AnimatedCounterState extends State<AnimatedCounter> {
  late double _previousValue = widget.value;

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 直前にビルドされた値から今回の値へアニメーションする。
    // 以前は Tween(begin: value, end: value) と同じ値同士でトゥイーン
    // していたため、数値が一切アニメーションせず瞬時に切り替わっていた。
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previousValue, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '${widget.prefix}${val.toStringAsFixed(widget.decimals)}${widget.suffix}',
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
