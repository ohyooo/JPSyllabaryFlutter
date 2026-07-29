class KanaEntry {
  const KanaEntry(this.kana, this.romaji, this.group);

  final String kana;
  final String romaji;
  final KanaGroup group;
}

enum KanaGroup {
  hiraganaVoiceless,
  katakanaVoiceless,
  hiraganaVoiced,
  katakanaVoiced,
  hiraganaSemiVoiced,
  katakanaSemiVoiced,
}

List<String> _words(String value) => value.trim().split(RegExp(r'\s+'));

final hiragana = _words(
  'あ い う え お か き く け こ さ し す せ そ た ち つ て と '
  'な に ぬ ね の は ひ ふ へ ほ ま み む め も や ゆ よ '
  'ら り る れ ろ わ を',
);
final katakana = _words(
  'ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト '
  'ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ '
  'ラ リ ル レ ロ ワ ヲ',
);
final romaji = _words(
  'a i u e o ka ki ku ke ko sa shi su se so ta chi tsu te to '
  'na ni nu ne no ha hi fu he ho ma mi mu me mo ya yu yo '
  'ra ri ru re ro wa wo',
);
final voicedHiragana = _words('が ぎ ぐ げ ご ざ じ ず ぜ ぞ だ ぢ づ で ど ば び ぶ べ ぼ');
final voicedKatakana = _words('ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ ビ ブ ベ ボ');
final voicedRomaji = _words(
  'ga gi gu ge go za ji zu ze zo da dji dzu de do ba bi bu be bo',
);
final semiHiragana = _words('ぱ ぴ ぷ ぺ ぽ');
final semiKatakana = _words('パ ピ プ ペ ポ');
final semiRomaji = _words('pa pi pu pe po');

List<KanaEntry> _zip(List<String> kana, List<String> sounds, KanaGroup group) =>
    List.generate(
      kana.length,
      (index) => KanaEntry(kana[index], sounds[index], group),
    );

final allKana = <KanaEntry>[
  ..._zip(hiragana, romaji, KanaGroup.hiraganaVoiceless),
  ..._zip(katakana, romaji, KanaGroup.katakanaVoiceless),
  ..._zip(voicedHiragana, voicedRomaji, KanaGroup.hiraganaVoiced),
  ..._zip(voicedKatakana, voicedRomaji, KanaGroup.katakanaVoiced),
  ..._zip(semiHiragana, semiRomaji, KanaGroup.hiraganaSemiVoiced),
  ..._zip(semiKatakana, semiRomaji, KanaGroup.katakanaSemiVoiced),
];

final sonant = <String>[
  ...voicedHiragana,
  ...voicedKatakana,
  ...semiHiragana,
  ...semiKatakana,
];
final sonantRomaji = <String>[
  ...voicedRomaji,
  ...voicedRomaji,
  ...semiRomaji,
  ...semiRomaji,
];

const _vowels = ['a', 'i', 'u', 'e', 'o'];
const _rows = [
  ['あ', 'い', 'う', 'え', 'お'],
  ['か', 'き', 'く', 'け', 'こ'],
  ['さ', 'し', 'す', 'せ', 'そ'],
  ['た', 'ち', 'つ', 'て', 'と'],
  ['な', 'に', 'ぬ', 'ね', 'の'],
  ['は', 'ひ', 'ふ', 'へ', 'ほ'],
  ['ま', 'み', 'む', 'め', 'も'],
  ['や', 'い', 'ゆ', 'え', 'よ'],
  ['ら', 'り', 'る', 'れ', 'ろ'],
  ['わ', 'い', 'う', 'え', 'を'],
];
const _rowRomaji = [
  ['a', 'i', 'u', 'e', 'o'],
  ['ka', 'ki', 'ku', 'ke', 'ko'],
  ['sa', 'shi', 'su', 'se', 'so'],
  ['ta', 'chi', 'tsu', 'te', 'to'],
  ['na', 'ni', 'nu', 'ne', 'no'],
  ['ha', 'hi', 'fu', 'he', 'ho'],
  ['ma', 'mi', 'mu', 'me', 'mo'],
  ['ya', 'i', 'yu', 'e', 'yo'],
  ['ra', 'ri', 'ru', 're', 'ro'],
  ['wa', 'i', 'u', 'e', 'wo'],
];

String _toKatakana(String text) => String.fromCharCodes(
  text.runes.map(
    (rune) => rune >= 0x3041 && rune <= 0x3096 ? rune + 0x60 : rune,
  ),
);

/// Ten practice rows, each available as hiragana, katakana and romaji.
final twisterRows = List.generate(_rows.length, (row) {
  final values = _rows[row];
  final sounds = _rowRomaji[row];
  final pattern = <int>[
    0,
    3,
    1,
    -1,
    0,
    4,
    2,
    -1,
    0,
    3,
    1,
    2,
    3,
    4,
    0,
    4,
    -1,
    0,
    1,
    2,
    3,
    4,
  ];
  List<String> build(List<String> source) =>
      pattern.map((index) => index < 0 ? '　' : source[index]).toList();
  return [
    build(values),
    build(values.map(_toKatakana).toList()),
    build(sounds),
  ];
});

// Retained for parity with the source data and useful in tests/documentation.
const vowelOrder = _vowels;
