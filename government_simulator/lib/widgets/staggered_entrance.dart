import 'package:flutter/material.dart';

/// リストやグリッドの各項目を、表示された順番に軽い時間差をつけて
/// フェード＋スライドインさせる汎用ラッパー。
///
/// ListView.separated 等の遅延ビルドでも項目ごとに独立して動作するよう、
/// 親側で共有の AnimationController は持たず、各項目が自前のタイマーで
/// 開始をずらす方式にしている（スクロールで新しい項目が遅れて
/// ビルドされても、その項目自身がその時点から短い時間差で登場する）。
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration stepDelay;
  final Duration duration;

  const StaggeredEntrance({
    Key? key,
    required this.index,
    required this.child,
    this.stepDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 350),
  }) : super(key: key);

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    // index が大きいほど開始を遅らせ、上から順に登場して見えるようにする。
    // 大量の項目があっても各 Timer は一度発火して破棄されるだけなので
    // 問題にならない。
    Future.delayed(widget.stepDelay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(anim),
        child: widget.child,
      ),
    );
  }
}
