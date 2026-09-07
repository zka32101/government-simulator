import 'package:flutter/material.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/models/indicator_history.dart';
import 'package:government_simulator/widgets/indicator_chart.dart';
import 'package:government_simulator/widgets/budget_breakdown_chart.dart';
import 'package:government_simulator/utils/constants.dart';

/// 国家統計情報を可視化するスクリーン。
/// 複数の指標をグラフで表示し、プレイヤーが自分の政策の効果を
/// 視覚的に理解できるようにする。
class StatisticsScreen extends StatefulWidget {
  final GameSession gameSession;

  const StatisticsScreen({
    Key? key,
    required this.gameSession,
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  IndicatorSnapshot? _selectedDataPoint;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 国家統計'),
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '経済指標'),
            Tab(text: '社会指標'),
            Tab(text: '国力'),
            Tab(text: '💰 予算配分'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildEconomicTab(),
            _buildSocialTab(),
            _buildPowerTab(),
            _buildBudgetTab(),
          ],
        ),
      ),
    );
  }

  /// 経済指標タブ
  Widget _buildEconomicTab() {
    final history = widget.gameSession.indicatorHistory;
    if (history.isEmpty) {
      return _buildEmptyHistoryMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        children: [
          IndicatorChart(
            indicatorKey: 'gdp',
            indicatorLabel: 'GDP',
            unit: 'B',
            chartColor: Colors.blue,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          IndicatorChart(
            indicatorKey: 'inflationRate',
            indicatorLabel: 'インフレ率',
            unit: '%',
            chartColor: Colors.orange,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          IndicatorChart(
            indicatorKey: 'publicDebt',
            indicatorLabel: '公的債務対GDP比',
            unit: '%',
            chartColor: Colors.red,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          if (_selectedDataPoint != null) _buildDetailsPanel(),
        ],
      ),
    );
  }

  /// 社会指標タブ
  Widget _buildSocialTab() {
    final history = widget.gameSession.indicatorHistory;
    if (history.isEmpty) {
      return _buildEmptyHistoryMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        children: [
          IndicatorChart(
            indicatorKey: 'unemployment',
            indicatorLabel: '失業率',
            unit: '%',
            chartColor: Colors.red,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          IndicatorChart(
            indicatorKey: 'satisfaction',
            indicatorLabel: '国民満足度',
            unit: '',
            chartColor: Colors.green,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          IndicatorChart(
            indicatorKey: 'stability',
            indicatorLabel: '経済安定度',
            unit: '',
            chartColor: Colors.purple,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          if (_selectedDataPoint != null) _buildDetailsPanel(),
        ],
      ),
    );
  }

  /// 国力タブ
  Widget _buildPowerTab() {
    final history = widget.gameSession.indicatorHistory;
    if (history.isEmpty) {
      return _buildEmptyHistoryMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        children: [
          IndicatorChart(
            indicatorKey: 'nationalPower',
            indicatorLabel: '国力',
            unit: '',
            chartColor: Colors.amber,
            history: history,
            onTapDataPoint: (snapshot) {
              setState(() => _selectedDataPoint = snapshot);
            },
          ),
          const SizedBox(height: AppConstants.paddingL),
          _buildNationalPowerExplanation(),
          const SizedBox(height: AppConstants.paddingL),
          if (_selectedDataPoint != null) _buildDetailsPanel(),
        ],
      ),
    );
  }

  /// 国力の説明パネル
  Widget _buildNationalPowerExplanation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '国力について',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              '国力は以下の要因により決定されます：',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.paddingS),
            _buildExplanationBullet('📊 経済規模（GDP）'),
            _buildExplanationBullet('⚔️ 防衛力（防衛支出）'),
            _buildExplanationBullet('🌍 外交スキル（国際関係）'),
            _buildExplanationBullet('👥 人口と資源（産業基盤）'),
          ],
        ),
      ),
    );
  }

  /// 説明用のバレットポイント
  Widget _buildExplanationBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
      child: Row(
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// 選択されたデータポイントの詳細パネル
  Widget _buildDetailsPanel() {
    if (_selectedDataPoint == null) {
      return const SizedBox.shrink();
    }

    final snapshot = _selectedDataPoint!;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Year ${snapshot.year} の詳細',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            _buildDetailRow('GDP', '\$${snapshot.gdp.toStringAsFixed(0)}B'),
            _buildDetailRow(
              '失業率',
              '${snapshot.unemployment.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              '満足度',
              '${snapshot.satisfaction.toStringAsFixed(1)}',
            ),
            _buildDetailRow(
              '国力',
              '${snapshot.nationalPower.toStringAsFixed(1)}',
            ),
            _buildDetailRow(
              'インフレ',
              '${snapshot.inflationRate.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              '公債比',
              '${snapshot.publicDebt.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              '安定度',
              '${snapshot.stability.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }

  /// 詳細行の構築
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// ヒストリーが空の場合のメッセージ
  Widget _buildEmptyHistoryMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'まだデータがありません',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'ゲームを進めるとグラフが表示されます',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 予算配分タブ
  Widget _buildBudgetTab() {
    final budget = widget.gameSession.status.budget;

    return BudgetBreakdownChart(
      budget: budget,
      onSectorTap: (sector) {
        // セクタータップ時の処理（現在は何もしない）
      },
    );
  }
}
