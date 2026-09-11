import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/campaign.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/utils/app_theme.dart';
import 'package:government_simulator/widgets/campaign_launch_dialog.dart';
import 'package:government_simulator/widgets/budget_dashboard.dart';

/// キャンペーン管理画面
/// プレイヤーのキャンペーンと対立候補者のカウンターキャンペーンを表示・管理
class CampaignScreen extends ConsumerStatefulWidget {
  final String countryName;

  const CampaignScreen({
    Key? key,
    required this.countryName,
  }) : super(key: key);

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen> {
  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(gameSessionProvider);
    final session = sessionState.session;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('選挙キャンペーン'),
          backgroundColor: AppTheme.gold,
        ),
        body: const Center(
          child: Text('ゲームセッションが読み込まれていません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('選挙キャンペーン'),
        backgroundColor: AppTheme.gold,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 予算ダッシュボード
              _buildBudgetDashboard(session),
              const SizedBox(height: 24),

              // アクティブなキャンペーン
              Text(
                'アクティブキャンペーン',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (session.activeCampaigns.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'アクティブなキャンペーンはありません',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...session.activeCampaigns.map((campaign) {
                  final isActive = campaign.isActiveInWeek(
                    session.status.year,
                    session.status.week,
                  );
                  return _buildCampaignCard(context, campaign, isActive);
                }).toList(),
              const SizedBox(height: 24),

              // ライバルのカウンターキャンペーン
              if (session.rivalCampaigns.isNotEmpty) ...[
                Text(
                  'ライバルのカウンターキャンペーン',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...session.rivalCampaigns.map((campaign) {
                  final isActive = campaign.isActiveInWeek(
                    session.status.year,
                    session.status.week,
                  );
                  return _buildCounterCampaignCard(
                    context,
                    campaign,
                    isActive,
                  );
                }).toList(),
              ],
              const SizedBox(height: 24),

              // キャンペーン開始ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await CampaignLaunchDialog.show(
                      context,
                      availableBudget: session.campaignBudget -
                          session.spentBudget,
                      currentYear: session.status.year,
                      currentWeek: session.status.week,
                      difficulty: session.difficulty,
                      onLaunch: (type, durationWeeks, budgetSpent) {
                        _launchCampaign(
                          session,
                          type,
                          durationWeeks,
                          budgetSpent,
                        );
                      },
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('キャンペーンを開始しました'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.campaign),
                  label: const Text('新しいキャンペーン開始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetDashboard(GameSession session) {
    return BudgetDashboard(
      title: 'キャンペーン予算',
      totalBudget: session.campaignBudget,
      spentBudget: session.spentBudget,
      showDetails: true,
    );
  }

  Widget _buildCampaignCard(
    BuildContext context,
    Campaign campaign,
    bool isActive,
  ) {
    final progressWeeks = campaign.startWeek + campaign.durationWeeks - 1;
    final currentWeek = context.read(gameSessionProvider).session?.status.week ?? 1;
    final weekProgress = ((currentWeek - campaign.startWeek + 1) /
            campaign.durationWeeks)
        .clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  campaign.type.label.split(' ')[0], // 絵文字
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        campaign.type.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.good.withOpacity(0.2)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isActive ? '進行中' : '未開始',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppTheme.good : AppTheme.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 進捗バー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '進捗',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(weekProgress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: weekProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 詳細情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  '効果度',
                  '${campaign.effectiveness.toStringAsFixed(1)}%',
                ),
                _buildInfoChip(
                  '最大上昇',
                  '${campaign.maxSupportBoost.toStringAsFixed(1)}%',
                ),
                _buildInfoChip(
                  '期間',
                  '${campaign.durationWeeks}週間',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCampaignCard(
    BuildContext context,
    CounterCampaign campaign,
    bool isActive,
  ) {
    final rivalry = 'ライバル候補者';
    final currentWeek = context.read(gameSessionProvider).session?.status.week ?? 1;
    final weekProgress = ((currentWeek - campaign.startWeek + 1) /
            campaign.durationWeeks)
        .clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  '⚔️',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${campaign.type.label} | $rivalry',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    campaign.isRetaliatory ? '報復キャンペーン' : 'カウンター',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 進捗バー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '進捗',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(weekProgress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: weekProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 詳細情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  '効果度',
                  '${campaign.effectiveness.toStringAsFixed(1)}%',
                ),
                _buildInfoChip(
                  '最大上昇',
                  '${campaign.maxSupportBoost.toStringAsFixed(1)}%',
                ),
                _buildInfoChip(
                  '期間',
                  '${campaign.durationWeeks}週間',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      backgroundColor: AppTheme.gold.withOpacity(0.15),
    );
  }

  void _launchCampaign(
    GameSession session,
    CampaignType type,
    int durationWeeks,
    double budgetSpent,
  ) async {
    try {
      await ref.read(gameSessionProvider.notifier).launchCampaign(
        type: type,
        durationWeeks: durationWeeks,
        budgetSpent: budgetSpent,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('キャンペーン開始に失敗しました: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
