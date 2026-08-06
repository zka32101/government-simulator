import 'package:dio/dio.dart';
import 'package:government_simulator/models/decision.dart';
import 'package:government_simulator/models/ending.dart';
import 'package:government_simulator/models/game_session.dart';
import 'package:government_simulator/utils/constants.dart';

/// あなたの統治の決断履歴から、AI が「歴史教科書の1ページ」を生成する。
class HistoryBookService {
  final Dio _dio = Dio();

  bool get isConfigured => AppConstants.claudeApiKey.isNotEmpty;

  Future<String?> generate({
    required GameSession session,
    required List<Decision> decisions,
    required Ending ending,
  }) async {
    if (!isConfigured) return null;

    final recent = DecisionHistory(decisions).getRecentDecisions(count: 12);
    final decisionSummary = recent.reversed
        .map((d) => '・${d.narrative.split('\n').first}（${d.evaluationLabel}）')
        .join('\n');

    final prompt = '''
あなたは歴史教科書の編纂者です。以下の統治記録をもとに、
「歴史教科書の1ページ」のような文体で、簡潔かつドラマチックに
この指導者の治世を評する文章を日本語で書いてください。

【国名】${session.countryName}
【統治期間】${session.status.year}年
【最終称号】${ending.title}
【最終評価】${ending.description}
【総意思決定数】${session.totalDecisions}
【成功率】${session.successRate.toStringAsFixed(1)}%

【主な決断の記録】
$decisionSummary

条件：
- 300文字程度
- 教科書的・客観的な三人称視点
- 見出し（1行）+本文の形式
- 大げさすぎない、事実に基づいた評価トーンで
''';

    try {
      final response = await _dio.post(
        '${AppConstants.claudeApiBase}/messages',
        options: Options(headers: {
          'x-api-key': AppConstants.claudeApiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': AppConstants.claudeTextModel,
          'max_tokens': 512,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        },
      );
      final text = response.data['content'][0]['text'] as String;
      return text.trim();
    } catch (e) {
      return null;
    }
  }
}
