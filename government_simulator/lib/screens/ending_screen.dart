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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                const SizedBox(height: 28),

                Container(
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
                const SizedBox(height: 20),

                Container(
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
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(w,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFF44336))),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (widget.onGenerateHistoryBook != null) ...[
                  HistoryBookButton(onGenerate: widget.onGenerateHistoryBook!),
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
