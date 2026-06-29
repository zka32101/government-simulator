import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/utils/constants.dart';

class EventDetailScreen extends StatefulWidget {
  final CountryStatus beforeStatus;
  final CountryStatus afterStatus;
  final Choice choice;
  final double impactScore;

  const EventDetailScreen({
    Key? key,
    required this.beforeStatus,
    required this.afterStatus,
    required this.choice,
    required this.impactScore,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late GameLogicService _gameLogic;

  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogicService();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrative = _gameLogic.generateNarrative(
      widget.choice,
      widget.beforeStatus,
      widget.afterStatus,
    );

    final evaluation = _getEvaluation(widget.impactScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('決定の結果'),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 結果評価
              ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
                ),
                child: Card(
                  color: evaluation.color,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Column(
                      children: [
                        Text(
                          evaluation.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Text(
                          evaluation.label,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                        Text(
                          'インパクトスコア: ${widget.impactScore.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // ナレーション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📖 ナレーション',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Text(
                        narrative,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // ステータス変化
              Text(
                '📊 ステータス変化',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.paddingM),

              _StatusChangeRow(
                icon: '💰',
                label: 'GDP',
                before: '\$${widget.beforeStatus.gdp.toStringAsFixed(0)}B',
                after: '\$${widget.afterStatus.gdp.toStringAsFixed(0)}B',
                delta: widget.afterStatus.gdp - widget.beforeStatus.gdp,
                isPositiveBetter: true,
              ),

              _StatusChangeRow(
                icon: '👥',
                label: '失業率',
                before: '${widget.beforeStatus.unemployment.toStringAsFixed(1)}%',
                after: '${widget.afterStatus.unemployment.toStringAsFixed(1)}%',
                delta: widget.afterStatus.unemployment - widget.beforeStatus.unemployment,
                isPositiveBetter: false,
              ),

              _StatusChangeRow(
                icon: '😊',
                label: '国民満足度',
                before: '${widget.beforeStatus.satisfaction.toStringAsFixed(0)}',
                after: '${widget.afterStatus.satisfaction.toStringAsFixed(0)}',
                delta: widget.afterStatus.satisfaction - widget.beforeStatus.satisfaction,
                isPositiveBetter: true,
              ),

              _StatusChangeRow(
                icon: '📈',
                label: '国力',
                before: '${widget.beforeStatus.nationalPower.toStringAsFixed(0)}',
                after: '${widget.afterStatus.nationalPower.toStringAsFixed(0)}',
                delta: widget.afterStatus.nationalPower - widget.beforeStatus.nationalPower,
                isPositiveBetter: true,
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 次へボタン
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('次の決定へ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                    vertical: AppConstants.paddingM,
                  ),
                  backgroundColor: Color(VisualConstants.colorPrimary),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _Evaluation _getEvaluation(double score) {
    if (score > 50) {
      return _Evaluation(
        label: '卓越した決定！',
        emoji: '🎉',
        color: Color(VisualConstants.colorGood),
      );
    } else if (score > 20) {
      return _Evaluation(
        label: '良い決定',
        emoji: '👍',
        color: Colors.blue,
      );
    } else if (score > -20) {
      return _Evaluation(
        label: '平凡な決定',
        emoji: '😐',
        color: Color(VisualConstants.colorNeutral),
      );
    } else if (score > -50) {
      return _Evaluation(
        label: '悪い決定',
        emoji: '😔',
        color: Color(VisualConstants.colorWarning),
      );
    } else {
      return _Evaluation(
        label: '失敗した決定',
        emoji: '💥',
        color: Color(VisualConstants.colorDanger),
      );
    }
  }
}

class _StatusChangeRow extends StatelessWidget {
  final String icon;
  final String label;
  final String before;
  final String after;
  final double delta;
  final bool isPositiveBetter;

  const _StatusChangeRow({
    required this.icon,
    required this.label,
    required this.before,
    required this.after,
    required this.delta,
    required this.isPositiveBetter,
  });

  Color _getDeltaColor() {
    if (delta == 0) return Color(VisualConstants.colorNeutral);

    final isImprovement = isPositiveBetter ? delta > 0 : delta < 0;
    return isImprovement
        ? Color(VisualConstants.colorGood)
        : Color(VisualConstants.colorDanger);
  }

  String _getDeltaArrow() {
    if (delta > 0) return '↑';
    if (delta < 0) return '↓';
    return '→';
  }

  @override
  Widget build(BuildContext context) {
    final deltaColor = _getDeltaColor();
    final deltaArrow = _getDeltaArrow();
    final deltaAbsStr = delta.abs().toStringAsFixed(delta.abs() < 1 ? 2 : 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$before → $after',
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
                color: deltaColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
              ),
              child: Text(
                '$deltaArrow $deltaAbsStr',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: deltaColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Evaluation {
  final String label;
  final String emoji;
  final Color color;

  _Evaluation({
    required this.label,
    required this.emoji,
    required this.color,
  });
}
