/// アニメーション設定・システム
/// 統一されたアニメーション構成とヘルパー関数

library;

import 'package:flutter/material.dart';

/// アニメーション設定（継続時間とカーブ）
class AnimationConfig {
  // 標準継続時間
  static const Duration veryShortDuration = Duration(milliseconds: 100);
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 800);
  static const Duration veryLongDuration = Duration(milliseconds: 1200);

  // 標準カーブ
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve snappyCurve = Curves.easeOutQuad;
  static const Curve springCurve = Curves.elasticOut;
  static const Curve bounceInCurve = Curves.elasticIn;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve smoothCurve = Curves.easeInCubic;
}

/// 討論会アニメーションビルダー
class DebateAnimations {
  /// スケールアニメーション（0.8 → 1.0）
  static Animation<double> buildScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
    Curve curve = AnimationConfig.snappyCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// フェードアニメーション（0.0 → 1.0）
  static Animation<double> buildFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = AnimationConfig.standardCurve,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// スライドアニメーション（左からスライドイン）
  static Animation<Offset> buildSlideInLeftAnimation(
    AnimationController controller, {
    Curve curve = AnimationConfig.snappyCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// スライドアニメーション（右からスライドイン）
  static Animation<Offset> buildSlideInRightAnimation(
    AnimationController controller, {
    Curve curve = AnimationConfig.snappyCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// スライドアニメーション（下からスライドイン）
  static Animation<Offset> buildSlideInUpAnimation(
    AnimationController controller, {
    Curve curve = AnimationConfig.snappyCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// バウンスアニメーション（スプリング効果）
  static Animation<double> buildBounceAnimation(
    AnimationController controller, {
    Curve curve = AnimationConfig.springCurve,
  }) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// スケッシュ効果（スケール + フェード）
  static List<Animation<double>> buildPopInAnimations(
    AnimationController controller, {
    Duration scaleDelay = Duration.zero,
    Duration fadeDuration = const Duration(milliseconds: 200),
  }) {
    final scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    return [scaleAnimation, fadeAnimation];
  }

  /// 回転アニメーション
  static Animation<double> buildRotateAnimation(
    AnimationController controller, {
    double fullRotations = 1.0,
    Curve curve = AnimationConfig.snappyCurve,
  }) {
    return Tween<double>(begin: 0.0, end: fullRotations * 2 * 3.14159).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  /// カラーアニメーション
  static Animation<Color?> buildColorAnimation(
    AnimationController controller, {
    required Color begin,
    required Color end,
    Curve curve = AnimationConfig.standardCurve,
  }) {
    return ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}

/// ページ遷移アニメーション
class PageTransitionAnimations {
  /// スライド左へ（ページ遷移：前へ）
  static Animation<Offset> buildSlideOutToLeftAnimation(
    AnimationController controller,
  ) {
    return Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInCubic),
    );
  }

  /// スライド右へ（ページ遷移：戻る）
  static Animation<Offset> buildSlideInFromRightAnimation(
    AnimationController controller,
  ) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
  }

  /// クロスフェード
  static Animation<double> buildCrossFadeAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad),
    );
  }
}

/// テキストアニメーション（タイプライター効果）
class TextAnimations {
  /// タイプライター効果
  static Animation<int> buildTypewriterAnimation(
    AnimationController controller, {
    required int textLength,
  }) {
    return IntTween(begin: 0, end: textLength).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
  }
}

/// スタッガーアニメーション（複数要素を順序付けて表示）
class StaggeredAnimations {
  /// リスト項目の交差フェード
  static List<Animation<double>> buildStaggeredFadeAnimations(
    AnimationController controller, {
    required int itemCount,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final animations = <Animation<double>>[];

    for (int i = 0; i < itemCount; i++) {
      final begin = (i * staggerDelay.inMilliseconds) /
          controller.duration!.inMilliseconds;
      final end = begin +
          (400 / controller.duration!.inMilliseconds); // 400ms per item

      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              begin.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
    }

    return animations;
  }

  /// リスト項目のスライドインアニメーション
  static List<Animation<Offset>> buildStaggeredSlideAnimations(
    AnimationController controller, {
    required int itemCount,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final animations = <Animation<Offset>>[];

    for (int i = 0; i < itemCount; i++) {
      final begin = (i * staggerDelay.inMilliseconds) /
          controller.duration!.inMilliseconds;
      final end = begin +
          (400 / controller.duration!.inMilliseconds); // 400ms per item

      animations.add(
        Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              begin.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    return animations;
  }
}

/// アニメーション遅延ビルダー
class DelayedAnimationBuilder extends StatefulWidget {
  final Widget Function(BuildContext, Animation<double>) builder;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const DelayedAnimationBuilder({
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    Key? key,
  }) : super(key: key);

  @override
  State<DelayedAnimationBuilder> createState() =>
      _DelayedAnimationBuilderState();
}

class _DelayedAnimationBuilderState extends State<DelayedAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
      builder: (context, child) => widget.builder(context, _animation),
    );
  }
}
