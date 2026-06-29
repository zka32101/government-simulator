# 政府シミュレーター v1.0

**Reigns × Suzerain。複数の政策選択を通じ、仮想国家の未来を変えるゲーム**

## 🎮 ゲーム性の特徴

### リッチな経営シミュレーション
- **複合ステータスシステム**: GDP、失業率、国民満足度、国力、インフレ率、経済安定度が相互影響
- **危機レベル判定**: 国家の状況を安定→注意→警告→緊急で可視化
- **国家健全性スコア**: 4つの指標を複合評価（0-100）
- **加重ランダムイベント**: 危機レベルに応じた動的イベント生成
- **インパクトスコア**: 意思決定の質を-100～100で評価
- **自動進行制御**: プレイ時間帯に応じたゲーム進行（W2必須機能）

## 📁 プロジェクト構成

```
lib/
├── models/
│   ├── country_status.dart      # 国家ステータス＋危機判定
│   ├── game_session.dart        # ゲーム進捗＋統計
│   ├── event.dart               # イベント＋複雑な影響
│   ├── decision.dart            # 意思決定記録＋評価
│   └── user_profile.dart        # ユーザー情報
├── services/
│   ├── game_logic_service.dart  # 政策計算・相互作用・ナレーション
│   ├── play_time_service.dart   # プレイ時間管理
│   └── firestore_service.dart   # Firebase統合（スタブ）
├── screens/
│   ├── home_screen.dart         # メイン画面
│   ├── event_detail_screen.dart # 結果画面
│   └── play_time_config_screen.dart # 時間設定
├── widgets/
│   ├── country_status_card.dart # ステータス表示
│   └── event_choice_button.dart # 選択肢ボタン
└── utils/
    └── constants.dart           # 定数＆テーマ
```

## ✅ 実装状況

| フェーズ | 内容 | 状態 |
|---------|------|------|
| **Phase 1** | 基本構造＋ゲーム性 | ✅ 完成 |
| **Phase 2** | プレイ時間制御 | ✅ 完成 |
| **Phase 3** | Firebase統合 | 📌 次 |
| **Phase 4** | グラフ＋国家史 | 予定 |
| **Phase 5** | RevenueCat | 予定 |

## 🚀 技術スタック

- Flutter 3.12+ / Dart 3.x
- Firebase (Firestore, Auth, Analytics)
- Riverpod (状態管理)
- Material 3 (UI)
- fl_chart (グラフ)
- RevenueCat (課金)

## 💰 マネタイズ

- **買い切り**: ¥600
- **DLC**: ¥400×8個
- **目標**: 3ヶ月5万DL → ¥2340万
