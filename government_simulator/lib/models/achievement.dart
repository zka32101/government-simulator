import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/country_status.dart';

/// 実績・称号。年末やゲームオーバー時に達成判定する。
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function(GameSession session) check;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.check,
  });
}

class Achievements {
  static final List<Achievement> all = [
    Achievement(
      id: 'first_year',
      emoji: '🎓',
      title: '初めての一年',
      description: '最初の1年を完走した',
      check: (s) => s.status.year >= 2,
    ),
    Achievement(
      id: 'economic_boom',
      emoji: '📈',
      title: '経済の奇跡',
      description: 'GDPを2000B以上に到達させた',
      check: (s) => s.status.gdp >= 2000,
    ),
    Achievement(
      id: 'beloved_leader',
      emoji: '❤️',
      title: '国民的英雄',
      description: '国民満足度90%以上を達成',
      check: (s) => s.status.satisfaction >= 90,
    ),
    Achievement(
      id: 'full_employment',
      emoji: '💪',
      title: '完全雇用',
      description: '失業率を2%未満に抑えた',
      check: (s) => s.status.unemployment < 2,
    ),
    Achievement(
      id: 'superpower',
      emoji: '🌐',
      title: '超大国',
      description: '国力90以上に到達',
      check: (s) => s.status.nationalPower >= 90,
    ),
    Achievement(
      id: 'iron_stability',
      emoji: '🛡️',
      title: '盤石の体制',
      description: '安定度95以上を維持',
      check: (s) => s.status.stability >= 95,
    ),
    Achievement(
      id: 'veteran_leader',
      emoji: '👑',
      title: '長期政権',
      description: '5年間統治を続けた',
      check: (s) => s.status.year >= 5,
    ),
    Achievement(
      id: 'perfect_score',
      emoji: '🏆',
      title: '完璧な統治',
      description: '国家健全度85以上を達成',
      check: (s) => s.status.healthScore >= 85,
    ),
    Achievement(
      id: 'decisive',
      emoji: '⚡',
      title: '決断の人',
      description: '通算50回の意思決定を行った',
      check: (s) => s.totalDecisions >= 50,
    ),
    Achievement(
      id: 'high_success',
      emoji: '🎯',
      title: '名宰相',
      description: '成功率80%以上（10決定以上）',
      check: (s) => s.totalDecisions >= 10 && s.successRate >= 80,
    ),
  ];

  static List<Achievement> checkNew(
      GameSession session, List<String> alreadyUnlocked) {
    return all
        .where((a) =>
            !alreadyUnlocked.contains(a.id) && a.check(session))
        .toList();
  }
}

/// ゲームオーバーの種類
enum GameOverType {
  none,
  coup, // クーデター（軍部離反）
  revolution, // 革命（市民蜂起・満足度0）
  collapse, // 国家崩壊（安定度0）
  bankruptcy, // 財政破綻（GDP暴落）
}

extension GameOverTypeExt on GameOverType {
  String get emoji {
    switch (this) {
      case GameOverType.coup:
        return '🎖️';
      case GameOverType.revolution:
        return '🔥';
      case GameOverType.collapse:
        return '🏚️';
      case GameOverType.bankruptcy:
        return '💸';
      case GameOverType.none:
        return '';
    }
  }

  String get title {
    switch (this) {
      case GameOverType.coup:
        return '軍事クーデター';
      case GameOverType.revolution:
        return '市民革命';
      case GameOverType.collapse:
        return '国家崩壊';
      case GameOverType.bankruptcy:
        return '財政破綻';
      case GameOverType.none:
        return '';
    }
  }

  String get message {
    switch (this) {
      case GameOverType.coup:
        return '軍部があなたの統治に見切りをつけ、戦車が首都に進駐した。'
            'あなたは権力の座を追われた。';
      case GameOverType.revolution:
        return '怒れる民衆が街頭を埋め尽くし、政府は転覆した。'
            '国民の信頼を失った指導者に居場所はなかった。';
      case GameOverType.collapse:
        return '国家の秩序は完全に崩壊し、各地で無政府状態が広がった。'
            'あなたの政権は歴史の中に消えた。';
      case GameOverType.bankruptcy:
        return '国庫は底をつき、経済は壊滅した。'
            '国際社会からも見放され、政権は崩壊した。';
      case GameOverType.none:
        return '';
    }
  }
}
