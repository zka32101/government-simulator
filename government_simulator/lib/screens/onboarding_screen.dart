import 'package:flutter/material.dart';
import 'package:government_simulator/utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(String countryName, String difficulty) onStart;

  const OnboardingScreen({Key? key, required this.onStart}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController(text: '新興共和国');
  String _difficulty = 'normal';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onStart() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onStart(name, _difficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // タイトルヘッダー
                Center(
                  child: Column(
                    children: [
                      const Text('🏛️',
                          style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(VisualConstants.colorPrimary),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '国家の命運はあなたの手に',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // 国名入力
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🗺️ あなたの国の名前',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '例: 東和共和国、北島連邦...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusM),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.flag),
                          ),
                          maxLength: 20,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // 難易度選択
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ 難易度',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        _DifficultyTile(
                          value: 'easy',
                          groupValue: _difficulty,
                          emoji: '🟢',
                          label: '初心者',
                          description: 'GDP高め・穏やかなイベント。国家運営を学びたい方に',
                          onChanged: (v) => setState(() => _difficulty = v),
                        ),
                        _DifficultyTile(
                          value: 'normal',
                          groupValue: _difficulty,
                          emoji: '🟡',
                          label: '標準',
                          description: 'バランスの取れた挑戦。政治シミュレーターを楽しみたい方に',
                          onChanged: (v) => setState(() => _difficulty = v),
                        ),
                        _DifficultyTile(
                          value: 'hard',
                          groupValue: _difficulty,
                          emoji: '🔴',
                          label: '上級者',
                          description: '低GDP・高難度。歴代の偉大な指導者の試練に挑め',
                          onChanged: (v) => setState(() => _difficulty = v),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // ゲーム概要
                Card(
                  color: Color(VisualConstants.colorPrimary).withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📌 ゲームの仕組み',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                        _InfoRow(icon: '📰', text: '毎日1件の国家的課題に対処する'),
                        _InfoRow(icon: '📊', text: 'GDP・失業率・満足度・国力など6指標を管理'),
                        _InfoRow(icon: '📅', text: '7日間が1年。年末に総括と次年度選択'),
                        _InfoRow(icon: '🏆', text: '成功率を高めて国家を繁栄させよ'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 開始ボタン
                ElevatedButton(
                  onPressed: _onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(VisualConstants.colorPrimary),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusM),
                    ),
                  ),
                  child: const Text(
                    '🚀 統治を開始する',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String value;
  final String groupValue;
  final String emoji;
  final String label;
  final String description;
  final ValueChanged<String> onChanged;

  const _DifficultyTile({
    required this.value,
    required this.groupValue,
    required this.emoji,
    required this.label,
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          border: Border.all(
            color: isSelected
                ? Color(VisualConstants.colorPrimary)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Color(VisualConstants.colorPrimary).withOpacity(0.08)
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: Color(VisualConstants.colorPrimary)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
