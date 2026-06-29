import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/utils/constants.dart';

class CountryStatusCard extends StatelessWidget {
  final CountryStatus status;

  const CountryStatusCard({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthScore = status.healthScore;
    final healthColor = _getHealthColor(healthScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘルススコア
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏛️ 国家の健全性',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${healthScore.toStringAsFixed(0)}/100',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),

            // ヘルススコアバー
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
              child: LinearProgressIndicator(
                value: healthScore / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              ),
            ),

            const SizedBox(height: AppConstants.paddingL),

            // ステータス詳細
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.paddingM,
                crossAxisSpacing: AppConstants.paddingM,
                childAspectRatio: 1.2,
              ),
              children: [
                _StatBox(
                  icon: '💰',
                  label: 'GDP',
                  value: '\$${status.gdp.toStringAsFixed(0)}B',
                  color: Color(VisualConstants.colorGood),
                ),
                _StatBox(
                  icon: '👥',
                  label: '失業率',
                  value: '${status.unemployment.toStringAsFixed(1)}%',
                  color: status.unemployment > 7
                      ? Color(VisualConstants.colorDanger)
                      : Color(VisualConstants.colorGood),
                ),
                _StatBox(
                  icon: '😊',
                  label: '国民満足度',
                  value: '${status.satisfaction.toStringAsFixed(0)}',
                  color: status.satisfaction > 60
                      ? Color(VisualConstants.colorGood)
                      : Color(VisualConstants.colorWarning),
                ),
                _StatBox(
                  icon: '📈',
                  label: '国力',
                  value: '${status.nationalPower.toStringAsFixed(0)}',
                  color: Color(VisualConstants.colorPrimary),
                ),
                _StatBox(
                  icon: '📉',
                  label: 'インフレ率',
                  value: '${status.inflationRate.toStringAsFixed(1)}%',
                  color: status.inflationRate > 5
                      ? Color(VisualConstants.colorWarning)
                      : Color(VisualConstants.colorGood),
                ),
                _StatBox(
                  icon: '🛡️',
                  label: '経済安定度',
                  value: '${status.stability.toStringAsFixed(0)}',
                  color: Color(VisualConstants.colorPrimary),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingM),

            // 進捗バー
            Row(
              children: [
                Text(
                  '年の進捗: ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: status.yearProgress,
                      minHeight: 4,
                    ),
                  ),
                ),
                Text(
                  ' ${status.day}/7日',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double score) {
    if (score >= 75) return Color(VisualConstants.colorGood);
    if (score >= 50) return Color(VisualConstants.colorWarning);
    return Color(VisualConstants.colorDanger);
  }
}

class _StatBox extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        color: color.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingS),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
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
    );
  }
}
