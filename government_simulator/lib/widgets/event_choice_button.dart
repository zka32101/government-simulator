import 'package:flutter/material.dart';
import 'package:government_simulator/models/event.dart';
import 'package:government_simulator/utils/constants.dart';

class EventChoiceButton extends StatefulWidget {
  final Choice choice;
  final VoidCallback onPressed;

  const EventChoiceButton({
    Key? key,
    required this.choice,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<EventChoiceButton> createState() => _EventChoiceButtonState();
}

class _EventChoiceButtonState extends State<EventChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    // 押下アニメーション(200ms)の最中に連打されると、以前は毎回
    // forward().then(...) が積まれ widget.onPressed が複数回呼ばれて
    // いたため、押下中は以降のタップを無視する。
    if (_pressed) return;
    _pressed = true;
    _controller.forward().then((_) {
      widget.onPressed();
    });
  }

  Color _getImpactColor(Impact impact) {
    final direction = impact.direction;
    if (direction > 0) {
      return Color(VisualConstants.colorGood);
    } else if (direction < 0) {
      return Color(VisualConstants.colorDanger);
    }
    return Color(VisualConstants.colorNeutral);
  }

  @override
  Widget build(BuildContext context) {
    final impactColor = _getImpactColor(widget.choice.impact);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: impactColor.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              color: impactColor.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: impactColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.choice.text,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    _ImpactIndicator(impact: widget.choice.impact),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  widget.choice.shortDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactIndicator extends StatelessWidget {
  final Impact impact;

  const _ImpactIndicator({required this.impact});

  @override
  Widget build(BuildContext context) {
    final types = impact.types;
    final magnitude = impact.magnitude;
    final direction = impact.direction;

    Color color;
    String emoji;

    if (direction > 0) {
      color = Color(VisualConstants.colorGood);
      emoji = '📈';
    } else if (direction < 0) {
      color = Color(VisualConstants.colorDanger);
      emoji = '📉';
    } else {
      color = Color(VisualConstants.colorNeutral);
      emoji = '➡️';
    }

    return Tooltip(
      message: '影響: ${types.map((t) => t.label).join(', ')}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              magnitude.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
