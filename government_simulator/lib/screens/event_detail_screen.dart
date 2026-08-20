import 'package:flutter/material.dart';
import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/services/game_logic_service.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/widgets/animated_counter.dart';
import 'package:government_simulator/widgets/celebration_effect.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _listController;
  late GameLogicService _gameLogic;

  // 遷移アニメーション中に連打すると pop() が二重発火し、2回目の pop が
  // このルートの下にある画面（HomeScreen 等）に対して行われてしまうため
  // ガードする。
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogicService();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
    // ステータス変化の各行を時間差で表示するためのコントローラー。
    _listController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // 4つのステータス行を index/4 ずつずらしてフェード＋スライドインさせる。
  Animation<double> _staggered(int index, int total) {
    final start = index / total * 0.5;
    final end = start + 0.5;
    return CurvedAnimation(
      parent: _listController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _staggeredRow({required int index, required Widget child}) {
    final anim = _staggered(index, 4);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
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
              // 結果評価（卓越した決定なら祝福エフェクト、失敗なら衝撃演出）
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                          parent: _animController, curve: Curves.elasticOut),
                    ),
                    child: ShakeOnce(
                      trigger: widget.impactScore <= -50,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.paddingS),
                              Text(
                                'インパクトスコア: ${widget.impactScore.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.impactScore > 50) const CelebrationBurst(),
                ],
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

              _staggeredRow(
                index: 0,
                child: _StatusChangeRow(
                  icon: '💰',
                  label: 'GDP',
                  beforeValue: widget.beforeStatus.gdp,
                  afterValue: widget.afterStatus.gdp,
                  prefix: '\$',
                  suffix: 'B',
                  delta: widget.afterStatus.gdp - widget.beforeStatus.gdp,
                  isPositiveBetter: true,
                ),
              ),

              _staggeredRow(
                index: 1,
                child: _StatusChangeRow(
                  icon: '👥',
                  label: '失業率',
                  beforeValue: widget.beforeStatus.unemployment,
                  afterValue: widget.afterStatus.unemployment,
                  suffix: '%',
                  decimals: 1,
                  delta: widget.afterStatus.unemployment -
                      widget.beforeStatus.unemployment,
                  isPositiveBetter: false,
                ),
              ),

              _staggeredRow(
                index: 2,
                child: _StatusChangeRow(
                  icon: '😊',
                  label: '国民満足度',
                  beforeValue: widget.beforeStatus.satisfaction,
                  afterValue: widget.afterStatus.satisfaction,
                  delta: widget.afterStatus.satisfaction -
                      widget.beforeStatus.satisfaction,
                  isPositiveBetter: true,
                ),
              ),

              _staggeredRow(
                index: 3,
                child: _StatusChangeRow(
                  icon: '📈',
                  label: '国力',
                  beforeValue: widget.beforeStatus.nationalPower,
                  afterValue: widget.afterStatus.nationalPower,
                  delta: widget.afterStatus.nationalPower -
                      widget.beforeStatus.nationalPower,
                  isPositiveBetter: true,
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 次へボタン
              ElevatedButton.icon(
                onPressed: () {
                  if (_popped) return;
                  _popped = true;
                  Navigator.of(context).pop(true);
                },
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
  final double beforeValue;
  final double afterValue;
  final String prefix;
  final String suffix;
  final int decimals;
  final double delta;
  final bool isPositiveBetter;

  const _StatusChangeRow({
    required this.icon,
    required this.label,
    required this.beforeValue,
    required this.afterValue,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
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
    final beforeStr = '$prefix${beforeValue.toStringAsFixed(decimals)}$suffix';

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
                  Row(
                    children: [
                      Text(
                        '$beforeStr → ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TransitionCounter(
                        from: beforeValue,
                        to: afterValue,
                        decimals: decimals,
                        prefix: prefix,
                        suffix: suffix,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
