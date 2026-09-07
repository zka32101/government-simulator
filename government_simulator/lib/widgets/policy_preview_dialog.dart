import 'package:flutter/material.dart';
import 'package:government_simulator/models/policy_preview.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// 政策選択の予想される影響を表示するダイアログ
/// ユーザーが選択肢を実行する前に、詳細な影響を確認できる
class PolicyPreviewDialog extends StatefulWidget {
  final PolicyPreview preview;
  final VoidCallback onCommit;
  final VoidCallback? onCancel;

  const PolicyPreviewDialog({
    Key? key,
    required this.preview,
    required this.onCommit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PolicyPreviewDialog> createState() => _PolicyPreviewDialogState();
}

class _PolicyPreviewDialogState extends State<PolicyPreviewDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRisks = widget.preview.riskFactors.isNotEmpty;

    return Dialog(
      backgroundColor: AppTheme.bg,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 政策の影響予測',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.preview.choiceText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (hasRisks)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.preview.hasCriticalRisks
                                ? AppTheme.danger.withValues(alpha: 0.2)
                                : AppTheme.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.preview.hasCriticalRisks
                                ? '🚨 危険'
                                : '⚠️ 注意',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.preview.hasCriticalRisks
                                  ? AppTheme.danger
                                  : AppTheme.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // タブセレクター
            Container(
              color: AppTheme.surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.gold,
                labelColor: AppTheme.gold,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(text: '📊 指標'),
                  Tab(text: '🎩 大臣'),
                  Tab(text: '🏛️ 派閥'),
                  Tab(text: '⚠️ リスク'),
                ],
              ),
            ),
            // タブコンテンツ
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildIndicatorsTab(),
                  _buildMinistersTab(),
                  _buildFactionsTab(),
                  _buildRisksTab(),
                ],
              ),
            ),
            // アクションボタン
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCommit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.preview.hasCriticalRisks
                            ? AppTheme.danger.withValues(alpha: 0.6)
                            : AppTheme.gold,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'この選択を実行',
                        style: TextStyle(
                          color: widget.preview.hasCriticalRisks
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsTab() {
    if (widget.preview.indicatorDeltas.isEmpty) {
      return Center(
        child: Text(
          '指標の変化なし',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.preview.indicatorDeltas.length,
      itemBuilder: (context, index) {
        final delta = widget.preview.indicatorDeltas.values.toList()[index];
        return _IndicatorDeltaCard(delta: delta);
      },
    );
  }

  Widget _buildMinistersTab() {
    if (widget.preview.ministerLoyaltyDeltas.isEmpty) {
      return Center(
        child: Text(
          '大臣への影響なし',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.preview.ministerLoyaltyDeltas.length,
      itemBuilder: (context, index) {
        final delta = widget.preview.ministerLoyaltyDeltas.values.toList()[index];
        return _MinisterLoyaltyCard(delta: delta);
      },
    );
  }

  Widget _buildFactionsTab() {
    if (widget.preview.factionDeltas.isEmpty) {
      return Center(
        child: Text(
          '派閥への影響なし',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.preview.factionDeltas.length,
      itemBuilder: (context, index) {
        final delta = widget.preview.factionDeltas.values.toList()[index];
        return _FactionDeltaCard(delta: delta);
      },
    );
  }

  Widget _buildRisksTab() {
    if (widget.preview.riskFactors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✅ リスク警告なし',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.good,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'この選択は安全です',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.preview.riskFactors.length,
      itemBuilder: (context, index) {
        final risk = widget.preview.riskFactors[index];
        return _RiskFactorCard(risk: risk);
      },
    );
  }
}

/// 指標の変化を表示するカード
class _IndicatorDeltaCard extends StatelessWidget {
  final IndicatorDelta delta;

  const _IndicatorDeltaCard({required this.delta});

  Color _getDeltaColor() {
    if (delta.isPositive) return AppTheme.good;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  delta.arrow,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delta.indicatorLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        delta.indicatorKey,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${delta.delta > 0 ? '+' : ''}${delta.delta.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getDeltaColor(),
                      ),
                    ),
                    Text(
                      '(${delta.deltaPercent > 0 ? '+' : ''}${delta.deltaPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getDeltaColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 値の推移
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '現在',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        delta.currentValue.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: _getDeltaColor(),
                  size: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '予想',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        delta.projectedValue.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getDeltaColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 大臣忠誠度の変化を表示するカード
class _MinisterLoyaltyCard extends StatelessWidget {
  final MinisterLoyaltyDelta delta;

  const _MinisterLoyaltyCard({required this.delta});

  Color _getLoyaltyColor(double loyalty) {
    if (loyalty <= 0) return AppTheme.danger;
    if (loyalty < 30) return AppTheme.warning;
    if (loyalty < 60) return AppTheme.gold;
    return AppTheme.good;
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _getLoyaltyColor(delta.currentLoyalty);
    final projectedColor = _getLoyaltyColor(delta.projectedLoyalty);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  delta.roleEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delta.roleJapanese,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        delta.ministerRole,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (delta.isBetrayed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '裏切り',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 忠誠度バー
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '現在',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${delta.currentLoyalty.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (delta.currentLoyalty / 100).clamp(0, 1),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(currentColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '予想',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${delta.projectedLoyalty.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: projectedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (delta.projectedLoyalty / 100).clamp(0, 1),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(projectedColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (delta.delta != 0) ...[
              const SizedBox(height: 8),
              Text(
                '変化: ${delta.delta > 0 ? '+' : ''}${delta.delta.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: delta.delta > 0 ? AppTheme.good : AppTheme.danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 派閥支持率の変化を表示するカード
class _FactionDeltaCard extends StatelessWidget {
  final FactionDelta delta;

  const _FactionDeltaCard({required this.delta});

  Color _getSupportColor(double support) {
    if (support <= 0) return AppTheme.danger;
    if (support < 30) return AppTheme.warning;
    if (support < 60) return AppTheme.gold;
    return AppTheme.good;
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _getSupportColor(delta.currentSupport);
    final projectedColor = _getSupportColor(delta.projectedSupport);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delta.factionJapanese,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        delta.factionName,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (delta.isCritical)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '危機',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 支持率バー
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '現在',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${delta.currentSupport.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (delta.currentSupport / 100).clamp(0, 1),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(currentColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '予想',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${delta.projectedSupport.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: projectedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (delta.projectedSupport / 100).clamp(0, 1),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(projectedColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (delta.delta != 0) ...[
              const SizedBox(height: 8),
              Text(
                '変化: ${delta.delta > 0 ? '+' : ''}${delta.delta.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: delta.delta > 0 ? AppTheme.good : AppTheme.danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// リスク要因を表示するカード
class _RiskFactorCard extends StatelessWidget {
  final RiskFactor risk;

  const _RiskFactorCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    final isWarning = risk.severity == RiskSeverity.warning;
    final backgroundColor =
        isWarning ? AppTheme.warning.withValues(alpha: 0.1) : AppTheme.danger.withValues(alpha: 0.1);
    final borderColor =
        isWarning ? AppTheme.warning.withValues(alpha: 0.3) : AppTheme.danger.withValues(alpha: 0.3);
    final textColor = isWarning ? AppTheme.warning : AppTheme.danger;
    final icon = isWarning ? '⚠️' : '🚨';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        risk.affectedAspect,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isWarning ? '注意が必要です' : '危険な状況です',
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // メッセージ
            Text(
              risk.message,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // アドバイス
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Text(
                    '💡',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      risk.advice,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
