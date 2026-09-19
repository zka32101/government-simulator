/// ストーリーパックイベント画面
/// シナリオ進行中に発生する物語的な分岐イベントを表示し、対応を選ばせる

library;

import 'package:flutter/material.dart';
import 'package:government_simulator/models/story_pack_event.dart';

class StoryPackEventScreen extends StatefulWidget {
  final StoryPackEvent event;

  const StoryPackEventScreen({required this.event, Key? key}) : super(key: key);

  @override
  State<StoryPackEventScreen> createState() => _StoryPackEventScreenState();
}

class _StoryPackEventScreenState extends State<StoryPackEventScreen> {
  StoryPackEventChoice? _selected;

  Color get _typeColor {
    return switch (widget.event.eventType) {
      'crisis' => Colors.red,
      'opportunity' => Colors.green,
      'plot_twist' => Colors.purple,
      'decision_point' => Colors.blue,
      _ => Colors.blueGrey,
    };
  }

  String get _typeLabel {
    return switch (widget.event.eventType) {
      'crisis' => '危機',
      'opportunity' => 'チャンス',
      'plot_twist' => '急展開',
      'decision_point' => '岐路',
      _ => '物語',
    };
  }

  IconData get _typeIcon {
    return switch (widget.event.eventType) {
      'crisis' => Icons.warning_amber_rounded,
      'opportunity' => Icons.emoji_objects,
      'plot_twist' => Icons.auto_awesome,
      'decision_point' => Icons.call_split,
      _ => Icons.menu_book,
    };
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_typeLabel),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.1),
                    border: Border.all(color: _typeColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(_typeIcon, color: _typeColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      event.storyText.trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'どうする？',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    for (final choice in event.choices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChoiceCard(
                          choice: choice,
                          isSelected: _selected == choice,
                          onSelected: () => setState(() => _selected = choice),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected != null
                        ? () => Navigator.pop(context, _selected)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _typeColor,
                    ),
                    child: const Text(
                      '決断する',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final StoryPackEventChoice choice;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ChoiceCard({
    required this.choice,
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
                Expanded(
                  child: Text(
                    choice.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  children: List.generate(
                    choice.difficulty.clamp(0, 5).toInt(),
                    (_) => const Icon(Icons.circle, size: 6, color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              choice.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
