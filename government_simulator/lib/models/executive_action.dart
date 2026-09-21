/// 統治アクション：ランダムイベントの発生を待たず、プレイヤーが自らの
/// 判断で能動的に実行できる統治行為。種類ごとに年1回まで実行できる。
library;

enum ExecutiveActionType {
  addressNation, // 国民に演説する
  negotiateFaction, // 派閥と交渉する
  encourageCabinet, // 内閣を激励する
}

extension ExecutiveActionTypeExt on ExecutiveActionType {
  String get emoji {
    switch (this) {
      case ExecutiveActionType.addressNation:
        return '📢';
      case ExecutiveActionType.negotiateFaction:
        return '🤝';
      case ExecutiveActionType.encourageCabinet:
        return '🏛️';
    }
  }

  String get label {
    switch (this) {
      case ExecutiveActionType.addressNation:
        return '国民に演説する';
      case ExecutiveActionType.negotiateFaction:
        return '派閥と交渉する';
      case ExecutiveActionType.encourageCabinet:
        return '大臣を激励する';
    }
  }

  String get description {
    switch (this) {
      case ExecutiveActionType.addressNation:
        return '国民に直接語りかけ、支持率をわずかに高める。';
      case ExecutiveActionType.negotiateFaction:
        return '選んだ派閥と個別に交渉し、関係を改善する。安定度をわずかに消費する。';
      case ExecutiveActionType.encourageCabinet:
        return '選んだ大臣を激励し、忠誠度を高める。';
    }
  }
}
