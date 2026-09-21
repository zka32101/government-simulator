import 'package:flutter/material.dart';
import 'package:government_simulator/models/election_result.dart';
import 'package:government_simulator/models/rival_candidate.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 選挙結果画面：4年ごとの定期選挙の結果を表示
class ElectionScreen extends StatelessWidget {
  final ElectionResult result;
  final String countryName;
  final List<RivalCandidate> rivals;

  const ElectionScreen({
    super.key,
    required this.result,
    required this.countryName,
    this.rivals = const [],
  });

  String _rivalName(String rivalId) {
    final rival = rivals.where((r) => r.id == rivalId).firstOrNull;
    return rival != null ? '${rival.emoji} ${rival.name}' : rivalId;
  }

  @override
  Widget build(BuildContext context) {
    final won = result.playerWon;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('大統領選挙'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.gold,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.gold.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ヘッダー：選挙年と国名
                Text(
                  '${result.year}年 $countryName大統領選挙',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 選挙結果（大きく表示）
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: won
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: won ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // 大きなアイコン
                      Text(
                        won ? '🎉' : '❌',
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),

                      // 結果テキスト
                      Text(
                        won ? 'あなたは再選されました' : 'あなたは落選しました',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: won ? Colors.green : Colors.red,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.victoryType.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),

                      // 得票率
                      Text(
                        '得票率',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${result.playerVoteShare.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // 得票率バー
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (result.playerVoteShare / 100).clamp(0, 1),
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            won ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 対立候補の得票率
                if (result.rivalVotes.isNotEmpty)
                  Card(
                    elevation: 0,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '対立候補の得票率',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          for (final entry in result.rivalVotes.entries) ...[
                            _buildDetailRow(
                              context,
                              _rivalName(entry.key),
                              '${entry.value.toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // ナレーティブ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.narrativeText,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // 続行ボタン
                if (won)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('統治を続行する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('結果を確認'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
              ),
        ),
      ],
    );
  }
}
