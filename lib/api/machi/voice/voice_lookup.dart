final RegExp persian = RegExp(r'^[\u0600-\u06FF]+');
final RegExp english = RegExp(r'^[a-zA-Z]+');
final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
final RegExp chinese = RegExp(r'^[\u4E00-\u9FFF]+');
final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
final RegExp ukrainian = RegExp(r'^[\u0400-\u04FF\u0500-\u052F]+');
final RegExp russian = RegExp(r'^[\u0400-\u04FF]+');
final RegExp italian = RegExp(r'^[\u00C0-\u017F]+');
final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
final RegExp spanish = RegExp(
    r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

/// list all Male voices from this region
/// copied from https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support?tabs=tts#voice-styles-and-roles
/// to save api call
List<Map<String, String>> regionLang({required String lang}) {
  switch (lang) {
    case 'en':
      dynamic base = {'lang': 'en'};
      return [
        {
          ...base,
          'region': 'US',
          'person': 'Jason',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Amber',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Ana',
          'age': 'Child',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Aria',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Ashley',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Brandon',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Christopher',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Cora',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Davis',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Elizabeth',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Eric',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Guy',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Jacob',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Jane',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Jenny',
          'age': 'Adult',
          'tone': 'MultilingualNeural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Jenny',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Michelle',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Monica',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Nancy',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Roger',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Sara',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Steffan',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'US',
          'person': 'Tony',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Abbi',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Alfie',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Bella',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Elliot',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Ethan',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Hollie',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Libby',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Maisie',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Noah',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Oliver',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Olivia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Ryan',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Sonia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'UK',
          'person': 'Thomas',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'IE',
          'person': 'Connor',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'IE',
          'person': 'Emily',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'NZ',
          'person': 'Mitchell',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'NZ',
          'person': 'Molly',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    case 'fr':
      dynamic base = {'lang': 'fr'};
      return [
        {
          ...base,
          'region': 'FR',
          'person': 'Alain',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Brigitte',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Celeste',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Claude',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Coralie',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Denise',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Eloise',
          'age': 'Child',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Henri',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Jacqueline',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Jerome',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Josephine',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Maurice',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Yves',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'FR',
          'person': 'Yvette',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    case 'es':
      dynamic base = {'lang': 'es'};
      return [
        {
          ...base,
          'region': 'ES',
          'person': 'Abril',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Arnau',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Dario',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Elias',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Elvira',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Estrella',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Irene',
          'age': 'Child',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Laia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Lia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Nil',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Saul',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Teo',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Triana',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'ES',
          'person': 'Vera',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Beatriz',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Candela',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Carlota',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Cecilio',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Dalia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Gerardo',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Jorge',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Larissa',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Luciano',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Marina',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Nuria',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Pelayo',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Renata',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'MX',
          'person': 'Yago',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    case 'zh':
      dynamic base = {'lang': 'zh'};
      return [
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaochen',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaohan',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaomeng',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaomo',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaoqiu',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaorui',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaoshuang',
          'age': 'Child',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaoxuan',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Xiaoyou',
          'age': 'Child',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunfeng',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunjian',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunxia',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunxi',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunyang',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'CN',
          'person': 'Yunye',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'TW',
          'person': 'HsiaoChen',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'TW',
          'person': 'HsiaoYu',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'TW',
          'person': 'YunJhe',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'HK',
          'person': 'HiuGaai',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'HK',
          'person': 'HiuMaan',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    case 'ko':
      dynamic base = {'lang': 'ko'};
      return [
        {
          ...base,
          'region': 'KR',
          'person': 'BongJin',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'GookMin',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'InJoon',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'BongJin',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'JiMin',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'SeoHyeon',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'SoonBok',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'SunHi',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'YuJin',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    case 'jp':
      dynamic base = {'lang': 'ja'};
      return [
        {
          ...base,
          'region': 'KR',
          'person': 'Aoi',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Daichi',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Keita',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Mayu',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Nanami',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Naoki',
          'age': 'Adult',
          'tone': 'Neural'
        },
        {
          ...base,
          'region': 'KR',
          'person': 'Shiori',
          'age': 'Adult',
          'tone': 'Neural'
        },
      ];
    default:
      return [
        {'lang': 'en', 'region': 'US', 'person': 'en-US-SaraNeural'}
      ];
  }
}
