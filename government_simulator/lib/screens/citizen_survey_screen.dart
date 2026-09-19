/// 国民世論調査画面
/// 各政策トピックへの国民の優先度・満足度を確認し、予算を投じて対応できる

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/services/citizen_survey_service.dart';
import 'package:government_simulator/utils/app_theme.dart';

class CitizenSurveyScreen extends ConsumerStatefulWidget {
  const CitizenSurveyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CitizenSurveyScreen> createState() => _CitizenSurveyScreenState();
}

class _CitizenSurveyScreenState extends ConsumerState<CitizenSurveyScreen> {
  bool _loading = false;

  Future<void> _conductSurvey() async {
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(gameSessionProvider.notifier).conductCitizenSurvey(session);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _address(OpinionTopic topic, double amount) async {
    final session = ref.read(gameSessionProvider).session;
    if (session == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(gameSessionProvider.notifier)
          .addressPublicOpinion(session, topic, amount);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showInvestmentSheet(OpinionTopic topic) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${topic.emoji} ${topic.label}への対応予算',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final preset in const [
              (label: '5億ドル（小規模）', value: 500000000.0),
              (label: '10億ドル（標準）', value: 1000000000.0),
              (label: '20億ドル（大規模）', value: 2000000000.0),
            ])
              ListTile(
                title: Text(preset.label),
                onTap: () => Navigator.pop(ctx, preset.value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (amount != null) {
      await _address(topic, amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider).session;
    final survey = session?.latestSurvey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('国民世論調査'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '再調査を実施',
            onPressed: _loading ? null : _conductSurvey,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : survey == null
              ? _buildEmptyState()
              : _buildSurveyBody(survey),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'まだ世論調査を実施していません。\n国民が政策をどう評価しているか確認しましょう。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _conductSurvey,
              icon: const Icon(Icons.poll),
              label: const Text('世論調査を実施する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyBody(SurveyResult survey) {
    final topics = survey.opinions.values.toList()
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('サンプル数：${survey.sampleSize}人　信頼度：${survey.confidenceLevel.toStringAsFixed(0)}%'),
                const SizedBox(height: 4),
                Text('平均満足度：${survey.averageSatisfaction.toStringAsFixed(1)}%'),
                if (survey.topPriority != null)
                  Text('最重要トピック：${survey.topPriority!.emoji} ${survey.topPriority!.label}'),
                if (survey.mostDissatisfied != null)
                  Text('最も不満なトピック：${survey.mostDissatisfied!.emoji} ${survey.mostDissatisfied!.label}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final opinion in topics) _buildTopicCard(opinion),
      ],
    );
  }

  Widget _buildTopicCard(CitizenOpinion opinion) {
    final topic = opinion.topic;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${topic.emoji} ', style: const TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(
                    topic.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => _showInvestmentSheet(topic),
                  child: const Text('対応する'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildBarRow('優先度', opinion.priority, Colors.orange),
            const SizedBox(height: 6),
            _buildBarRow('満足度', opinion.satisfaction, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildBarRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 48, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text('${value.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
