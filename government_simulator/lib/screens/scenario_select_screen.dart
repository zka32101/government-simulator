import 'package:flutter/material.dart';
import 'package:government_simulator/models/historical_scenario.dart';
import 'package:government_simulator/models/country_tier.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/widgets/staggered_entrance.dart';

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
          return StaggeredEntrance(
            index: index,
            child: _ScenarioCard(
              scenario: scenario,
              onTap: () => _confirmAndStart(context, scenario),
            ),
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
    final tier = CountryTier.evaluateStats(
      gdp: scenario.gdp,
      unemployment: scenario.unemployment,
      satisfaction: scenario.satisfaction,
      nationalPower: scenario.nationalPower,
      inflationRate: scenario.inflationRate,
      publicDebt: scenario.publicDebt,
      stability: scenario.stability,
    );

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
                  const SizedBox(height: 8),
                  // 想定国：あくまで仮想の国家分類（先進国クラス等）としての
                  // 目安表示であり、実在の国・地域を指すものではない。
                  _TierBadge(tier: tier),
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

/// 想定国バッジ：このシナリオの初期指標を、現実の国家分類になぞらえた
/// 仮想の目安（先進国クラス等）として表示する。実在の国・地域は指さない。
class _TierBadge extends StatelessWidget {
  final CountryTier tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tier.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tier.color.withOpacity(0.5)),
      ),
      child: Text(
        '🌍 想定：${tier.label}',
        style: TextStyle(
          fontSize: 10,
          color: tier.color,
          fontWeight: FontWeight.bold,
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
