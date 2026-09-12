/// 外交イベント画面
/// 外交的危機や提案の表示と対応選択肢

import 'package:flutter/material.dart';
import 'package:government_simulator/models/international_relations.dart';
import 'package:government_simulator/utils/animation_configs.dart';

/// 外交イベント画面
class DiplomaticEventScreen extends StatefulWidget {
  final DiplomaticEvent event;
  final VoidCallback? onEventResolved;

  const DiplomaticEventScreen({
    required this.event,
    this.onEventResolved,
    Key? key,
  }) : super(key: key);

  @override
  State<DiplomaticEventScreen> createState() => _DiplomaticEventScreenState();
}

class _DiplomaticEventScreenState extends State<DiplomaticEventScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _staggeredAnimations;

  DiplomaticOption? selectedOption;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 複数要素のスタガーアニメーション
    _staggeredAnimations = StaggeredAnimations.buildStaggeredFadeAnimations(
      _controller,
      itemCount: 4 + widget.event.availableOptions.length,
      staggerDelay: const Duration(milliseconds: 120),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventTypeLabel = _getEventTypeLabel(widget.event.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(eventTypeLabel),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // イベントタイプインジケーター
            FadeTransition(
              opacity: _staggeredAnimations[0],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(widget.event.type).withOpacity(0.1),
                    border: Border.all(
                      color: _getEventTypeColor(widget.event.type),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _getEventTypeIcon(widget.event.type),
                        color: _getEventTypeColor(widget.event.type),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          eventTypeLabel,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _getEventTypeColor(widget.event.type),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // イベントタイトル
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // イベント説明
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
                ),
              ),
              child: FadeTransition(
                opacity: _staggeredAnimations[2],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
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
                    widget.event.availableOptions.length,
                    (index) {
                      final option = widget.event.availableOptions[index];
                      final isSelected = selectedOption == option;
                      final animationIndex = 3 + index;

                      return FadeTransition(
                        opacity: animationIndex < _staggeredAnimations.length
                            ? _staggeredAnimations[animationIndex]
                            : AlwaysStoppedAnimation(1.0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DiplomaticOptionCard(
                            option: option,
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
                            // イベントを解決（実装は親で行う）
                            Navigator.pop(context, selectedOption);
                            widget.onEventResolved?.call();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '対応を決定',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventTypeLabel(DiplomaticEventType type) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation => '貿易交渉',
      DiplomaticEventType.borderIncident => '国境紛争',
      DiplomaticEventType.allianceProposal => '同盟提案',
      DiplomaticEventType.sanctions => '国際制裁',
      DiplomaticEventType.culturalExchange => '文化交流',
      DiplomaticEventType.humanitarianAid => '人道支援',
      DiplomaticEventType.warDeclaration => '宣戦布告',
      DiplomaticEventType.peaceTreaty => '平和条約',
    };
  }

  Color _getEventTypeColor(DiplomaticEventType type) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation => Colors.blue,
      DiplomaticEventType.borderIncident => Colors.orange,
      DiplomaticEventType.allianceProposal => Colors.green,
      DiplomaticEventType.sanctions => Colors.red,
      DiplomaticEventType.culturalExchange => Colors.purple,
      DiplomaticEventType.humanitarianAid => Colors.teal,
      DiplomaticEventType.warDeclaration => Colors.red[900]!,
      DiplomaticEventType.peaceTreaty => Colors.green[700]!,
    };
  }

  IconData _getEventTypeIcon(DiplomaticEventType type) {
    return switch (type) {
      DiplomaticEventType.tradeNegotiation => Icons.handshake,
      DiplomaticEventType.borderIncident => Icons.warning,
      DiplomaticEventType.allianceProposal => Icons.people,
      DiplomaticEventType.sanctions => Icons.gavel,
      DiplomaticEventType.culturalExchange => Icons.theater_comedy,
      DiplomaticEventType.humanitarianAid => Icons.favorite,
      DiplomaticEventType.warDeclaration => Icons.military_tech,
      DiplomaticEventType.peaceTreaty => Icons.balance,
    };
  }
}

/// 外交オプションカード
class _DiplomaticOptionCard extends StatelessWidget {
  final DiplomaticOption option;
  final bool isSelected;
  final VoidCallback onSelected;

  const _DiplomaticOptionCard({
    required this.option,
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
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                option.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: _OptionImpactRow(option: option),
            ),
            if (option.sideEffect != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

/// オプションの影響表示
class _OptionImpactRow extends StatelessWidget {
  final DiplomaticOption option;

  const _OptionImpactRow({required this.option});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (option.economicCost > 0)
          _ImpactChip(
            icon: Icons.attach_money,
            label: '-\$${(option.economicCost / 1000).toStringAsFixed(0)}K',
            color: Colors.red,
          ),
        if (option.relationshipChange > 0)
          _ImpactChip(
            icon: Icons.trending_up,
            label: '+${option.relationshipChange.toStringAsFixed(0)}関係',
            color: Colors.green,
          )
        else if (option.relationshipChange < 0)
          _ImpactChip(
            icon: Icons.trending_down,
            label: '${option.relationshipChange.toStringAsFixed(0)}関係',
            color: Colors.red,
          ),
        if (option.approvalImpact > 0)
          _ImpactChip(
            icon: Icons.thumb_up,
            label: '+${option.approvalImpact.toStringAsFixed(1)}%評価',
            color: Colors.blue,
          )
        else if (option.approvalImpact < 0)
          _ImpactChip(
            icon: Icons.thumb_down,
            label: '${option.approvalImpact.toStringAsFixed(1)}%評価',
            color: Colors.red,
          ),
      ],
    );
  }
}

/// 影響チップ
class _ImpactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ImpactChip({
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
        borderRadius: BorderRadius.circular(20),
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
