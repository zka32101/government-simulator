/// ストーリーパック選択画面
/// ユーザーがテーマ別にシナリオを選択できる新しいゲーム開始フロー

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/story_pack.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/services/story_pack_service.dart';
import 'package:government_simulator/services/scenario_service.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// ストーリーパック選択画面
class StoryPacksScreen extends ConsumerStatefulWidget {
  final Function(GameScenario) onScenarioSelected;

  const StoryPacksScreen({
    Key? key,
    required this.onScenarioSelected,
  }) : super(key: key);

  @override
  ConsumerState<StoryPacksScreen> createState() => _StoryPacksScreenState();
}

class _StoryPacksScreenState extends ConsumerState<StoryPacksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedPackId;
  List<GameScenario>? _selectedPackScenarios;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectPack(String packId) {
    setState(() {
      _selectedPackId = packId;
      _selectedPackScenarios = StoryPackService.getScenariosInPack(packId);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPackId = null;
      _selectedPackScenarios = null;
    });
  }

  void _onScenarioSelected(GameScenario scenario) {
    widget.onScenarioSelected(scenario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('📚 ストーリーパック'),
        elevation: 0,
        backgroundColor: AppTheme.bg,
      ),
      body: _selectedPackId == null
          ? _buildPacksList()
          : _buildScenarioSelection(),
    );
  }

  /// パック一覧を表示
  Widget _buildPacksList() {
    final packs = StoryPackService.getUnlockedPacks();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'テーマ別シナリオ集',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ナラティブな世界観を通じて異なる統治の課題に取り組みます',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // パック一覧
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: packs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final pack = packs[index];
              return _StoryPackCard(
                pack: pack,
                onTap: () => _selectPack(pack.id),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// シナリオ選択画面を表示
  Widget _buildScenarioSelection() {
    final pack = StoryPackService.getPackById(_selectedPackId!);
    if (pack == null || _selectedPackScenarios == null) {
      return const Center(child: Text('パックが見つかりません'));
    }

    return Column(
      children: [
        // ヘッダー
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _clearSelection,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pack.emoji} ${pack.title}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pack.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // シナリオ一覧
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _selectedPackScenarios!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scenario = _selectedPackScenarios![index];
              return _ScenarioTile(
                scenario: scenario,
                onTap: () => _onScenarioSelected(scenario),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ストーリーパックカード
class _StoryPackCard extends StatelessWidget {
  final StoryPack pack;
  final VoidCallback onTap;

  const _StoryPackCard({
    required this.pack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scenarioCount = pack.scenarioIds.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pack.region,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 説明
            Text(
              pack.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // タグとシナリオ数
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // タグ
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: pack.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),

                // シナリオ数
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$scenarioCount シナリオ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// シナリオタイル
class _ScenarioTile extends StatelessWidget {
  final GameScenario scenario;
  final VoidCallback onTap;

  const _ScenarioTile({
    required this.scenario,
    required this.onTap,
  });

  Color _getDifficultyColor(String difficulty) {
    return switch (difficulty) {
      'easy' => const Color(0xFF4CAF50),
      'normal' => const Color(0xFF2196F3),
      'hard' => const Color(0xFFFF9800),
      'very_hard' => const Color(0xFFD32F2F),
      _ => Colors.grey,
    };
  }

  String _getDifficultyLabel(String difficulty) {
    return switch (difficulty) {
      'easy' => 'イージー',
      'normal' => 'ノーマル',
      'hard' => 'ハード',
      'very_hard' => 'ベリーハード',
      _ => '不明',
    };
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(scenario.difficulty);
    final difficultyLabel = _getDifficultyLabel(scenario.difficulty);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 国名と難易度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    scenario.countryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    difficultyLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: difficultyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 説明
            Text(
              scenario.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // 情報行
            Row(
              children: [
                _InfoBadge(
                  icon: '👥',
                  label: '${scenario.population.toInt()}M',
                ),
                const SizedBox(width: 8),
                _InfoBadge(
                  icon: '💰',
                  label: '\$${scenario.gdp.toStringAsFixed(1)}T',
                ),
                const SizedBox(width: 8),
                _InfoBadge(
                  icon: '🗳️',
                  label: scenario.politicalSystem.split(' ').first,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 情報バッジ
class _InfoBadge extends StatelessWidget {
  final String icon;
  final String label;

  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
