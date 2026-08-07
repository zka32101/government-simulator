// 元のファイルは Flutter デフォルトテンプレートのカウンターアプリ用テストが
// そのまま残っており、本アプリには存在しない `MyApp` を参照していたため
// コンパイルすら通らなかった（`flutter analyze`/`flutter test` が常に失敗）。
//
// アプリ本体（GovernmentSimulator）は起動時に Firebase
// （FirebaseAuth.instance 等）へアクセスするため、素の `flutter test`
// （Firebase のプラットフォームチャンネルをモックしていない）ではpumpできない。
// そのため、ここでは Firebase/Riverpod に依存しないウィジェットの
// スモークテストに置き換える。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_simulator/widgets/animated_counter.dart';

void main() {
  testWidgets('AnimatedCounter は初期値と更新後の値を正しく表示する',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 42, decimals: 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);

    // 値が変わったら、アニメーション後に新しい値へ収束する
    // （以前は Tween(begin: value, end: value) で自分自身とトゥイーンして
    // いたため、瞬時に切り替わるだけでアニメーションしていなかった）。
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedCounter(value: 100, decimals: 0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });
}
