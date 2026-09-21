import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/executive_action.dart';
import 'package:government_simulator/models/faction.dart';
import 'package:government_simulator/models/minister.dart';
import 'package:government_simulator/providers/game_provider.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 統治アクション画面：ランダムイベントの発生を待たず、プレイヤーが
/// 自らの判断で能動的に実行できる統治アクションを選択・実行する。
class ExecutiveActionScreen extends ConsumerStatefulWidget {
  const ExecutiveActionScreen({super.key});

  @override
  ConsumerState<ExecutiveActionScreen> createState() =>
      _ExecutiveActionScreenState();
}

class _ExecutiveActionScreenState extends ConsumerState<ExecutiveActionScreen> {
  bool _busy = false;

  Future<void> _execute(
    ExecutiveActionType type, {
    Faction? faction,
    MinisterRole? minister,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final session = ref.read(gameSessionProvider).session;
      if (session == null) return;
      final message =
          await ref.read(gameSessionProvider.notifier).performExecutiveAction(
                session,
                type,
                targetFaction: faction,
                targetMinister: minister,
              );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? '${type.label}は今年すでに実行済みです。'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFactionAndExecute(ExecutiveActionType type) async {
    final faction = await showDialog<Faction>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('交渉相手の派閥を選択'),
        children: Faction.values
            .map(
              (f) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, f),
                child: Text('${f.emoji} ${f.label}'),
              ),
            )
            .toList(),
      ),
    );
    if (faction != null && mounted) {
      await _execute(type, faction: faction);
    }
  }

  Future<void> _pickMinisterAndExecute(ExecutiveActionType type) async {
    final minister = await showDialog<MinisterRole>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('激励する大臣を選択'),
        children: MinisterRole.values
            .map(
              (r) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, r),
                child: Text('${r.emoji} ${r.label}'),
              ),
            )
            .toList(),
      ),
    );
    if (minister != null && mounted) {
      await _execute(type, minister: minister);
    }
  }

  void _onActionPressed(ExecutiveActionType type) {
    switch (type) {
      case ExecutiveActionType.addressNation:
        _execute(type);
      case ExecutiveActionType.negotiateFaction:
        _pickFactionAndExecute(type);
      case ExecutiveActionType.encourageCabinet:
        _pickMinisterAndExecute(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider).session;
    final year = session?.status.year ?? 1;
    final usage = session?.executiveActionLastUsedYear ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('統治アクション'),
        backgroundColor: AppTheme.gold,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'イベントの発生を待たず、自らの判断で実行できる統治アクションです。'
            '種類ごとに年1回まで実行できます。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final type in ExecutiveActionType.values) ...[
            _buildActionCard(context, type, usage[type.name] == year),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ExecutiveActionType type,
    bool usedThisYear,
  ) {
    return Card(
      elevation: 0,
      color: usedThisYear ? Colors.grey[200] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed:
                  (_busy || usedThisYear) ? null : () => _onActionPressed(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.white,
              ),
              child: Text(usedThisYear ? '実行済み' : '実行する'),
            ),
          ],
        ),
      ),
    );
  }
}
