import 'package:flutter/material.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 画面下部などに流れる速報ニュースティッカー。
class NewsTicker extends StatefulWidget {
  final List<String> headlines;

  const NewsTicker({Key? key, required this.headlines}) : super(key: key);

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scroll;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!_scroll.hasClients) return;
    _ctrl.repeat();
  }

  void _tick() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    _scroll.jumpTo(_ctrl.value * max);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.headlines.join('     ◆     ');
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          top: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            color: AppTheme.danger,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: const Text(
              '速報',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                child: Text(
                  '$text     ◆     $text',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
