/// 危機アラート画面
/// 発生した危機をプレイヤーに通知し、対応選択肢を提示

import 'package:flutter/material.dart';
import 'package:government_simulator/models/crisis.dart';
import 'package:government_simulator/services/crisis_event_service.dart';
import 'package:government_simulator/utils/animation_configs.dart';

/// 危機アラート画面
class CrisisAlertScreen extends StatefulWidget {
  final Crisis crisis;
  final CrisisEventDisplay crisisDisplay;
  final ValueChanged<CrisisOption> onResponseSelected;

  const CrisisAlertScreen({
    required this.crisis,
    required this.crisisDisplay,
    required this.onResponseSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<CrisisAlertScreen> createState() => _CrisisAlertScreenState();
}

class _CrisisAlertScreenState extends State<CrisisAlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _staggeredAnimations;
  CrisisOption? selectedOption;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // スタガーアニメーション（タイトル + 説明 + 3オプション + ボタン）
    _staggeredAnimations = StaggeredAnimations.buildStaggeredFadeAnimations(
      _controller,
      itemCount: 3 + widget.crisisDisplay.options.length,
      staggerDelay: const Duration(milliseconds: 150),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCrisisColor() {
    return switch (widget.crisis.type) {
      CrisisType.demonstration => Colors.orange,
      CrisisType.riot => Colors.red[700]!,
      CrisisType.laborStrike => Colors.amber,
      CrisisType.economicCrisis => Colors.deepOrange,
      CrisisType.militaryCoup => Colors.red[900]!,
    };
  }

  IconData _getCrisisIcon() {
    return switch (widget.crisis.type) {
      CrisisType.demonstration => Icons.groups,
      CrisisType.riot => Icons.warning,
      CrisisType.laborStrike => Icons.handshake,
      CrisisType.economicCrisis => Icons.trending_down,
      CrisisType.militaryCoup => Icons.military_tech,
    };
  }

  String _getUrgencyLabel() {
    final urgency = widget.crisisDisplay.timeUrgencyFactor;
    if (urgency >= 0.8) return '【緊急】';
    if (urgency >= 0.5) return '【警告】';
    return '【注意】';
  }

  @override
  Widget build(BuildContext context) {
    final crisisColor = _getCrisisColor();
    final urgencyLabel = _getUrgencyLabel();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$urgencyLabel${widget.crisisDisplay.title}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: crisisColor.withOpacity(0.8),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 危機タイプインジケーター
            FadeTransition(
              opacity: _staggeredAnimations[0],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: crisisColor.withOpacity(0.1),
                    border: Border.all(
                      color: crisisColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _getCrisisIcon(),
                        color: crisisColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '危機レベル',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: crisisColor,
                                  ),
                            ),
                            Text(
                              widget.crisis.type.toString().split('.').last,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: crisisColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // 緊急度インジケーター
                      Column(
                        children: [
                          Text(
                            '緊急度',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: widget
                                .crisisDisplay.timeUrgencyFactor
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(crisisColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 危機説明
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: _staggeredAnimations[1],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.crisisDisplay.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 危機の影響表示
            FadeTransition(
              opacity: _staggeredAnimations[2],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _ImpactSummaryWidget(
                  crisis: widget.crisis,
                  crisisColor: crisisColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 対応選択肢
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '対応選択肢',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    widget.crisisDisplay.options.length,
                    (index) {
                      final option = widget.crisisDisplay.options[index];
                      final isSelected = selectedOption == option;
                      final animationIndex = 3 + index;

                      return FadeTransition(
                        opacity: animationIndex < _staggeredAnimations.length
                            ? _staggeredAnimations[animationIndex]
                            : AlwaysStoppedAnimation(1.0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CrisisResponseCard(
                            option: option,
                            crisisColor: crisisColor,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() => selectedOption = option);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 決定ボタン
            FadeTransition(
              opacity: _staggeredAnimations.isNotEmpty
                  ? _staggeredAnimations.last
                  : AlwaysStoppedAnimation(1.0),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedOption != null
                        ? () {
                            widget.onResponseSelected(selectedOption!);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _getCrisisColor(),
                    ),
                    child: const Text(
                      '対応を決定',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 危機の影響サマリーウィジェット
class _ImpactSummaryWidget extends StatelessWidget {
  final Crisis crisis;
  final Color crisisColor;

  const _ImpactSummaryWidget({
    required this.crisis,
    required this.crisisColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: crisisColor.withOpacity(0.05),
        border: Border.all(color: crisisColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '予測される影響',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_down, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '承認度: ${crisis.approvalImpact.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (crisis.economicImpact != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '経済ダメージ: \$${(crisis.economicImpact! / 1000).toStringAsFixed(0)}K',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: crisisColor.withOpacity(0.2),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'エスカレーションリスク',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: crisis.escalationRisk.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(crisisColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(crisis.escalationRisk * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: crisisColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 危機対応選択肢カード
class _CrisisResponseCard extends StatelessWidget {
  final CrisisOption option;
  final Color crisisColor;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CrisisResponseCard({
    required this.option,
    required this.crisisColor,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? crisisColor : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? crisisColor.withOpacity(0.05)
              : Colors.grey[50],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 選択インジケーター
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? crisisColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: crisisColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? crisisColor : null,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                option.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: _ResponseImpactRow(
                option: option,
                crisisColor: crisisColor,
              ),
            ),
            if (option.sideEffect != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⚠️ ${option.sideEffect}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.orange[900],
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 対応の影響表示
class _ResponseImpactRow extends StatelessWidget {
  final CrisisOption option;
  final Color crisisColor;

  const _ResponseImpactRow({
    required this.option,
    required this.crisisColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (option.costEstimate > 0)
          _ImpactBadge(
            icon: Icons.attach_money,
            label: '-\$${(option.costEstimate / 1000).toStringAsFixed(0)}K',
            color: Colors.red,
          ),
        if (option.approvalRecovery > 0)
          _ImpactBadge(
            icon: Icons.trending_up,
            label: '+${option.approvalRecovery.toStringAsFixed(1)}%',
            color: Colors.green,
          )
        else if (option.approvalRecovery < 0)
          _ImpactBadge(
            icon: Icons.trending_down,
            label: '${option.approvalRecovery.toStringAsFixed(1)}%',
            color: Colors.red,
          ),
      ],
    );
  }
}

/// 影響バッジ
class _ImpactBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ImpactBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
