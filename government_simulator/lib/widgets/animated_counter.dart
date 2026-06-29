import 'package:flutter/material.dart';

/// 数値が滑らかにカウントアップ/ダウンするテキスト。
class AnimatedCounter extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '$prefix${val.toStringAsFixed(decimals)}$suffix',
          style: style,
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
