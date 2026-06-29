import 'package:flutter/material.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/achievement.dart';
import 'package:government_simulator/utils/app_theme.dart';

class GameOverScreen extends StatefulWidget {
  final GameSession session;
  final GameOverType type;
  final VoidCallback onRestart;

  const GameOverScreen({
    Key? key,
    required this.session,
    required this.type,
    required this.onRestart,
  }) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A1212), Color(0xFF0E1420)],
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
                  child: Text(widget.type.emoji,
                      style: const TextStyle(fontSize: 90)),
                ),
                const SizedBox(height: 16),
                const Text('GAME OVER',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 4,
                      color: AppTheme.danger,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                Text(
                  widget.type.title,
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
                    widget.type.message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),

                // 統治記録
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
                      _row('解除した実績', '${s.unlockedAchievements.length}個'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

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
