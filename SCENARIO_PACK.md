# Government Simulator - シナリオ追加パック

## 概要

政治シミュレーションゲーム「Government Simulator」に複数の仮想国シナリオを追加しました。プレイヤーは異なる地政学的背景、経済状況、社会的課題を持つ5つの国家でゲームをプレイできます。

---

## 📦 シナリオパック構成

### 1. **オスティア共和国** (ostia_scenario.dart)
**難易度：Normal | 地域：ヨーロッパ・カルパチア地方**

- **背景**：経済危機から回復途上の中堅先進国
- **人口**：3,500万人 | **GDP**：$2.8兆 | **初期承認度**：45%

**主要課題**
- 経済危機（失業12%、インフレ8%）
- ロスカ帝国との国境紛争・領土問題
- 政治的分裂（改革派 vs 保守派）
- 少数民族問題（スラヴ系30%、イスラム系15%）
- 労働組合の強い反発

**ストーリーアーク**（優先度順）
1. 経済危機からの回復（economic）
2. ロスカ帝国との国境紛争（military）
3. 国内政治の分裂と統和（domestic）
4. 少数民族問題の解決（domestic）
5. 国際的地位の確立（diplomatic）

**主要キャラクター**
- ボリス・ノヴァク：財務大臣（改革派、影響度0.8）
- マルタ・コーバル：野党党首（保守派、影響度0.75）
- ジャンナ・クレス：国防大臣（強硬派、影響度0.6）

**国際関係**
- ロスカ帝国：敵対国（スタンディング-60）
- プロスペリア連邦：友好国（スタンディング45）
- ヴァリア王国：NATO同盟国（スタンディング35）
- アルタイ共和国：中立国・不安定（スタンディング5）

---

### 2. **アマンダ共和国** (amanda_scenario.dart)
**難易度：Hard | 地域：アフリカ・サハラ以南**

- **背景**：資源豊富だが汚職と内戦危機に直面する発展途上国
- **人口**：2,800万人 | **GDP**：$650億 | **初期承認度**：38%

**主要課題**
- 貧困と極度の不平等（Gini係数60超え）
- 汚職の蔓延（資源収益の横領）
- 族間対立の危機
- 医療・教育インフラの崩壊
- テロリスト集団の活動

**ストーリーアーク**（優先度順）
1. 資源の呪い：富と汚職（economic）
2. 内戦危機の回避（military）
3. 民主化と人権（domestic）
4. 医療・教育の危機的状況（social）
5. 国際的信用と開発援助（diplomatic）

**主要キャラクター**
- ジャスティン・カバラ：エネルギー資源大臣（汚職疑惑、影響度0.85）
- ドミニク・アベベ：野党党首（反汚職、影響度0.7）
- ジェラール・シェンバ：軍部最高司令官（クーデター候補、影響度0.7）

**国際関係**
- 南アフリカ連邦：友好国・経済的主導国（スタンディング50）
- フランス共和国：旧宗主国（スタンディング25）
- 中国：新興経済的パートナー（スタンディング35）
- ルワンダ：隣国・不安定（スタンディング10）

---

### 3. **イスラス連邦** (islas_scenario.dart)
**難易度：Hard | 地域：アジア太平洋**

- **背景**：急速な経済成長と地域覇権争いの最前線
- **人口**：2.75億人 | **GDP**：$2.1兆 | **初期承認度**：52%

**主要課題**
- 急速な都市化と格差拡大
- 宗教・民族対立（キリスト教 vs イスラム教）
- 中国との南シナ海領土紛争
- 環境破壊と気候変動
- テロリズムの脅威再活性化

**ストーリーアーク**（優先度順）
1. 経済成長と格差の拡大（economic）
2. 宗教・民族対立の緊張（domestic）
3. 南シナ海での領土争い（military）
4. 環境破壊と気候変動対策（social）
5. 地域統合のリーダーシップ（diplomatic）

**主要キャラクター**
- ジャヤ・スタメガ：大蔵大臣（経済成長至上主義、影響度0.8）
- アイシャ・ラーマン：野党党首（福祉・環境重視、影響度0.72）
- ハジ・アマル：イスラム指導者（法厳格化推進、影響度0.68）

**国際関係**
- 中国：経済的主導国・領土紛争国（スタンディング15）
- アメリカ：セキュリティ同盟国（スタンディング40）
- シンガポール：地域経済的リーダー（スタンディング50）
- オーストラリア：地域パートナー（スタンディング35）

---

### 4. **ノルスランド王国** (norsland_scenario.dart)
**難易度：Normal | 地域：北ヨーロッパ・北極圏**

- **背景**：高福祉国家の危機と気候変動対策の最前線
- **人口**：550万人 | **GDP**：$2.2兆 | **初期承認度**：58%

**主要課題**
- 気候変動による環境危機（北極氷の急速融解）
- 移民・難民の急増による社会統合の困難
- 福祉制度の持続可能性問題
- 産業転換の必要性（石油産業からの脱却）
- ポピュリズムと右翼政党の台頭

**ストーリーアーク**（優先度順）
1. 気候変動の急速化と対応（economic）
2. 移民危機と社会統合（domestic）
3. 福祉国家の持続可能性（social）
4. 北極圏の地政学（military）
5. グリーン経済への産業転換（economic）

**主要キャラクター**
- エリック・オーストロム：首相（気候変動対策最優先、影響度0.9）
- ソフィア・リンドストローム：保守党党首（移民制限派、影響度0.75）
- ムハマド・アムスン：労働・統合担当大臣（移民統合派、影響度0.65）

**国際関係**
- スウェーデン：北欧パートナー（スタンディング65）
- デンマーク：北欧パートナー（スタンディング60）
- ロシア：地政学的対立国（スタンディング-25）
- ドイツ：EU主要国（スタンディング55）

---

### 5. **テラノバ共和国** (terranova_scenario.dart)
**難易度：Very Hard | 地域：ラテンアメリカ・カリブ地域**

- **背景**：民主化後も麻薬戦争と汚職に苦しむ国家
- **人口**：4,800万人 | **GDP**：$950億 | **初期承認度**：32%

**主要課題**
- 麻薬組織による激しい暴力（毎年5000人以上の殺害）
- 警察・司法制度の深刻な腐敗
- 民主主義の存続危機
- 社会的極度の不平等
- 米国への違法移民の急増

**ストーリーアーク**（優先度順）
1. 麻薬戦争と暴力の根絶（military）
2. 汚職と司法制度の改革（domestic）
3. 民主主義の生存（military）
4. 社会的不平等と貧困（social）
5. US支援と主権のバランス（diplomatic）

**主要キャラクター**
- カルロス・ロドリゲス：大統領（麻薬戦争強硬派、影響度0.75）
- ホセ・アルバレス：検察総長（反腐敗・法治主義派、影響度0.65）
- エドゥアルド・サンチェス：軍部総司令官（秩序維持重視・クーデターリスク、影響度0.7）

**国際関係**
- アメリカ合衆国：支配的な大国（スタンディング40）
- メキシコ：北隣の麻薬戦争同盟国（スタンディング35）
- コロンビア：コカイン麻薬供給源（スタンディング-15）
- ラテンアメリカ諸国：地域パートナー（スタンディング25）

---

## 🛠️ 実装ファイル構成

```
lib/
├── models/
│   └── scenario.dart                          # シナリオデータモデル
├── data/
│   └── scenarios/
│       ├── ostia_scenario.dart               # オスティア共和国
│       ├── amanda_scenario.dart              # アマンダ共和国
│       ├── islas_scenario.dart               # イスラス連邦
│       ├── norsland_scenario.dart            # ノルスランド王国
│       └── terranova_scenario.dart           # テラノバ共和国
├── services/
│   └── scenario_service.dart                  # シナリオ管理サービス
└── screens/
    └── scenario_selection_screen.dart         # シナリオ選択UI
```

---

## 📊 シナリオ比較表

| シナリオ | 難易度 | 人口 | GDP | 初期承認度 | 主要課題 | 地域 |
|---------|-------|------|-----|----------|--------|------|
| オスティア | Normal | 3,500万 | $2.8T | 45% | 経済危機 + 国際紛争 | 欧州 |
| アマンダ | Hard | 2,800万 | $650B | 38% | 汚職 + 内戦危機 | アフリカ |
| イスラス | Hard | 2.75億 | $2.1T | 52% | 宗教対立 + 領土紛争 | アジア太平洋 |
| ノルスランド | Normal | 550万 | $2.2T | 58% | 気候変動 + 移民 | 北欧 |
| テラノバ | Very Hard | 4,800万 | $950B | 32% | 麻薬戦争 + 民主主義危機 | ラテンアメリカ |

---

## 🎮 ゲームフロー統合

### 1. シナリオ選択画面の表示
```
ゲーム開始 → ScenarioSelectionScreen 表示
              ↓
         シナリオ選択・詳細確認
              ↓
         「プレイ開始」ボタン
```

### 2. 選択されたシナリオからの初期化
```
シナリオ選択 → ScenarioService.createGameSessionDataFromScenario()
           ↓
        初期ゲーム状態を生成
           ↓
        GameSession作成
           ↓
        ゲーム開始
```

### 3. シナリオデータの活用
- **初期状態**：承認度、満足度、予算、国債
- **国際関係**：隣国との関係スコア、同盟・対立状況
- **ストーリーアーク**：優先度付きで、イベント生成の参考に
- **キャラクター情報**：政治勢力・影響度の参考データ
- **危機タイプ**：シナリオに固有の危機をフィルター

---

## 🔧 ScenarioService API

### 主要メソッド

```dart
// すべてのシナリオを取得
static final List<GameScenario> allScenarios

// シナリオIDから取得
static GameScenario? getScenarioById(String id)

// 難易度別に取得
static List<GameScenario> getScenariosByDifficulty(String difficulty)

// 地域別に取得
static List<GameScenario> getScenariosByRegion(String region)

// シナリオからゲーム初期化データを生成
static Map<String, dynamic> createGameSessionDataFromScenario(
  GameScenario scenario,
)

// シナリオの詳細説明を取得（UI用）
static String getScenarioDescription(GameScenario scenario)
```

---

## 📝 シナリオデータモデル

### GameScenario クラス
```dart
class GameScenario {
  final String id;                              // シナリオID
  final String countryName;                     // 国名
  final String region;                          // 地域
  final String description;                     // 短説明
  final String difficulty;                      // 難易度
  final double population;                      // 人口（百万単位）
  final double gdp;                             // GDP（兆ドル単位）
  final String politicalSystem;                 // 政治体制
  final String currency;                        // 通貨
  
  // 初期ゲーム状態
  final double initialApproval;                 // 初期承認度
  final double economicSatisfaction;            // 経済満足度
  final double socialSatisfaction;              // 社会満足度
  final double securitySatisfaction;            // 安保満足度
  final double healthcareSatisfaction;          // 医療満足度
  final double budget;                          // 初期予算
  final double nationalDebt;                    // 国債
  
  // 背景情報
  final String historicalBackground;            // 歴史背景
  final List<String> currentChallenges;         // 現在の課題
  final List<String> opportunities;             // 機会
  
  // ゲーム要素
  final List<ScenarioCharacter> characters;     // キャラクター
  final List<InitialNationRelation> initialNations; // 初期国際関係
  final List<StoryArc> storyArcs;               // ストーリーアーク
  final List<CrisisType> uniqueCrises;          // 固有危機
}
```

---

## 🎯 拡張性

このシナリオシステムは以下のように拡張可能です：

1. **新しいシナリオの追加**
   - `lib/data/scenarios/`に新しいシナリオファイルを作成
   - `ScenarioService.allScenarios`に追加

2. **シナリオ固有のイベント**
   - ストーリーアークの情報を使用してイベント生成ロジックをカスタマイズ
   - CrisisEventServiceで`scenario.uniqueCrises`をフィルターとして使用

3. **キャラクター・政党システムの統合**
   - `ScenarioCharacter`の情報をPoliticalPartyやRivalCandidateに変換
   - 初期政党・候補者をシナリオから動的生成

4. **動的ストーリーマーク**
   - ストーリーアークの進行状況を追跡
   - アーク達成時のスペシャルイベント実装

---

## ✅ 実装チェックリスト

- [x] シナリオデータモデル作成
- [x] 5つの仮想国シナリオ実装
- [x] シナリオ管理サービス作成
- [x] シナリオ選択UI実装
- [ ] ゲーム開始フロー統合
- [ ] シナリオ固有イベント実装（Phase 4.16）
- [ ] キャラクター・政党動的生成（Phase 4.16+）
- [ ] 多言語対応（拡張）

---

## 🚀 次のフェーズ

**Phase 4.16: シナリオ統合とイベント生成**
- ゲーム開始フローにシナリオ選択を統合
- CrisisEventService / DiplomaticEventServiceにシナリオデータを統合
- シナリオ固有のイベントチェーンを実装
- キャラクター・政党をシナリオから動的生成

---

## 📄 ライセンス

このシナリオパックはゲーム本体と同じライセンスの下で公開されています。

---

最終更新：2026-09-12
