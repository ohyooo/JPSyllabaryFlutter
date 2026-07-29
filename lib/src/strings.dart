import 'kana_data.dart';

class AppStrings {
  const AppStrings(this.zh);

  final bool zh;

  String get appName => zh ? '五十音测试' : 'JpSyllabary';
  String get single => zh ? '快测' : 'Single';
  String get table => zh ? '表格' : 'Table';
  String get twister => zh ? '绕口令' : 'Tongue Twister';
  String get source => zh ? '源码' : 'Source Code';
  String get hiragana => zh ? '平假名' : 'Hiragana';
  String get katakana => zh ? '片假名' : 'Katakana';
  String get romaji => zh ? '罗马音' : 'Romaji';
  String get sonant => zh ? '浊音' : 'Sonant';
  String get shuffle => zh ? '随机排序' : 'Shuffle';
  String get order => zh ? '恢复顺序' : 'Restore order';
  String get revealHint => zh ? '点击显示读音' : 'Tap to reveal';
  String get next => zh ? '下一个' : 'Next';
  String get openRepository => zh ? '打开 GitHub 仓库' : 'Open GitHub repository';

  String group(KanaGroup group) => switch (group) {
    KanaGroup.hiraganaVoiceless => zh ? '平假名 · 清音' : 'Hiragana · Voiceless',
    KanaGroup.katakanaVoiceless => zh ? '片假名 · 清音' : 'Katakana · Voiceless',
    KanaGroup.hiraganaVoiced => zh ? '平假名 · 浊音' : 'Hiragana · Voiced',
    KanaGroup.katakanaVoiced => zh ? '片假名 · 浊音' : 'Katakana · Voiced',
    KanaGroup.hiraganaSemiVoiced => zh ? '平假名 · 半浊音' : 'Hiragana · Semi-voiced',
    KanaGroup.katakanaSemiVoiced => zh ? '片假名 · 半浊音' : 'Katakana · Semi-voiced',
  };
}
