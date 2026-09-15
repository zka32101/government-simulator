/// 選挙システム：4年ごとに開催される大統領選挙
library;

class Election {
  final String id;
  final int year;
  final int votesCast;
  final int votesReceived;
  final bool won;
  final double percentageVotes;

  const Election({
    required this.id,
    required this.year,
    required this.votesCast,
    required this.votesReceived,
    required this.won,
    required this.percentageVotes,
  });

  /// 投票率を計算
  double get turnout {
    if (votesCast == 0) return 0;
    return (votesReceived / votesCast) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'votesCast': votesCast,
      'votesReceived': votesReceived,
      'won': won,
      'percentageVotes': percentageVotes,
    };
  }

  factory Election.fromMap(Map<String, dynamic> map) {
    return Election(
      id: map['id'] ?? '',
      year: map['year'] ?? 1,
      votesCast: map['votesCast'] ?? 0,
      votesReceived: map['votesReceived'] ?? 0,
      won: map['won'] ?? false,
      percentageVotes: (map['percentageVotes'] ?? 0).toDouble(),
    );
  }
}

/// 選挙結果のシンプルな指標（勝敗のみ）
enum SimpleElectionOutcome {
  won, // 再選成功
  lost, // 落選
}

extension SimpleElectionOutcomeExt on SimpleElectionOutcome {
  String get emoji {
    switch (this) {
      case SimpleElectionOutcome.won:
        return '🎉';
      case SimpleElectionOutcome.lost:
        return '❌';
    }
  }

  String get title {
    switch (this) {
      case SimpleElectionOutcome.won:
        return '再選成功';
      case SimpleElectionOutcome.lost:
        return '落選';
    }
  }

  String get message {
    switch (this) {
      case SimpleElectionOutcome.won:
        return 'あなたは国民の支持を得て、次期大統領として再選された。';
      case SimpleElectionOutcome.lost:
        return '国民はあなたに失望し、別の候補者を選んだ。あなたの政権は終わりを迎えた。';
    }
  }
}
