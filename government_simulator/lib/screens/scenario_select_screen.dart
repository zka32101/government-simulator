import 'package:flutter/material.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/utils/constants.dart';

/// 「歴史のif」チャレンジ：固定の初期ステータスを持つシナリオから選んで開始する。
class ScenarioSelectScreen extends StatelessWidget {
  final void Function(HistoricalScenario scenario) onSelect;

  const ScenarioSelectScreen({Key? key, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('📖 歴史のIfチャレンジ'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: HistoricalScenario.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final scenario = HistoricalScenario.all[index];
          return _ScenarioCard(
            scenario: scenario,
            onTap: () => _confirmAndStart(context, scenario),
          );
        },
      ),
    );
  }

  void _confirmAndStart(BuildContext context, HistoricalScenario scenario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('${scenario.emoji} ${scenario.title}',
            style: const TextStyle(color: AppTheme.gold)),
        content: Text(
          '${scenario.description}\n\nこのシナリオで統治を開始しますか？',
          style: const TextStyle(color: AppTheme.textPrimary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSelect(scenario);
            },
            child: const Text('挑戦する'),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final HistoricalScenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                scenario.imagePath,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Text(scenario.emoji,
                    style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scenario.era,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(scenario.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  Text(scenario.description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4)),
                  const SizedBox(height: 10),
                  _StatBadgeRow(scenario: scenario),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadgeRow extends StatelessWidget {
  final HistoricalScenario scenario;

  const _StatBadgeRow({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _badge('💰 \$${scenario.gdp.toStringAsFixed(0)}B'),
        _badge('👷 ${scenario.unemployment.toStringAsFixed(0)}%'),
        _badge('😊 ${scenario.satisfaction.toStringAsFixed(0)}'),
        _badge('🏛️ ${scenario.stability.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    );
  }
}
