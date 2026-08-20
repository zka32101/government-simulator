import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_stage.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/utils/constants.dart';

/// 国家ステージ選択：様々な「国の設定（環境）」をステージ形式で選び、
/// 難易度を星の数で表現する開始画面。
class CountryStageSelectScreen extends StatelessWidget {
  final void Function(CountryStage stage) onSelect;

  const CountryStageSelectScreen({Key? key, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('🌍 ステージを選ぶ'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: CountryStage.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final stage = CountryStage.all[index];
          return _StageCard(
            stage: stage,
            onTap: () => _confirmAndStart(context, stage),
          );
        },
      ),
    );
  }

  void _confirmAndStart(BuildContext context, CountryStage stage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('${stage.emoji} ${stage.title}',
            style: const TextStyle(color: AppTheme.gold)),
        content: Text(
          '${stage.description}\n\nこのステージで統治を開始しますか？',
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
              onSelect(stage);
            },
            child: const Text('このステージで始める'),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final CountryStage stage;
  final VoidCallback onTap;

  const _StageCard({required this.stage, required this.onTap});

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
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(stage.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DifficultyStars(stars: stage.difficultyStars),
                  const SizedBox(height: 4),
                  Text(stage.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  Text(stage.description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4)),
                  const SizedBox(height: 10),
                  _StatBadgeRow(stage: stage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  final int stars;

  const _DifficultyStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    final color = stars >= 5
        ? AppTheme.danger
        : stars >= 4
            ? AppTheme.warning
            : AppTheme.gold;
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < stars ? Icons.star : Icons.star_border,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _label(stars),
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _label(int stars) {
    switch (stars) {
      case 1:
        return '易しい';
      case 2:
        return 'やや易しい';
      case 3:
        return '標準';
      case 4:
        return '難しい';
      default:
        return '最難関';
    }
  }
}

class _StatBadgeRow extends StatelessWidget {
  final CountryStage stage;

  const _StatBadgeRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _badge('💰 \$${stage.gdp.toStringAsFixed(0)}B'),
        _badge('👷 ${stage.unemployment.toStringAsFixed(0)}%'),
        _badge('😊 ${stage.satisfaction.toStringAsFixed(0)}'),
        _badge('🏛️ ${stage.stability.toStringAsFixed(0)}'),
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
