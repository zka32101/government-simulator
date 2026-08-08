import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/ending.dart';
import 'package:government_simulator/services/game_logic_service.dart';

// GameLogicService には数値ロジック（派閥支持率変動・エンディング閾値）が
// 実装されているが、プレイテストなしで設計された。
// ここでは「ランダム方策」で数百回分の統治をシミュレーションし、
// 極端な偏り（即死・エンディングの偏在）がないかを検証する。
// 戦略的なプレイの代わりではなく、粗い設計ミスを機械的に検出するための
// スモークテストである。

class _GameResult {
  final int turnsSurvived;
  final String outcome; // GameOverType の名前 or 'retired'
  final String endingTitle;
  final double finalGdp;
  final double finalPublicDebt;

  _GameResult({
    required this.turnsSurvived,
    required this.outcome,
    required this.endingTitle,
    required this.finalGdp,
    required this.finalPublicDebt,
  });
}

_GameResult _simulateOneGame(GameLogicService logic, Random rng,
    {int maxTurns = 150}) {
  var status = CountryStatus(
    gdp: 1000,
    unemployment: 5.0,
    satisfaction: 50.0,
    nationalPower: 50.0,
    year: 1,
    day: 1,
    lastUpdated: DateTime(2026, 1, 1),
  );

  final recentEventIds = <String>{};
  var outcome = 'retired';
  var turn = 0;

  for (; turn < maxTurns; turn++) {
    final event =
        logic.generateRandomEvent(status, recentIds: recentEventIds);
    recentEventIds.add(event.id);
    if (recentEventIds.length > 3) recentEventIds.remove(recentEventIds.first);

    final choices = event.choices;
    final choice = choices[rng.nextInt(choices.length)];

    // 実際のゲームフロー（GameSessionNotifier.applyChoice）を再現：
    // day/decisionsCount を進めてから impact を適用する。
    var newStatus = status.copyWith(
      day: status.day + 1,
      decisionsCount: status.decisionsCount + 1,
      lastUpdated: status.lastUpdated,
    );
    newStatus = logic.applyImpact(newStatus, choice.impact);

    // 年末処理（7日で1年）
    if (newStatus.day >= 7) {
      newStatus = logic.simulateYearPassed(newStatus);
    }

    status = newStatus;

    final gameOver = logic.checkGameOver(status);
    if (gameOver != GameOverType.none) {
      outcome = gameOver.name;
      turn++; // 生存ターン数に今回の決定を含める
      break;
    }
  }

  final ending = Ending.determine(status, status.factions);

  return _GameResult(
    turnsSurvived: turn,
    outcome: outcome,
    endingTitle: ending.title,
    finalGdp: status.gdp,
    finalPublicDebt: status.publicDebt,
  );
}

void main() {
  test('ランダム方策で300ゲーム分シミュレーションし、極端な偏りがないか検証する', () {
    final logic = GameLogicService();
    final rng = Random(42); // 再現性のため固定シード
    const gameCount = 300;

    final results =
        List.generate(gameCount, (_) => _simulateOneGame(logic, rng));

    final survivalTurns = results.map((r) => r.turnsSurvived).toList()
      ..sort();
    final avgSurvival =
        survivalTurns.reduce((a, b) => a + b) / survivalTurns.length;
    final medianSurvival = survivalTurns[survivalTurns.length ~/ 2];

    final outcomeCounts = <String, int>{};
    for (final r in results) {
      outcomeCounts[r.outcome] = (outcomeCounts[r.outcome] ?? 0) + 1;
    }

    final endingCounts = <String, int>{};
    for (final r in results) {
      endingCounts[r.endingTitle] = (endingCounts[r.endingTitle] ?? 0) + 1;
    }

    final finalGdps = results.map((r) => r.finalGdp).toList()..sort();
    final avgGdp = finalGdps.reduce((a, b) => a + b) / finalGdps.length;
    final finalDebts = results.map((r) => r.finalPublicDebt).toList()..sort();
    final avgDebt = finalDebts.reduce((a, b) => a + b) / finalDebts.length;

    // ---- レポート出力 ----
    // ignore: avoid_print
    print('=== バランスシミュレーション結果（$gameCount ゲーム・ランダム方策） ===');
    // ignore: avoid_print
    print('生存ターン数: 平均 ${avgSurvival.toStringAsFixed(1)} / '
        '中央値 $medianSurvival / 最短 ${survivalTurns.first} / 最長 ${survivalTurns.last}');
    // ignore: avoid_print
    print('ゲームオーバー種別分布: $outcomeCounts');
    // ignore: avoid_print
    print('エンディング分布（${endingCounts.length}種類が出現）: $endingCounts');
    // ignore: avoid_print
    print('最終GDP: 平均 \$${avgGdp.toStringAsFixed(0)}B / '
        '最小 \$${finalGdps.first.toStringAsFixed(0)}B / 最大 \$${finalGdps.last.toStringAsFixed(0)}B');
    // ignore: avoid_print
    print('最終公債: 平均 ${avgDebt.toStringAsFixed(1)} / '
        '最小 ${finalDebts.first.toStringAsFixed(1)} / 最大 ${finalDebts.last.toStringAsFixed(1)}');

    // ---- 粗い健全性チェック ----
    // 即死ゲームが大半を占めていないか（あまりに理不尽な難易度でないか）
    expect(medianSurvival, greaterThan(3),
        reason: '中央値が3ターン未満は理不尽な即死バランスの可能性');

    // エンディングが1〜2種類に極端に偏っていないか（12種のうち最低4種は出現してほしい）
    expect(endingCounts.length, greaterThanOrEqualTo(4),
        reason: 'エンディングの分岐が実質機能していない可能性');
  });
}
