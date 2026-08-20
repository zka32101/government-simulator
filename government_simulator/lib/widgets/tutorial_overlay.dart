import 'package:flutter/material.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 初回プレイ時に表示される操作チュートリアル。
/// スワイプ機構・指標・派閥をステップ形式で教える。
/// 完了/スキップで onFinish が呼ばれる。
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onFinish;

  const TutorialOverlay({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final _controller = PageController();
  int _index = 0;

  // 最終ページの「開始する」ボタンとヘッダーの「スキップ」ボタンの
  // どちらも widget.onFinish を呼びうる。どちらか一方が押された後に
  // 素早くもう一方が押されると（あるいは同じボタンを連打すると）
  // onFinish が二重に呼ばれてしまうため、一度呼んだら以降は無視する。
  bool _finished = false;

  static const int _pageCount = 5;

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinish();
  }

  void _next() {
    if (_index >= _pageCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pageCount - 1;
    return Material(
      color: Colors.black.withOpacity(0.82),
      child: SafeArea(
        child: Column(
          children: [
            // スキップ
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('スキップ',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _WelcomePage(),
                  _StatsPage(),
                  _FactionPage(),
                  _SwipePage(),
                  _GameOverPage(),
                ],
              ),
            ),
            // ページインジケーター
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pageCount, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.gold
                        : AppTheme.textSecondary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    isLast ? '🚀 統治を開始する' : '次へ',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 共通レイアウト
// ─────────────────────────────────────────────
class _TutorialPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Widget? extra;

  const _TutorialPage({
    required this.emoji,
    required this.title,
    required this.body,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Text(emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.textPrimary,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 24),
            extra!,
          ],
        ],
      ),
    );
  }
}

// 1. ようこそ
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return const _TutorialPage(
      emoji: '🏛️',
      title: 'あなたは新政権の指導者',
      body: '国家の命運はあなたの決断次第。\n'
          '毎日届く難題にどう応えるかで、\n国は繁栄にも崩壊にも向かいます。\n\n'
          'まずは操作を覚えましょう。',
    );
  }
}

// 2. 指標
class _StatsPage extends StatelessWidget {
  const _StatsPage();

  static const _stats = [
    ['💰', 'GDP', '経済規模'],
    ['👷', '失業率', '低いほど良い'],
    ['😊', '満足度', '国民の支持'],
    ['⚔️', '国力', '軍事・外交力'],
    ['📈', 'インフレ', '物価の安定'],
    ['🏛️', '安定度', '政権の基盤'],
  ];

  @override
  Widget build(BuildContext context) {
    return _TutorialPage(
      emoji: '📊',
      title: '6つの指標を管理せよ',
      body: '画面上部で国家の状態を常に確認できます。\nバランスよく保つことが繁栄の鍵。',
      extra: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _stats
            .map((s) => _LegendChip(emoji: s[0], label: s[1], sub: s[2]))
            .toList(),
      ),
    );
  }
}

// 3. 派閥
class _FactionPage extends StatelessWidget {
  const _FactionPage();

  @override
  Widget build(BuildContext context) {
    return _TutorialPage(
      emoji: '⚖️',
      title: '4つの派閥の顔色を伺え',
      body: 'あなたの決断は各派閥の支持を左右します。\n'
          '軍部の支持を失えばクーデター、\n国民の支持を失えば革命が起こります。',
      extra: Column(
        children: Faction.values
            .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Text(f.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56,
                        child: Text(
                          f.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          f.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// 4. スワイプ操作（アニメ実演）
class _SwipePage extends StatelessWidget {
  const _SwipePage();

  @override
  Widget build(BuildContext context) {
    return _TutorialPage(
      emoji: '👆',
      title: 'カードを左右にスワイプ',
      body: '政策カードを左右にスワイプして決断します。\n'
          '左右で異なる選択肢。上部にどちらを選ぶか表示されます。\n\n'
          '3つ以上の選択肢がある時は\nカード下のボタンから選べます。',
      extra: _SwipeDemo(),
    );
  }
}

// 5. ゲームオーバー
class _GameOverPage extends StatelessWidget {
  const _GameOverPage();

  @override
  Widget build(BuildContext context) {
    return const _TutorialPage(
      emoji: '🔥',
      title: '国家を存続させよ',
      body: '満足度・安定度・GDPが尽きるか、\n派閥に見放されるとゲームオーバー。\n\n'
          '7日で1年。長く国を治め、\n歴史に名を刻む指導者を目指しましょう。\n\n'
          '準備はいいですか？',
    );
  }
}

// ─────────────────────────────────────────────
// パーツ
// ─────────────────────────────────────────────
class _LegendChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;

  const _LegendChip({required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

/// スワイプ操作のループアニメ実演。
class _SwipeDemo extends StatefulWidget {
  @override
  State<_SwipeDemo> createState() => _SwipeDemoState();
}

class _SwipeDemoState extends State<_SwipeDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value; // -1..1
        final dx = t * 60;
        final rot = t * 0.12;
        final tintRight = t > 0 ? t : 0.0;
        final tintLeft = t < 0 ? -t : 0.0;
        return SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // カード
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.rotate(
                  angle: rot,
                  child: Container(
                    width: 180,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.surfaceLight, AppTheme.surface],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppTheme.gold.withOpacity(0.3), width: 1.2),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: tintLeft > 0
                                  ? AppTheme.danger.withOpacity(tintLeft * 0.3)
                                  : AppTheme.good.withOpacity(tintRight * 0.3),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text('📋',
                              style: TextStyle(fontSize: 40)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 指
              Transform.translate(
                offset: Offset(dx, 34),
                child: const Text('👆', style: TextStyle(fontSize: 34)),
              ),
              // 左右ラベル
              const Positioned(
                left: 0,
                child: Icon(Icons.arrow_back, color: AppTheme.danger),
              ),
              const Positioned(
                right: 0,
                child: Icon(Icons.arrow_forward, color: AppTheme.good),
              ),
            ],
          ),
        );
      },
    );
  }
}
