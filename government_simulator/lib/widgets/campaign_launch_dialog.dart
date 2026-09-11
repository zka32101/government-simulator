import 'package:flutter/material.dart';
import 'package:government_simulator/models/campaign.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// キャンペーン開始ダイアログ
/// プレイヤーがキャンペーンタイプを選択し、期間・予算を設定する
class CampaignLaunchDialog extends StatefulWidget {
  final double availableBudget;
  final int currentYear;
  final int currentWeek;
  final String difficulty;
  final Function(CampaignType, int, double) onLaunch; // type, durationWeeks, budgetSpent

  const CampaignLaunchDialog({
    Key? key,
    required this.availableBudget,
    required this.currentYear,
    required this.currentWeek,
    required this.difficulty,
    required this.onLaunch,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    required double availableBudget,
    required int currentYear,
    required int currentWeek,
    required String difficulty,
    required Function(CampaignType, int, double) onLaunch,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CampaignLaunchDialog(
        availableBudget: availableBudget,
        currentYear: currentYear,
        currentWeek: currentWeek,
        difficulty: difficulty,
        onLaunch: onLaunch,
      ),
    );
  }

  @override
  State<CampaignLaunchDialog> createState() => _CampaignLaunchDialogState();
}

class _CampaignLaunchDialogState extends State<CampaignLaunchDialog> {
  CampaignType? _selectedType;
  int _durationWeeks = 4;
  double _budgetSpent = 0;
  double _projectedEffectiveness = 0;
  double _projectedMaxBoost = 0;

  @override
  void initState() {
    super.initState();
    // デフォルトで最初のキャンペーンタイプを選択
    _selectedType = CampaignType.tvAds;
    _updateProjection();
  }

  void _updateProjection() {
    if (_selectedType == null) return;

    // 基本効果度を計算
    final effectiveness = CampaignManager.calculateInitialEffectiveness(
      type: _selectedType!,
      budgetSpent: _budgetSpent,
      difficulty: widget.difficulty,
    );

    // 最大支持率上昇を計算
    final maxBoost = CampaignManager.calculateMaxSupportBoost(_selectedType!);

    setState(() {
      _projectedEffectiveness = effectiveness;
      _projectedMaxBoost = maxBoost;
    });
  }

  double _getBaseCost(CampaignType type) {
    final difficultyMap = CampaignManager.costByDifficulty[widget.difficulty];
    return difficultyMap?[type] ?? type.baseCost;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedType == null) {
      return const Dialog(child: SizedBox());
    }

    final baseCost = _getBaseCost(_selectedType!);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.surface,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'キャンペーン開始',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // キャンペーンタイプセレクタ
              Text(
                'キャンペーン種類',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildCampaignTypeSelector(),
              const SizedBox(height: 20),

              // キャンペーン情報カード
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('基本コスト', '${baseCost.toStringAsFixed(0)}千円'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '基本効果度',
                      '${_selectedType!.baseEffectiveness.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '最大支持率上昇',
                      '${CampaignManager.calculateMaxSupportBoost(_selectedType!).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 予算スライダー
              Text(
                'キャンペーン予算',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _budgetSpent.clamp(0, widget.availableBudget),
                      min: baseCost,
                      max: widget.availableBudget,
                      divisions: ((widget.availableBudget - baseCost) / 10).toInt(),
                      label: '${_budgetSpent.toStringAsFixed(0)}千円',
                      activeColor: AppTheme.gold,
                      onChanged: (value) {
                        setState(() => _budgetSpent = value);
                        _updateProjection();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${_budgetSpent.toStringAsFixed(0)}千円',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gold,
                          ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              Text(
                '利用可能予算: ${widget.availableBudget.toStringAsFixed(0)}千円',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),

              // 期間スライダー
              Text(
                'キャンペーン期間',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _durationWeeks.toDouble(),
                      min: 1,
                      max: 52,
                      divisions: 51,
                      label: '$_durationWeeks週間',
                      activeColor: AppTheme.accent,
                      onChanged: (value) {
                        setState(() => _durationWeeks = value.toInt());
                        _updateProjection();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '$_durationWeeks週間',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 効果予測
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.good.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.good.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 効果予測',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.good,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '実効効果度',
                      '${_projectedEffectiveness.toStringAsFixed(1)}%',
                      valueColor: AppTheme.good,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      '最大支持率上昇幅',
                      '${_projectedMaxBoost.toStringAsFixed(1)}%',
                      valueColor: AppTheme.good,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'キャンペーン効果は期間中に山型曲線で推移します。'
                      '初期段階は低く、中盤がピーク、終盤は減衰します。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _budgetSpent > 0 && _budgetSpent <= widget.availableBudget
                          ? () {
                              widget.onLaunch(
                                _selectedType!,
                                _durationWeeks,
                                _budgetSpent,
                              );
                              Navigator.pop(context, true);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'キャンペーン開始',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignTypeSelector() {
    return Column(
      children: CampaignType.values.map((type) {
        final isSelected = _selectedType == type;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() => _selectedType = type);
              _updateProjection();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.gold.withOpacity(0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      type.label.split(' ')[0], // 絵文字を取得
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '基本コスト: ${type.baseCost.toStringAsFixed(0)}千円',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.gold),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color valueColor = AppTheme.gold,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
