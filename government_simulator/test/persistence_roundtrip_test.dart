import 'package:flutter_test/flutter_test.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/models/promise.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/user_profile.dart';

// FirestoreService はこれらのモデルの toMap()/fromMap() を単一ソースとして
// 委譲する（Timestamp⇄ISO8601 の変換のみを橋渡しする）。ここではその前提となる
// モデル自体のラウンドトリップが完全であることを検証する。
// 過去に factions/cabinet/activePromises/unlockedAchievements が FirestoreService
// 側で手動シリアライズされておらず、アプリ再起動でリセットされるバグがあった。
void main() {
  group('CountryStatus round-trip', () {
    test('factions・cabinet・派閥の嘘つきフラグが保持される', () {
      final factions = const FactionSupport({
        Faction.military: 72,
        Faction.business: 33,
        Faction.labor: 60,
        Faction.citizen: 45,
      }).markLiar(Faction.labor);

      final cabinet = Cabinet.initial()
          .applyDeltas({MinisterRole.finance: -30})
          .markBetrayed(MinisterRole.defense);

      final original = CountryStatus(
        gdp: 1234.5,
        unemployment: 8.2,
        satisfaction: 61.0,
        nationalPower: 55.0,
        year: 3,
        day: 4,
        lastUpdated: DateTime(2026, 5, 1, 10, 30),
        factions: factions,
        cabinet: cabinet,
        previousSessionId: 'prev-123',
        isNewGame: false,
      );

      final restored = CountryStatus.fromMap(original.toMap());

      expect(restored.factions.of(Faction.military), 72);
      expect(restored.factions.of(Faction.labor), 60);
      expect(restored.factions.liarFlags, contains(Faction.labor));
      expect(restored.cabinet.of(MinisterRole.finance), 30);
      expect(restored.cabinet.betrayed, contains(MinisterRole.defense));
      expect(restored.previousSessionId, 'prev-123');
      expect(restored.isNewGame, false);
    });
  });

  group('GameSession round-trip', () {
    test('activePromises・unlockedAchievements・hasSeenTutorial が保持される', () {
      final promise = Promise(
        id: 'p1',
        faction: Faction.citizen,
        madeAtDecisionCount: 5,
        dueAtDecisionCount: 8,
        supportAtPromiseTime: 50,
      );

      final original = GameSession(
        id: 'session-1',
        userId: 'user-1',
        countryName: 'テスト共和国',
        status: CountryStatus(
          gdp: 1000,
          unemployment: 5,
          satisfaction: 50,
          nationalPower: 50,
          year: 1,
          day: 1,
          lastUpdated: DateTime(2026, 1, 1),
        ),
        createdAt: DateTime(2026, 1, 1),
        lastPlayedAt: DateTime(2026, 1, 2),
        unlockedAchievements: const ['first_year', 'economic_boom'],
        hasSeenTutorial: true,
        activePromises: [promise],
      );

      final restored = GameSession.fromMap(original.toMap());

      expect(restored.unlockedAchievements,
          containsAll(['first_year', 'economic_boom']));
      expect(restored.hasSeenTutorial, true);
      expect(restored.activePromises, hasLength(1));
      expect(restored.activePromises.first.faction, Faction.citizen);
      expect(restored.activePromises.first.dueAtDecisionCount, 8);
    });
  });

  group('UserProfile round-trip', () {
    test('email・displayName・お気に入り国名・難易度設定・チュートリアル既読が保持される', () {
      final original = UserProfile(
        id: 'user-1',
        email: 'user@example.com',
        displayName: 'テストユーザー',
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 2),
        isPurchased: true,
        favoriteCountryNames: const ['新興共和国', 'テスト王国'],
        preferredDifficulty: 'hard',
        hasCompletedTutorial: true,
      );

      final restored = UserProfile.fromMap(original.toMap());

      expect(restored.email, 'user@example.com');
      expect(restored.displayName, 'テストユーザー');
      expect(restored.favoriteCountryNames, contains('テスト王国'));
      expect(restored.preferredDifficulty, 'hard');
      expect(restored.hasCompletedTutorial, true);
      expect(restored.isPurchased, true);
    });
  });
}
