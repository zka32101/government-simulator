import 'package:flutter/material.dart';
import 'package:government_simulator/models/user_profile.dart';
import 'package:government_simulator/utils/constants.dart';
import 'package:government_simulator/screens/economics_handbook_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ValueChanged<UserProfile> onProfileChanged;

  /// 「ゲームをリセット」確定後に呼ばれる。設定画面を閉じた後、
  /// 呼び出し元（HomeScreen）が新しいセッションを作成して表示し直す。
  final VoidCallback onReset;

  const SettingsScreen({
    Key? key,
    required this.userProfile,
    required this.onProfileChanged,
    required this.onReset,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.userProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ 設定'),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 購入情報
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🛒 購入状態',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _PurchaseStatus(
                        isPurchased: _profile.isPurchased,
                        onPurchase: _handlePurchase,
                      ),
                      if (_profile.isPurchased) ...[
                        const SizedBox(height: AppConstants.paddingM),
                        Text(
                          '解除済みDLC',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                        if (_profile.unlockedDlcScenarios.isEmpty)
                          Text(
                            'DLCはまだ購入されていません',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          )
                        else
                          Wrap(
                            spacing: AppConstants.paddingS,
                            children: _profile.unlockedDlcScenarios
                                .map((dlc) => Chip(label: Text(dlc)))
                                .toList(),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // ゲーム設定
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎮 ゲーム設定',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _SettingRow(
                        icon: '🔊',
                        label: 'サウンド',
                        enabled: _profile.soundEnabled,
                        onChanged: (value) => setState(() {
                          _profile = _profile.copyWith(soundEnabled: value);
                          widget.onProfileChanged(_profile);
                        }),
                      ),
                      _SettingRow(
                        icon: '🔔',
                        label: '通知',
                        enabled: _profile.notificationsEnabled,
                        onChanged: (value) => setState(() {
                          _profile =
                              _profile.copyWith(notificationsEnabled: value);
                          widget.onProfileChanged(_profile);
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // プレイ統計
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 プレイ統計',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _StatItem(
                        icon: '🎮',
                        label: 'ゲーム作成数',
                        value: '${_profile.totalGamesCreated}',
                      ),
                      _StatItem(
                        icon: '⏱️',
                        label: 'プレイ時間',
                        value: '${_profile.totalGameHours}時間',
                      ),
                      _StatItem(
                        icon: '⭐',
                        label: 'ユーザーレベル',
                        value: 'Lv.${_profile.userLevel}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // その他
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 その他',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('バージョン'),
                        trailing: Text(AppConstants.appVersion),
                        dense: true,
                      ),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('言語'),
                        trailing: const Text('日本語'),
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // 教育コンテンツ
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📚 学習リソース',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EconomicsHandbookScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school),
                          label: const Text('経済学ハンドブック'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(VisualConstants.colorWarning),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        '政策選択の経済学的根拠や実例を学べます。',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),

              // リセットボタン
              ElevatedButton.icon(
                onPressed: _showResetDialog,
                icon: const Icon(Icons.delete),
                label: const Text('ゲームをリセット'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(VisualConstants.colorDanger),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePurchase() {
    // TODO: RevenueCat統合
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('購入機能は準備中です')),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ゲームをリセット？'),
        content: const Text('すべてのゲームセッションが削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // 確認ダイアログを閉じる
              // 新しいセッションの作成とホーム画面までの画面遷移(popUntil)は
              // 呼び出し元（HomeScreen._onRestartGame）が担う。
              widget.onReset();
            },
            child: const Text(
              'リセット',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseStatus extends StatelessWidget {
  final bool isPurchased;
  final VoidCallback onPurchase;

  const _PurchaseStatus({
    required this.isPurchased,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: isPurchased
            ? Color(VisualConstants.colorGood).withOpacity(0.1)
            : Color(VisualConstants.colorWarning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isPurchased ? '✅' : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPurchased ? '購入済み' : '未購入',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPurchased
                                ? Color(VisualConstants.colorGood)
                                : Color(VisualConstants.colorWarning),
                          ),
                    ),
                    Text(
                      isPurchased
                          ? '政府シミュレーター v1.0'
                          : '¥600で購入できます',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!isPurchased)
                ElevatedButton(
                  onPressed: onPurchase,
                  child: const Text('購入'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String icon;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppConstants.paddingS),
              Text(label),
            ],
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppConstants.paddingS),
              Text(label),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
