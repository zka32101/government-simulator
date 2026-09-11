/// スクリーン遷移アニメーション管理
/// 画面遷移時のスムーズなアニメーションを提供

import 'package:flutter/material.dart';
import 'package:government_simulator/utils/animation_configs.dart';

/// スクリーン遷移タイプ
enum TransitionType {
  /// 前へ遷移（右からスライドイン）
  slideFromRight,

  /// 戻る遷移（左からスライドイン）
  slideFromLeft,

  /// 同レベル遷移（クロスフェード）
  crossFade,

  /// 詳細/勝利画面遷移（スケールアップ）
  scaleUp,
}

/// スクリーン遷移サービス
/// 統一されたアニメーション遷移の実装
class ScreenTransitionService {
  /// アニメーション付きで新しい画面に遷移
  static Future<T?> navigateWithAnimation<T>({
    required BuildContext context,
    required Widget screen,
    required TransitionType type,
    Duration? duration,
  }) {
    final animationDuration = duration ?? AnimationConfig.mediumDuration;

    return Navigator.push(
      context,
      _createPageRoute<T>(
        screen: screen,
        type: type,
        duration: animationDuration,
      ),
    );
  }

  /// アニメーション付きで画面を置き換え
  static Future<T?> replaceWithAnimation<T>({
    required BuildContext context,
    required Widget screen,
    required TransitionType type,
    Duration? duration,
  }) {
    final animationDuration = duration ?? AnimationConfig.mediumDuration;

    return Navigator.pushReplacement(
      context,
      _createPageRoute<T>(
        screen: screen,
        type: type,
        duration: animationDuration,
      ),
    );
  }

  /// アニメーション付きで画面スタックをクリアして遷移
  static Future<T?> navigateAndRemoveUntil<T>({
    required BuildContext context,
    required Widget screen,
    required TransitionType type,
    required RoutePredicate predicate,
    Duration? duration,
  }) {
    final animationDuration = duration ?? AnimationConfig.mediumDuration;

    return Navigator.pushAndRemoveUntil(
      context,
      _createPageRoute<T>(
        screen: screen,
        type: type,
        duration: animationDuration,
      ),
      predicate,
    );
  }

  /// PageRouteを生成
  static PageRoute<T> _createPageRoute<T>({
    required Widget screen,
    required TransitionType type,
    required Duration duration,
  }) {
    return switch (type) {
      TransitionType.slideFromRight =>
        _SlidePageRoute<T>(
          child: screen,
          duration: duration,
          beginOffset: const Offset(1.0, 0.0),
        ),
      TransitionType.slideFromLeft =>
        _SlidePageRoute<T>(
          child: screen,
          duration: duration,
          beginOffset: const Offset(-1.0, 0.0),
        ),
      TransitionType.crossFade =>
        _FadePageRoute<T>(
          child: screen,
          duration: duration,
        ),
      TransitionType.scaleUp =>
        _ScalePageRoute<T>(
          child: screen,
          duration: duration,
        ),
    };
  }
}

/// スライドアニメーション付きPageRoute
class _SlidePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  _SlidePageRoute({
    required this.child,
    required this.duration,
    required this.beginOffset,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    // 逆方向のアニメーション
    final reverseSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: beginOffset * -0.3).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic),
    );

    return SlideTransition(
      position: animation.status == AnimationStatus.forward
          ? slideAnimation
          : reverseSlideAnimation,
      child: child,
    );
  }
}

/// フェードアニメーション付きPageRoute
class _FadePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  _FadePageRoute({
    required this.child,
    required this.duration,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// スケールアニメーション付きPageRoute
class _ScalePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  _ScalePageRoute({
    required this.child,
    required this.duration,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
