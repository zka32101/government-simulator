/// シナリオ選択画面
/// プレイヤーが複数の仮想国シナリオから選択できる

import 'package:flutter/material.dart';
import 'package:government_simulator/models/scenario.dart';
import 'package:government_simulator/services/scenario_service.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  final Function(GameScenario) onScenarioSelected;

  const ScenarioSelectionScreen({
    Key? key,
    required this.onScenarioSelected,
  }) : super(key: key);

  @override
  State<ScenarioSelectionScreen> createState() =>
      _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedScenarioId;
  String _filterDifficulty = 'all';

  final List<String> _difficulties = ['all', 'easy', 'normal', 'hard', 'very_hard'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<GameScenario> _getFilteredScenarios() {
    if (_filterDifficulty == 'all') {
      return ScenarioService.allScenarios;
    }
    return ScenarioService.getScenariosByDifficulty(_filterDifficulty);
  }

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
      'very_hard' => '超ハード',
      _ => difficulty,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredScenarios = _getFilteredScenarios();

    return Scaffold(
      appBar: AppBar(
        title: const Text('シナリオ選択'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ヘッダー情報
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0, 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '複数の仮想国シナリオをプレイ可能',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ScenarioService.allScenarios.length}個のシナリオが利用可能です。'
                      '難易度と地域背景により、異なるゲーム体験が得られます。',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 難易度フィルター
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.2, 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '難易度でフィルター',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _difficulties.map((difficulty) {
                          final isSelected = _filterDifficulty == difficulty;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                difficulty == 'all'
                                    ? 'すべて'
                                    : _getDifficultyLabel(difficulty),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _filterDifficulty = difficulty;
                                  _selectedScenarioId = null;
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: _getDifficultyColor(difficulty),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // シナリオリスト
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 0.8),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredScenarios.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final scenario = filteredScenarios[index];
                    final isSelected = _selectedScenarioId == scenario.id;

                    return _ScenarioCard(
                      scenario: scenario,
                      isSelected: isSelected,
                      difficultyColor:
                          _getDifficultyColor(scenario.difficulty),
                      onTap: () {
                        setState(() {
                          _selectedScenarioId = scenario.id;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 詳細情報パネル
            if (_selectedScenarioId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 1.0),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.6, 1.0),
                      ),
                    ),
                    child: _ScenarioDetailPanel(
                      scenario: ScenarioService.getScenarioById(
                        _selectedScenarioId!,
                      )!,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // 開始ボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedScenarioId != null
                      ? () {
                          final scenario = ScenarioService.getScenarioById(
                            _selectedScenarioId!,
                          );
                          if (scenario != null) {
                            widget.onScenarioSelected(scenario);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('このシナリオでプレイ開始'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// シナリオカード
class _ScenarioCard extends StatelessWidget {
  final GameScenario scenario;
  final bool isSelected;
  final Color difficultyColor;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.isSelected,
    required this.difficultyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? difficultyColor.withOpacity(0.1)
          : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? difficultyColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.countryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scenario.region,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getDifficultyLabel(scenario.difficulty),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scenario.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.people,
                      label: '${scenario.population.toStringAsFixed(0)}M',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.trending_up,
                      label: '\$${scenario.gdp.toStringAsFixed(1)}T',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.percent,
                      label: '${scenario.initialApproval.toStringAsFixed(0)}%',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: difficultyColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '選択中',
                      style: TextStyle(
                        color: difficultyColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    return switch (difficulty) {
      'easy' => 'イージー',
      'normal' => 'ノーマル',
      'hard' => 'ハード',
      'very_hard' => '超ハード',
      _ => difficulty,
    };
  }
}

/// 情報チップ
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// シナリオ詳細パネル
class _ScenarioDetailPanel extends StatelessWidget {
  final GameScenario scenario;

  const _ScenarioDetailPanel({
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'シナリオの詳細',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: '初期承認度',
            value: '${scenario.initialApproval.toStringAsFixed(1)}%',
          ),
          _DetailRow(
            label: '予算',
            value: '\$${scenario.budget.toStringAsFixed(0)}百万',
          ),
          _DetailRow(
            label: '国債',
            value: '\$${scenario.nationalDebt.toStringAsFixed(0)}十億',
          ),
          const SizedBox(height: 12),
          const Text(
            '主要課題',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...scenario.currentChallenges.take(3).map((challenge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      challenge,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
