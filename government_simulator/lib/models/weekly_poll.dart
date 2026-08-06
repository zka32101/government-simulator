/// 週替わり「全国民投票」の設問。全プレイヤーが同じ週は同じ設問に投票する。
class WeeklyPollQuestion {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String choiceALabel;
  final String choiceBLabel;

  const WeeklyPollQuestion({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.choiceALabel,
    required this.choiceBLabel,
  });

  static const List<WeeklyPollQuestion> all = [
    WeeklyPollQuestion(
      id: 'poll_tax_vs_welfare',
      emoji: '💰',
      title: '増税か、福祉削減か',
      description: '財政赤字が深刻化しています。あなたならどちらを選びますか？',
      choiceALabel: '増税で財源を確保する',
      choiceBLabel: '福祉予算を削減する',
    ),
    WeeklyPollQuestion(
      id: 'poll_open_vs_protect',
      emoji: '🌐',
      title: '市場開放か、国内産業保護か',
      description: '貿易協定の是非が国を二分しています。',
      choiceALabel: '市場を開放する',
      choiceBLabel: '国内産業を保護する',
    ),
    WeeklyPollQuestion(
      id: 'poll_military_vs_diplomacy',
      emoji: '⚔️',
      title: '軍拡か、対話か',
      description: '近隣国との緊張が高まっています。',
      choiceALabel: '防衛費を増額する',
      choiceBLabel: '対話による解決を図る',
    ),
    WeeklyPollQuestion(
      id: 'poll_growth_vs_environment',
      emoji: '🏭',
      title: '経済成長か、環境保護か',
      description: '工業地帯の拡張計画が議論を呼んでいます。',
      choiceALabel: '経済成長を優先する',
      choiceBLabel: '環境規制を強化する',
    ),
    WeeklyPollQuestion(
      id: 'poll_censorship_vs_freedom',
      emoji: '📰',
      title: '報道規制か、言論の自由か',
      description: '政府批判の報道が過熱しています。',
      choiceALabel: '一部の報道を規制する',
      choiceBLabel: '言論の自由を尊重する',
    ),
    WeeklyPollQuestion(
      id: 'poll_immigration',
      emoji: '🧳',
      title: '移民受け入れの是非',
      description: '労働力不足を補うための移民政策が議論されています。',
      choiceALabel: '積極的に受け入れる',
      choiceBLabel: '受け入れを制限する',
    ),
    WeeklyPollQuestion(
      id: 'poll_centralize_vs_devolve',
      emoji: '🏛️',
      title: '中央集権か、地方分権か',
      description: '地方からの権限移譲の要求が強まっています。',
      choiceALabel: '中央の権限を維持する',
      choiceBLabel: '地方に権限を移譲する',
    ),
    WeeklyPollQuestion(
      id: 'poll_ai_regulation',
      emoji: '🤖',
      title: 'AI技術の規制か、推進か',
      description: '急速なAI普及に対する国の方針が問われています。',
      choiceALabel: '規制を強化する',
      choiceBLabel: '産業育成を優先する',
    ),
    WeeklyPollQuestion(
      id: 'poll_election_timing',
      emoji: '🗳️',
      title: '早期選挙か、任期満了まで続投か',
      description: '支持率が不安定な中、選挙のタイミングが問われています。',
      choiceALabel: '早期に信を問う',
      choiceBLabel: '任期満了まで続投する',
    ),
    WeeklyPollQuestion(
      id: 'poll_currency_peg',
      emoji: '💱',
      title: '通貨を固定するか、変動させるか',
      description: '為替の乱高下が輸出産業を直撃しています。',
      choiceALabel: '通貨を固定する',
      choiceBLabel: '市場に委ねる',
    ),
  ];

  /// 現在の週のIDと設問を取得する（全プレイヤー共通）。
  static ({String weekId, WeeklyPollQuestion question}) current({DateTime? now}) {
    final n = now ?? DateTime.now();
    final startOfYear = DateTime(n.year, 1, 1);
    final dayOfYear = n.difference(startOfYear).inDays + 1;
    final weekOfYear = ((dayOfYear - 1) / 7).floor() + 1;
    final weekId = '${n.year}-W${weekOfYear.toString().padLeft(2, '0')}';
    final question = all[weekOfYear % all.length];
    return (weekId: weekId, question: question);
  }
}
