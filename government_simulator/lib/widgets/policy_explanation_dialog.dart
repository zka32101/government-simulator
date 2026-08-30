import 'package:flutter/material.dart';
import 'package:government_simulator/models/policy_explanation.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 政策選択肢の経済学的説明をダイアログで表示。
/// ゲーム中の決定時に参考資料として活用できる。
class PolicyExplanationDialog extends StatelessWidget {
  final PolicyExplanation explanation;
  final VoidCallback? onClose;

  const PolicyExplanationDialog({
    Key? key,
    required this.explanation,
    this.onClose,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    PolicyExplanation explanation,
  ) {
    return showDialog(
      context: context,
      builder: (context) => PolicyExplanationDialog(
        explanation: explanation,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      explanation.policyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '理論: ${explanation.economicTheory}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 各セクション
              _buildSection(
                title: '作用メカニズム',
                content: explanation.mechanism,
                accentColor: AppTheme.textPrimary,
              ),
              _buildSection(
                title: '期待される効果',
                content: explanation.expectedOutcomes,
                accentColor: AppTheme.good,
              ),
              _buildSection(
                title: 'リスク・副作用',
                content: explanation.risks,
                accentColor: AppTheme.danger,
              ),
              _buildSection(
                title: '歴史的事例',
                content: explanation.historicalPrecedents,
                accentColor: AppTheme.textPrimary,
              ),
              const SizedBox(height: 16),
              // 学習ポイント（ハイライト表示）
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 学習ポイント',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation.keyTakeaway,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gold,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 関連概念タグ
              if (explanation.relatedConcepts.isNotEmpty) ...[
                Text(
                  '関連概念',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: explanation.relatedConcepts
                      .map((concept) => Chip(
                        label: Text(concept),
                        backgroundColor: AppTheme.gold.withOpacity(0.2),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold,
                        ),
                      ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '了解',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
