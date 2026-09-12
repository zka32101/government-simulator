import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:government_simulator/models/election.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 選挙結果画面：4年ごとの定期選挙の結果を表示
class ElectionScreen extends ConsumerStatefulWidget {
  final Election election;
  final String countryName;

  const ElectionScreen({
    super.key,
    required this.election,
    required this.countryName,
  });

  @override
  ConsumerState<ElectionScreen> createState() => _ElectionScreenState();
}

class _ElectionScreenState extends ConsumerState<ElectionScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final election = widget.election;
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
                  '${widget.election.year}年 ${widget.countryName}大統領選挙',
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
                    color: election.won
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: election.won ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // 大きなアイコン
                      Text(
                        election.won ? '🎉' : '❌',
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),

                      // 結果テキスト
                      Text(
                        election.won ? 'あなたは再選されました' : 'あなたは落選しました',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: election.won ? Colors.green : Colors.red,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // 得票率
                      Text(
                        '得票率',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${election.percentageVotes.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // 投票数バー
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (election.percentageVotes / 100).clamp(0, 1),
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation(
                            election.won ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 詳細情報
                Card(
                  elevation: 0,
                  color: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          '投票数',
                          '${election.votesReceived}票 / ${election.votesCast}票',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          '投票率',
                          '${((election.votesReceived / election.votesCast) * 100).toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // メッセージ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    election.won
                        ? 'あなたは国民の信頼を得て、次期大統領として再選された。'
                            '国政をさらに4年間主導する権利を得た。'
                        : 'あなたの政策は国民に支持されず、選挙に敗北した。'
                            'あなたの政権は終わりを迎えた。',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // 続行ボタン
                if (election.won)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('ゲーム終了'),
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
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
