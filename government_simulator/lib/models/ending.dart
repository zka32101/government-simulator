import 'package:government_simulator/models/country_status.dart';
import 'package:government_simulator/models/faction.dart';

/// 統治スタイル：軍部偏重・市民軽視なら独裁、その逆なら民主。
enum RegimeType { authoritarian, democratic }

/// 最終的な国家の繁栄度。
enum EndingOutcome { prosperity, stagnation, collapse }

/// 統治の正当性：国民に支持されたか、力で抑えつけたか。
enum EndingLegitimacy { supported, oppressive }

/// 12種の分岐エンディング（2 regime × 3 outcome × 2 legitimacy）。
class Ending {
  final RegimeType regime;
  final EndingOutcome outcome;
  final EndingLegitimacy legitimacy;
  final String title;
  final String description;

  const Ending({
    required this.regime,
    required this.outcome,
    required this.legitimacy,
    required this.title,
    required this.description,
  });

  /// AI生成挿絵画像のアセットパス
  String get imagePath =>
      'assets/images/endings/ending_${regime.name}_${outcome.name}_${legitimacy.name}.png';

  static Ending determine(CountryStatus status, FactionSupport factions) {
    final regime = (factions.of(Faction.military) >= 55 &&
            factions.of(Faction.citizen) < 45)
        ? RegimeType.authoritarian
        : RegimeType.democratic;

    final EndingOutcome outcome;
    if (status.healthScore >= 70) {
      outcome = EndingOutcome.prosperity;
    } else if (status.healthScore >= 40) {
      outcome = EndingOutcome.stagnation;
    } else {
      outcome = EndingOutcome.collapse;
    }

    final legitimacy = factions.of(Faction.citizen) >= 50
        ? EndingLegitimacy.supported
        : EndingLegitimacy.oppressive;

    return _table[(regime, outcome, legitimacy)]!;
  }

  static final Map<(RegimeType, EndingOutcome, EndingLegitimacy), Ending>
      _table = {
    (RegimeType.authoritarian, EndingOutcome.prosperity,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.prosperity,
      legitimacy: EndingLegitimacy.supported,
      title: '開発独裁の父',
      description: '強権を敷きながらも経済的繁栄をもたらし、国民の多くはあなたの統治を黙認し、'
          '一部は熱狂的に支持した。歴史は功罪相半ばする人物として記憶する。',
    ),
    (RegimeType.authoritarian, EndingOutcome.prosperity,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.prosperity,
      legitimacy: EndingLegitimacy.oppressive,
      title: '黄金の独裁者',
      description: '経済指標は輝かしい数字を残したが、それは恐怖による沈黙の上に築かれたものだった。'
          '国民は豊かさと引き換えに自由を差し出した。',
    ),
    (RegimeType.authoritarian, EndingOutcome.stagnation,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.stagnation,
      legitimacy: EndingLegitimacy.supported,
      title: '停滞の統率者',
      description: '劇的な成長こそなかったが、強いリーダーシップの下で国はどうにか秩序を保った。'
          '国民は変化より安定を選んだ。',
    ),
    (RegimeType.authoritarian, EndingOutcome.stagnation,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.stagnation,
      legitimacy: EndingLegitimacy.oppressive,
      title: '灰色の権威主義者',
      description: '経済は停滞し、自由も失われた。国民は表向き従いながら、静かに不満を募らせている。',
    ),
    (RegimeType.authoritarian, EndingOutcome.collapse,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.collapse,
      legitimacy: EndingLegitimacy.supported,
      title: '悲劇の強権者',
      description: '国民の一部はなお忠誠を誓っていたが、国家そのものが崩壊した。'
          '善意と誤った手法が悲劇を生んだ典型として語り継がれる。',
    ),
    (RegimeType.authoritarian, EndingOutcome.collapse,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.authoritarian,
      outcome: EndingOutcome.collapse,
      legitimacy: EndingLegitimacy.oppressive,
      title: '暴君',
      description: '恐怖による支配は国家の崩壊とともに終わりを告げた。'
          '歴史教科書にはあなたの名が「暴君」として刻まれるだろう。',
    ),
    (RegimeType.democratic, EndingOutcome.prosperity,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.prosperity,
      legitimacy: EndingLegitimacy.supported,
      title: '黄金時代を築いた改革者',
      description: '国民の信頼を勝ち取りながら、国家を空前の繁栄に導いた。'
          'あなたの名は建国以来の名君として長く語り継がれるだろう。',
    ),
    (RegimeType.democratic, EndingOutcome.prosperity,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.prosperity,
      legitimacy: EndingLegitimacy.oppressive,
      title: '孤高の実務家',
      description: '制度は民主的だったが、あなたの政策は国民の心を掴めなかった。'
          '経済指標は良好でも、支持を欠いたまま任期を終えた。',
    ),
    (RegimeType.democratic, EndingOutcome.stagnation,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.stagnation,
      legitimacy: EndingLegitimacy.supported,
      title: '愛された凡庸な指導者',
      description: '目覚ましい成果こそ残せなかったが、国民との対話を怠らず、'
          '信頼される指導者として穏やかな時代を過ごした。',
    ),
    (RegimeType.democratic, EndingOutcome.stagnation,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.stagnation,
      legitimacy: EndingLegitimacy.oppressive,
      title: '迷走した調整役',
      description: '民主的な体裁は保ったが実質的な成果は乏しく、国民の信頼も次第に薄れていった。',
    ),
    (RegimeType.democratic, EndingOutcome.collapse,
        EndingLegitimacy.supported): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.collapse,
      legitimacy: EndingLegitimacy.supported,
      title: '志半ばの改革者',
      description: '国民はあなたを最後まで支持していたが、外的要因や積み重なった困難が'
          '国家を崩壊へと追いやった。悲劇的だが尊敬される結末である。',
    ),
    (RegimeType.democratic, EndingOutcome.collapse,
        EndingLegitimacy.oppressive): const Ending(
      regime: RegimeType.democratic,
      outcome: EndingOutcome.collapse,
      legitimacy: EndingLegitimacy.oppressive,
      title: '見捨てられた指導者',
      description: '民主的な体制を掲げながらも国民の信頼を失い、国家は崩壊した。'
          '歴史はあなたを無能な指導者として記録するだろう。',
    ),
  };
}
