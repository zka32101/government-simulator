import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:government_simulator/utils/app_theme.dart';

/// AI歴史書生成ボタン。結果はダイアログでシェア用テキストとして表示する。
class HistoryBookButton extends StatelessWidget {
  final Future<String?> Function() onGenerate;

  const HistoryBookButton({Key? key, required this.onGenerate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showBookDialog(context),
        icon: const Icon(Icons.menu_book),
        label: const Text('📜 歴史書を生成する'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.gold,
          side: BorderSide(color: AppTheme.gold.withOpacity(0.6)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _HistoryBookDialog(onGenerate: onGenerate),
    );
  }
}

class _HistoryBookDialog extends StatefulWidget {
  final Future<String?> Function() onGenerate;

  const _HistoryBookDialog({required this.onGenerate});

  @override
  State<_HistoryBookDialog> createState() => _HistoryBookDialogState();
}

class _HistoryBookDialogState extends State<_HistoryBookDialog> {
  String? _text;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.onGenerate();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _text = result;
      _failed = result == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text('📜 歴史書', style: TextStyle(color: AppTheme.gold)),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('歴史家が筆を執っています…',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              )
            : _failed
                ? const Text(
                    'AI 歴史書の生成に失敗しました。\n'
                    'CLAUDE_API_KEY が設定されていない可能性があります。',
                    style: TextStyle(color: AppTheme.textSecondary),
                  )
                : SelectableText(
                    _text!,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, height: 1.6),
                  ),
      ),
      actions: [
        if (!_loading && !_failed)
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _text!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('コピーしました')),
              );
            },
            child: const Text('コピー'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}
