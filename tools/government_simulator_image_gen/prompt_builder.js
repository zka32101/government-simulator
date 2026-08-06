// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 政府シミュレーター AI画像生成 プロンプト組み立てモジュール
// leonardo-ai-image-gen スキル（原本: card_crown）のパターンを流用。
// カテゴリが異種混在（ポートレート/紋章/エンディング挿絵/シナリオ挿絵/アイコン）なため、
// 単一Dartデータのパースではなく、実データ（ゲーム内モデルの値）をこのファイルに
// 直接列挙する方式にしている。
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 統一ハウススタイル：ダーク紺×ゴールドの重厚な政治ドラマ調（AppTheme.dart準拠）
// 人物は写実ではなく「キャラクター化」（ゲームキャラクターデザイン風）で統一する。
const HOUSE_STYLE =
  'dark navy and antique gold color palette, dramatic chiaroscuro lighting, ' +
  'stylized game character illustration, clean bold linework, semi-realistic anime-adjacent character design, serious institutional tone';

// 人物カテゴリ専用の追記スタイル（写実回避を明示）
const CHARACTER_STYLE_SUFFIX =
  'stylized character design, not photorealistic, illustrated character portrait, expressive simplified features';

const NEGATIVE_COMMON = [
  'text, words, letters, numbers, watermark, signature, logo',
  'ugly, blurry, low quality, deformed, mutated, malformed',
  'extra limbs, bad anatomy, extra fingers, extra faces',
  'oversaturated, washed out, low contrast',
].join(', ');

// 人物カテゴリ（大臣・顧問）専用のネガティブプロンプト：写実・実写を明示的に排除
const NEGATIVE_CHARACTER = [
  NEGATIVE_COMMON,
  'photorealistic, photograph, realistic human skin texture, real person, hyperrealistic',
].join(', ');

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. アプリアイコン（1枚）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const APP_ICON = {
  id: 'app_icon',
  category: 'icon',
  nameJp: 'アプリアイコン',
  prompt: [
    'minimalist app icon, classical government building silhouette (columns and pediment)',
    'centered composition, bold simple shapes readable at small size',
    'deep navy background, single antique gold accent light',
    'flat vector-ish illustration, no gradients clutter, square composition',
    'no text no watermark no border',
  ].join(', '),
};

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. 大臣ポートレート（5枚）— MinisterRole 準拠
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const MINISTERS = [
  {
    id: 'minister_finance',
    nameJp: '財務大臣',
    desc: 'sharp-eyed finance minister in formal dark suit, holding ledger, calculating expression',
  },
  {
    id: 'minister_defense',
    nameJp: '国防大臣',
    desc: 'stern military-uniformed defense minister, medals on chest, rigid disciplined posture',
  },
  {
    id: 'minister_interior',
    nameJp: '内務大臣',
    desc: 'composed bureaucratic interior minister, spectacles, calm authoritative gaze',
  },
  {
    id: 'minister_foreign',
    nameJp: '外務大臣',
    desc: 'elegant diplomatic foreign minister, refined formal attire, subtle knowing smile',
  },
  {
    id: 'minister_environment',
    nameJp: '環境大臣',
    desc: 'earthy idealistic environment minister, simpler attire, weathered thoughtful face',
  },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. エンディング挿絵（12枚）— ending.dart の12分岐に対応
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const ENDINGS = [
  { id: 'ending_authoritarian_prosperity_supported', nameJp: '開発独裁の父',
    desc: 'a stern leader overlooking a thriving illuminated city from a balcony, adoring yet uneasy crowd below' },
  { id: 'ending_authoritarian_prosperity_oppressive', nameJp: '黄金の独裁者',
    desc: 'a leader on a golden throne surrounded by wealth, silent fearful subjects bowing in shadow' },
  { id: 'ending_authoritarian_stagnation_supported', nameJp: '停滞の統率者',
    desc: 'a rigid military leader standing before a grey unchanging cityscape, order without progress' },
  { id: 'ending_authoritarian_stagnation_oppressive', nameJp: '灰色の権威主義者',
    desc: 'a faceless bureaucrat-leader in a fog-grey plaza, empty streets, oppressive quiet' },
  { id: 'ending_authoritarian_collapse_supported', nameJp: '悲劇の強権者',
    desc: 'a leader kneeling amid crumbling monuments, loyal few still standing beside him, tragic dusk light' },
  { id: 'ending_authoritarian_collapse_oppressive', nameJp: '暴君',
    desc: 'a tyrant silhouette against a burning palace, revolutionary torches surrounding in the dark' },
  { id: 'ending_democratic_prosperity_supported', nameJp: '黄金時代を築いた改革者',
    desc: 'a beloved reformist leader among cheering diverse citizens, golden sunrise over a prosperous capital' },
  { id: 'ending_democratic_prosperity_oppressive', nameJp: '孤高の実務家',
    desc: 'a competent leader alone at a desk full of good economic charts, empty chamber, unloved success' },
  { id: 'ending_democratic_stagnation_supported', nameJp: '愛された凡庸な指導者',
    desc: 'a modest well-liked leader having tea with ordinary townspeople, quiet unremarkable contentment' },
  { id: 'ending_democratic_stagnation_oppressive', nameJp: '迷走した調整役',
    desc: 'a leader surrounded by conflicting advisors and paperwork, indecisive fog, directionless parliament' },
  { id: 'ending_democratic_collapse_supported', nameJp: '志半ばの改革者',
    desc: 'a determined leader still reaching forward as the nation crumbles, loyal supporters holding firm, tragic hope' },
  { id: 'ending_democratic_collapse_oppressive', nameJp: '見捨てられた指導者',
    desc: 'a leader standing alone in an emptied grand hall, abandoned podium, echoing solitude' },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. 歴史のIfシナリオ サムネ（10枚）— historical_scenario.dart 準拠
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const SCENARIOS = [
  { id: 'scenario_great_depression', nameJp: '大恐慌下の新興国',
    desc: 'crowds outside a shuttered bank, grey depression-era city street, breadlines in fog' },
  { id: 'scenario_oil_shock', nameJp: 'オイルショックの資源輸入国',
    desc: 'long queues at gas stations, oil derricks silhouette, hazy amber industrial skyline' },
  { id: 'scenario_cold_war_divide', nameJp: '分断国家の最前線',
    desc: 'a concrete dividing wall under searchlights, guard towers, tense cold-war border night' },
  { id: 'scenario_new_independence', nameJp: '独立直後の新興国家',
    desc: 'a new flag being raised over a modest capital at dawn, hopeful crowd, fragile optimism' },
  { id: 'scenario_export_boom', nameJp: '高度成長期の輸出大国',
    desc: 'towering factories and cargo ports at golden hour, smokestacks, booming industrial energy' },
  { id: 'scenario_welfare_debt', nameJp: '財政危機の福祉国家',
    desc: 'grand welfare-state architecture with cracks showing, ledgers of red ink, opulent decay' },
  { id: 'scenario_post_coup', nameJp: 'クーデター後の暫定政権',
    desc: 'tanks parked in a plaza at dawn, uneasy soldiers, a provisional government building' },
  { id: 'scenario_currency_crisis', nameJp: '通貨危機の新興市場',
    desc: 'a currency exchange board with plummeting numbers, panicked traders, red warning glow' },
  { id: 'scenario_reunification', nameJp: '統一直後の東西融合国家',
    desc: 'two halves of a city merging, old wall fragments among new construction, mixed architecture' },
  { id: 'scenario_post_pandemic', nameJp: '感染症危機後の再建期',
    desc: 'workers reopening shuttered shops, masks being lowered, cautious hopeful reconstruction light' },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. 隣国の紋章（5枚）— world_map.dart 準拠
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const NEIGHBORS = [
  { id: 'neighbor_northern_power', nameJp: '北方大国',
    desc: 'heraldic crest featuring a bear, militaristic ornamentation, cold steel-grey and gold' },
  { id: 'neighbor_eastern_ally', nameJp: '東方連邦',
    desc: 'heraldic crest featuring cherry blossoms, elegant balanced symmetry, soft pink and gold' },
  { id: 'neighbor_southern_trade', nameJp: '南方通商圏',
    desc: 'heraldic crest featuring palm fronds and a merchant ship, warm amber and gold' },
  { id: 'neighbor_western_confederation', nameJp: '西方諸国連合',
    desc: 'heraldic crest featuring an eagle with multiple small shields joined, muted bronze and gold' },
  { id: 'neighbor_island_nation', nameJp: '孤島共和国',
    desc: 'heraldic crest featuring waves and a small island, serene teal and gold' },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. 派閥アイコン（4枚）— faction.dart 準拠
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const FACTIONS = [
  { id: 'faction_military', nameJp: '軍部',
    desc: 'emblem of crossed swords beneath a star, disciplined military insignia' },
  { id: 'faction_business', nameJp: '財界',
    desc: 'emblem of a laurel wreath encircling a coin, prosperous commercial insignia' },
  { id: 'faction_labor', nameJp: '労働者',
    desc: 'emblem of a raised gear and wrench crossed, workers solidarity insignia' },
  { id: 'faction_citizen', nameJp: '市民',
    desc: 'emblem of an open hand beneath a rising sun, civic unity insignia' },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. イベントカテゴリ別 大臣アバター（7枚）— event.dart の EventCategory 準拠
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const ADVISORS = [
  { id: 'advisor_economic', nameJp: '経済顧問',
    desc: 'economic advisor character bust, holding a briefcase, sharp calculating gaze' },
  { id: 'advisor_employment', nameJp: '雇用顧問',
    desc: 'employment advisor character bust, rolled-up sleeves, practical grounded expression' },
  { id: 'advisor_social', nameJp: '社会顧問',
    desc: 'social affairs advisor character bust, warm approachable demeanor, community-minded' },
  { id: 'advisor_political', nameJp: '政治顧問',
    desc: 'political advisor character bust, sly strategic half-smile, sharp formal attire' },
  { id: 'advisor_environmental', nameJp: '環境顧問',
    desc: 'environmental advisor character bust, earthy attire, concerned thoughtful eyes' },
  { id: 'advisor_military', nameJp: '軍事顧問',
    desc: 'military advisor character bust, decorated uniform, hardened watchful stare' },
  { id: 'advisor_external', nameJp: '外交顧問',
    desc: 'foreign affairs advisor character bust, cosmopolitan refined look, guarded diplomatic smile' },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 全アセット統合リスト（44件）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function buildAssetList() {
  const list = [];
  list.push({ ...APP_ICON });
  for (const m of MINISTERS) list.push({ id: m.id, category: 'minister', nameJp: m.nameJp, desc: m.desc });
  for (const e of ENDINGS) list.push({ id: e.id, category: 'ending', nameJp: e.nameJp, desc: e.desc });
  for (const s of SCENARIOS) list.push({ id: s.id, category: 'scenario', nameJp: s.nameJp, desc: s.desc });
  for (const n of NEIGHBORS) list.push({ id: n.id, category: 'neighbor', nameJp: n.nameJp, desc: n.desc });
  for (const f of FACTIONS) list.push({ id: f.id, category: 'faction', nameJp: f.nameJp, desc: f.desc });
  for (const a of ADVISORS) list.push({ id: a.id, category: 'advisor', nameJp: a.nameJp, desc: a.desc });
  return list;
}

// カテゴリ別のアートスタイル指定
const CATEGORY_STYLE = {
  icon: '', // APP_ICON は prompt を独自に完結させているので追加スタイル不要
  minister: 'stylized character design bust, centered composition, plain dark background vignette',
  advisor: 'stylized character design bust, centered composition, plain dark background vignette',
  ending: 'atmospheric symbolic cinematic scene illustration, wide composition, storytelling mood, stylized characters not photorealistic',
  scenario: 'moody historical scene illustration, atmospheric period detail, wide composition',
  neighbor: 'ornate heraldic crest emblem, flat symmetrical vector-ish illustration, circular composition',
  faction: 'clean emblem icon, flat symmetrical vector-ish illustration, circular composition',
};

// 人物（人型キャラクター）を含むカテゴリ：写実回避の追記＋専用ネガティブを適用
const CHARACTER_CATEGORIES = new Set(['minister', 'advisor', 'ending']);

function buildPrompt(asset) {
  if (asset.category === 'icon') {
    return { prompt: asset.prompt, negativePrompt: NEGATIVE_COMMON };
  }

  const style = CATEGORY_STYLE[asset.category] || '';
  const isCharacter = CHARACTER_CATEGORIES.has(asset.category);
  const prompt = [
    asset.desc,
    style,
    isCharacter ? CHARACTER_STYLE_SUFFIX : null,
    HOUSE_STYLE,
    'no text no watermark no border',
  ]
    .filter(Boolean)
    .join(', ');

  return {
    prompt,
    negativePrompt: isCharacter ? NEGATIVE_CHARACTER : NEGATIVE_COMMON,
  };
}

module.exports = { buildAssetList, buildPrompt };
