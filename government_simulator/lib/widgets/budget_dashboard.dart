import 'package:flutter/material.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 予算ダッシュボード
/// キャンペーン予算の利用状況を視覚的に表示
class BudgetDashboard extends StatelessWidget {
  final double totalBudget;
  final double spentBudget;
  final String? title;
  final bool showDetails;

  const BudgetDashboard({
    Key? key,
    required this.totalBudget,
    required this.spentBudget,
    this.title,
    this.showDetails = true,
  }) : super(key: key);

  double get availableBudget => (totalBudget - spentBudget).clamp(0, totalBudget);

  double get spentPercentage =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0.0;

  Color get statusColor {
    if (spentPercentage > 0.9) return Colors.red;
    if (spentPercentage > 0.7) return Colors.orange;
    return AppTheme.gold;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
          ],
          if (showDetails)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetCard(
                  context,
                  '利用可能',
                  '${availableBudget.toStringAsFixed(0)}千円',
                  AppTheme.good,
                ),
                _buildBudgetCard(
                  context,
                  '使用済み',
                  '${spentBudget.toStringAsFixed(0)}千円',
                  AppTheme.textPrimary,
                ),
                _buildBudgetCard(
                  context,
                  '総予算',
                  '${totalBudget.toStringAsFixed(0)}千円',
                  AppTheme.gold,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '利用可能',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${availableBudget.toStringAsFixed(0)}千円',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.good,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '使用済み',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${spentBudget.toStringAsFixed(0)}千円',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spentPercentage,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(spentPercentage * 100).toStringAsFixed(0)}% 使用中',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
