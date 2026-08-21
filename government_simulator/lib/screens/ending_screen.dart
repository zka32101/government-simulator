import 'package:flutter/material.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/ending.dart';
import 'package:government_simulator/models/country_tier.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/widgets/history_book_button.dart';

/// 自ら引退を選んだ際に表示する、12種の分岐エンディング画面。
class EndingScreen extends StatefulWidget {
  final GameSession session;
  final VoidCallback onRestart;
  final Future<String?> Function()? onGenerateHistoryBook;

  const EndingScreen({
    Key? key,
    required this.session,
    required this.onRestart,
    this.onGenerateHistoryBook,
  }) : super(key: key);

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  // 挿絵は elasticOut で弾むように登場させる一方、タイトル以下の各
  // セクション（統治記録・現実世界での評価・ボタン群）はこれまで静的に
  // 一括表示されていた。統治の結末という一番重い瞬間の画面なので、
  // 挿絵に続けて上から順にフェード＋スライドインさせ、余韻を持たせる。
  static const int _sectionCount = 4;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _staggered(int index) {
    final start = 0.25 + index / _sectionCount * 0.6;
    final end = (start + 0.35).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start.clamp(0.0, 1.0), end, curve: Curves.easeOutCubic),
    );
  }

  Widget _section({required int index, required Widget child}) {
    final anim = _staggered(index);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final ending = Ending.determine(s.status, s.status.factions);
    final tier = CountryTier.evaluate(s.status);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF12203A), Color(0xFF0E1420)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      ending.imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const Text('📜', style: TextStyle(fontSize: 90)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  index: 0,
                  child: Column(
                    children: [
                      const Text('統治の終焉',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 4,
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        ending.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          ending.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                _section(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('${s.countryName} の統治記録',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold)),
                        const SizedBox(height: 14),
                        _row('在位期間', '${s.status.year}年目'),
                        _row('意思決定数', '${s.totalDecisions}回'),
                        _row('成功率', '${s.successRate.toStringAsFixed(1)}%'),
                        _row('国家健全度',
                            '${s.status.healthScore.toStringAsFixed(0)}/100'),
                        _row('解除した実績', '${s.unlockedAchievements.length}個'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _section(
                  index: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: tier.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: tier.color.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🌍 現実世界でいうと',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text(tier.label,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: tier.color)),
                        const SizedBox(height: 6),
                        Text(tier.comparison,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text(tier.description,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.4)),
                        if (tier.warnings.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...tier.warnings.map(
                            (w) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Text(w,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFF44336))),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                _section(
                  index: 3,
                  child: Column(
                    children: [
                      if (widget.onGenerateHistoryBook != null) ...[
                        HistoryBookButton(
                            onGenerate: widget.onGenerateHistoryBook!),
                        const SizedBox(height: 14),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onRestart,
                          icon: const Icon(Icons.refresh),
                          label: const Text('新しい国家で再起する'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
