/// レスポンシブレイアウト管理
/// 様々な画面サイズに対応するブレークポイントとレイアウトヘルパー

library;

import 'package:flutter/material.dart';

/// レスポンシブレイアウトユーティリティ
/// ブレークポイントに基づくレイアウト調整を提供
class ResponsiveLayout {
  /// 小型スマートフォン（< 360px）
  static const double smallPhoneBreakpoint = 360;

  /// 通常スマートフォン（360-600px）
  static const double mediumPhoneBreakpoint = 600;

  /// 小型タブレット（600-840px）
  static const double tabletBreakpoint = 840;

  /// 小型スマートフォンか判定
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < smallPhoneBreakpoint;
  }

  /// 通常スマートフォンか判定
  static bool isMediumPhone(BuildContext context) {
    return MediaQuery.of(context).size.width >= smallPhoneBreakpoint &&
        MediaQuery.of(context).size.width < mediumPhoneBreakpoint;
  }

  /// スマートフォンか判定（小型または通常）
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumPhoneBreakpoint;
  }

  /// 小型タブレットか判定
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumPhoneBreakpoint &&
        MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// デスクトップか判定
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// 画面の幅を取得
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 画面の高さを取得
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 適切なパディングを取得
  static EdgeInsets getPadding(BuildContext context) {
    final width = getWidth(context);

    if (width < smallPhoneBreakpoint) {
      // 小型スマートフォン：8ptパディング
      return const EdgeInsets.all(8);
    } else if (width < mediumPhoneBreakpoint) {
      // 通常スマートフォン：12ptパディング
      return const EdgeInsets.all(12);
    } else if (width < tabletBreakpoint) {
      // タブレット：16ptパディング
      return const EdgeInsets.all(16);
    } else {
      // デスクトップ：24ptパディング
      return const EdgeInsets.all(24);
    }
  }

  /// グリッドの列数を取得
  static int getGridColumns(BuildContext context) {
    final width = getWidth(context);

    if (width < mediumPhoneBreakpoint) {
      return 1; // スマートフォン：1列
    } else if (width < tabletBreakpoint) {
      return 2; // 小型タブレット：2列
    } else {
      return 3; // デスクトップ：3列
    }
  }

  /// カード幅を取得
  static double getCardWidth(BuildContext context) {
    final width = getWidth(context);
    final padding = getPadding(context);

    final availableWidth = width - (padding.left + padding.right) - 16;

    if (width < mediumPhoneBreakpoint) {
      return availableWidth; // スマートフォン：フル幅
    } else if (width < tabletBreakpoint) {
      return (availableWidth - 8) / 2; // タブレット：2列
    } else {
      return (availableWidth - 16) / 3; // デスクトップ：3列
    }
  }

  /// ボタンの高さを取得
  static double getButtonHeight(BuildContext context) {
    if (isSmallPhone(context)) {
      return 44; // スマートフォン：44pt
    } else {
      return 48; // その他：48pt
    }
  }

  /// タッチターゲットのサイズ（最小48pt）を取得
  static double getTouchTargetSize(BuildContext context) {
    return 48;
  }

  /// テキストのフォントサイズ調整係数を取得
  static double getFontSizeMultiplier(BuildContext context) {
    if (isSmallPhone(context)) {
      return 0.9; // 小型スマートフォン：-10%
    } else if (isDesktop(context)) {
      return 1.1; // デスクトップ：+10%
    } else {
      return 1.0; // その他：100%
    }
  }

  /// ボタンのパディングを取得
  static EdgeInsets getButtonPadding(BuildContext context) {
    if (isSmallPhone(context)) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
    } else if (isMediumPhone(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 14);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  /// カードのパディングを取得
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isSmallPhone(context)) {
      return const EdgeInsets.all(12);
    } else if (isMediumPhone(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  /// カード間隔を取得
  static double getCardSpacing(BuildContext context) {
    if (isSmallPhone(context)) {
      return 8;
    } else if (isMediumPhone(context)) {
      return 12;
    } else {
      return 16;
    }
  }

  /// ヘッドラインのフォントサイズを取得
  static double getHeadlineFontSize(BuildContext context) {
    final multiplier = getFontSizeMultiplier(context);

    if (isSmallPhone(context)) {
      return 18 * multiplier;
    } else if (isMediumPhone(context)) {
      return 20 * multiplier;
    } else {
      return 24 * multiplier;
    }
  }

  /// ボディテキストのフォントサイズを取得
  static double getBodyFontSize(BuildContext context) {
    final multiplier = getFontSizeMultiplier(context);

    if (isSmallPhone(context)) {
      return 12 * multiplier;
    } else if (isMediumPhone(context)) {
      return 14 * multiplier;
    } else {
      return 16 * multiplier;
    }
  }

  /// ラベルのフォントサイズを取得
  static double getLabelFontSize(BuildContext context) {
    final multiplier = getFontSizeMultiplier(context);

    if (isSmallPhone(context)) {
      return 10 * multiplier;
    } else if (isMediumPhone(context)) {
      return 11 * multiplier;
    } else {
      return 12 * multiplier;
    }
  }

  /// 最大コンテンツ幅を取得
  static double getMaxContentWidth(BuildContext context) {
    final width = getWidth(context);

    if (isDesktop(context)) {
      return 1200; // デスクトップ：最大1200px
    } else {
      return width - (getPadding(context).left + getPadding(context).right);
    }
  }

  /// リスト項目の高さを取得
  static double getListItemHeight(BuildContext context) {
    if (isSmallPhone(context)) {
      return 56;
    } else if (isMediumPhone(context)) {
      return 60;
    } else {
      return 64;
    }
  }

  /// アイコンサイズを取得
  static double getIconSize(BuildContext context, {bool large = false}) {
    if (large) {
      if (isSmallPhone(context)) {
        return 32;
      } else if (isMediumPhone(context)) {
        return 40;
      } else {
        return 48;
      }
    } else {
      if (isSmallPhone(context)) {
        return 20;
      } else if (isMediumPhone(context)) {
        return 24;
      } else {
        return 28;
      }
    }
  }

  /// 円角のサイズを取得
  static double getBorderRadius(BuildContext context) {
    if (isSmallPhone(context)) {
      return 8;
    } else if (isMediumPhone(context)) {
      return 10;
    } else {
      return 12;
    }
  }

  /// 横向きか判定
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 縦向きか判定
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// セーフエリアの内部パディングを考慮したパディングを取得
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding;
  }
}

/// レスポンシブウィジェットビルダー
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isPhone, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ResponsiveLayout.isPhone(context),
      ResponsiveLayout.isTablet(context),
      ResponsiveLayout.isDesktop(context),
    );
  }
}

/// デバイスタイプ
enum DeviceType {
  /// 小型スマートフォン（< 360px）
  smallPhone,

  /// 通常スマートフォン（360-600px）
  phone,

  /// タブレット（600-840px）
  tablet,

  /// デスクトップ（840px+）
  desktop,
}

/// デバイスタイプを取得
DeviceType getDeviceType(BuildContext context) {
  final width = ResponsiveLayout.getWidth(context);

  if (width < ResponsiveLayout.smallPhoneBreakpoint) {
    return DeviceType.smallPhone;
  } else if (width < ResponsiveLayout.mediumPhoneBreakpoint) {
    return DeviceType.phone;
  } else if (width < ResponsiveLayout.tabletBreakpoint) {
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}
