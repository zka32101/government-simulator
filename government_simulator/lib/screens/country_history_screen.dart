import 'package:flutter/material.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/utils/constants.dart';

class CountryHistoryScreen extends StatefulWidget {
  final GameSession gameSession;
  final DecisionHistory decisionHistory;

  const CountryHistoryScreen({
    Key? key,
    required this.gameSession,
    required this.decisionHistory,
  }) : super(key: key);

  @override
  State<CountryHistoryScreen> createState() => _CountryHistoryScreenState();
}

class _CountryHistoryScreenState extends State<CountryHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final recentDecisions = widget.decisionHistory.getRecentDecisions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 国家史'),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _shareHistory,
                icon: const Icon(Icons.share),
                label: const Text('シェア'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(VisualConstants.colorPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダー
              Card(
                color: Color(VisualConstants.colorPrimary).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏛️ ${widget.gameSession.countryName}の物語',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        '${widget.gameSession.status.year}年目 | 総決定数: ${widget.gameSession.totalDecisions}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      LinearProgressIndicator(
                        value: widget.gameSession.successRate / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.gameSession.successRate > 60
                              ? Color(VisualConstants.colorGood)
                              : Color(VisualConstants.colorWarning),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        '成功率: ${widget.gameSession.successRate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 選択履歴（タイムライン）
              if (recentDecisions.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Center(
                      child: Text(
                        'まだ意思決定がありません。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 最近の意思決定',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentDecisions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.paddingS),
                      itemBuilder: (context, index) {
                        final decision = recentDecisions[index];
                        return _HistoryCard(decision: decision);
                      },
                    ),
                  ],
                ),

              const SizedBox(height: AppConstants.paddingL),

              // シェアテキスト
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💬 シェア用テキスト',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      SelectableText(
                        _generateShareText(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateShareText() {
    final status = widget.gameSession.status;
    final text = '''
🎮 政府シミュレーターをプレイしました！

国名: ${widget.gameSession.countryName}
難易度: ${widget.gameSession.difficulty}
経過: ${widget.gameSession.status.year}年 ${widget.gameSession.status.day}日

📊 最終ステータス:
• GDP: \$${status.gdp.toStringAsFixed(0)}B
• 失業率: ${status.unemployment.toStringAsFixed(1)}%
• 国民満足度: ${status.satisfaction.toStringAsFixed(0)}/100
• 国力: ${status.nationalPower.toStringAsFixed(0)}/100

📈 成績:
• 総決定数: ${widget.gameSession.totalDecisions}
• 成功率: ${widget.gameSession.successRate.toStringAsFixed(1)}%

あなたも国家の指導者になってみませんか？
''';
    return text.trim();
  }

  void _shareHistory() {
    // TODO: Shareプラグインで実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('シェア機能は準備中です')),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Decision decision;

  const _HistoryCard({required this.decision});

  @override
  Widget build(BuildContext context) {
    final gdpDelta = decision.gdpDelta;
    final satisfactionDelta = decision.satisfactionDelta;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decision.narrative.split('\n').first,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(decision.decidedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: decision.wasPositiveOutcome
                        ? Color(VisualConstants.colorGood).withOpacity(0.2)
                        : Color(VisualConstants.colorDanger).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                  ),
                  child: Text(
                    decision.evaluationLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: decision.wasPositiveOutcome
                          ? Color(VisualConstants.colorGood)
                          : Color(VisualConstants.colorDanger),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            Row(
              children: [
                Expanded(
                  child: _DeltaIndicator(
                    icon: '💰',
                    label: 'GDP',
                    delta: gdpDelta,
                    isBetter: gdpDelta > 0,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(
                  child: _DeltaIndicator(
                    icon: '😊',
                    label: '満足度',
                    delta: satisfactionDelta,
                    isBetter: satisfactionDelta > 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DeltaIndicator extends StatelessWidget {
  final String icon;
  final String label;
  final double delta;
  final bool isBetter;

  const _DeltaIndicator({
    required this.icon,
    required this.label,
    required this.delta,
    required this.isBetter,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isBetter ? Color(VisualConstants.colorGood) : Color(VisualConstants.colorWarning);
    final arrow = delta > 0 ? '↑' : delta < 0 ? '↓' : '→';

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '$arrow${delta.abs().toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
