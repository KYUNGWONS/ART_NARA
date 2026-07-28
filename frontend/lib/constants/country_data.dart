class CountryData {
  final String code;
  final String nameEn;
  final String flag;
  final List<String> defaultLanguages;

  const CountryData({
    required this.code,
    required this.nameEn,
    required this.flag,
    required this.defaultLanguages,
  });
}

class LanguageData {
  final String code;
  final String nameEn;
  final String nameNative;

  const LanguageData({
    required this.code,
    required this.nameEn,
    required this.nameNative,
  });
}

// 주요 국가 목록 (ISO 3166-1 기반)
const List<CountryData> countries = [
  CountryData(
    code: 'US',
    nameEn: 'United States',
    flag: '🇺🇸',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'GB',
    nameEn: 'United Kingdom',
    flag: '🇬🇧',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'CA',
    nameEn: 'Canada',
    flag: '🇨🇦',
    defaultLanguages: ['en', 'fr'],
  ),
  CountryData(
    code: 'AU',
    nameEn: 'Australia',
    flag: '🇦🇺',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'NZ',
    nameEn: 'New Zealand',
    flag: '🇳🇿',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'JP',
    nameEn: 'Japan',
    flag: '🇯🇵',
    defaultLanguages: ['ja'],
  ),
  CountryData(
    code: 'CN',
    nameEn: 'China',
    flag: '🇨🇳',
    defaultLanguages: ['zh'],
  ),
  CountryData(
    code: 'TW',
    nameEn: 'Taiwan',
    flag: '🇹🇼',
    defaultLanguages: ['zh'],
  ),
  CountryData(
    code: 'HK',
    nameEn: 'Hong Kong',
    flag: '🇭🇰',
    defaultLanguages: ['zh', 'en'],
  ),
  CountryData(
    code: 'SG',
    nameEn: 'Singapore',
    flag: '🇸🇬',
    defaultLanguages: ['en', 'zh'],
  ),
  CountryData(
    code: 'TH',
    nameEn: 'Thailand',
    flag: '🇹🇭',
    defaultLanguages: ['th'],
  ),
  CountryData(
    code: 'VN',
    nameEn: 'Vietnam',
    flag: '🇻🇳',
    defaultLanguages: ['vi'],
  ),
  CountryData(
    code: 'PH',
    nameEn: 'Philippines',
    flag: '🇵🇭',
    defaultLanguages: ['en', 'tl'],
  ),
  CountryData(
    code: 'MY',
    nameEn: 'Malaysia',
    flag: '🇲🇾',
    defaultLanguages: ['ms', 'en'],
  ),
  CountryData(
    code: 'ID',
    nameEn: 'Indonesia',
    flag: '🇮🇩',
    defaultLanguages: ['id'],
  ),
  CountryData(
    code: 'IN',
    nameEn: 'India',
    flag: '🇮🇳',
    defaultLanguages: ['hi', 'en'],
  ),
  CountryData(
    code: 'DE',
    nameEn: 'Germany',
    flag: '🇩🇪',
    defaultLanguages: ['de'],
  ),
  CountryData(
    code: 'FR',
    nameEn: 'France',
    flag: '🇫🇷',
    defaultLanguages: ['fr'],
  ),
  CountryData(
    code: 'ES',
    nameEn: 'Spain',
    flag: '🇪🇸',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'IT',
    nameEn: 'Italy',
    flag: '🇮🇹',
    defaultLanguages: ['it'],
  ),
  CountryData(
    code: 'PT',
    nameEn: 'Portugal',
    flag: '🇵🇹',
    defaultLanguages: ['pt'],
  ),
  CountryData(
    code: 'NL',
    nameEn: 'Netherlands',
    flag: '🇳🇱',
    defaultLanguages: ['nl'],
  ),
  CountryData(
    code: 'BE',
    nameEn: 'Belgium',
    flag: '🇧🇪',
    defaultLanguages: ['nl', 'fr', 'de'],
  ),
  CountryData(
    code: 'CH',
    nameEn: 'Switzerland',
    flag: '🇨🇭',
    defaultLanguages: ['de', 'fr', 'it'],
  ),
  CountryData(
    code: 'AT',
    nameEn: 'Austria',
    flag: '🇦🇹',
    defaultLanguages: ['de'],
  ),
  CountryData(
    code: 'SE',
    nameEn: 'Sweden',
    flag: '🇸🇪',
    defaultLanguages: ['sv'],
  ),
  CountryData(
    code: 'NO',
    nameEn: 'Norway',
    flag: '🇳🇴',
    defaultLanguages: ['no'],
  ),
  CountryData(
    code: 'DK',
    nameEn: 'Denmark',
    flag: '🇩🇰',
    defaultLanguages: ['da'],
  ),
  CountryData(
    code: 'FI',
    nameEn: 'Finland',
    flag: '🇫🇮',
    defaultLanguages: ['fi'],
  ),
  CountryData(
    code: 'RU',
    nameEn: 'Russia',
    flag: '🇷🇺',
    defaultLanguages: ['ru'],
  ),
  CountryData(
    code: 'PL',
    nameEn: 'Poland',
    flag: '🇵🇱',
    defaultLanguages: ['pl'],
  ),
  CountryData(
    code: 'CZ',
    nameEn: 'Czech Republic',
    flag: '🇨🇿',
    defaultLanguages: ['cs'],
  ),
  CountryData(
    code: 'TR',
    nameEn: 'Turkey',
    flag: '🇹🇷',
    defaultLanguages: ['tr'],
  ),
  CountryData(
    code: 'BR',
    nameEn: 'Brazil',
    flag: '🇧🇷',
    defaultLanguages: ['pt'],
  ),
  CountryData(
    code: 'MX',
    nameEn: 'Mexico',
    flag: '🇲🇽',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'AR',
    nameEn: 'Argentina',
    flag: '🇦🇷',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'CL',
    nameEn: 'Chile',
    flag: '🇨🇱',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'CO',
    nameEn: 'Colombia',
    flag: '🇨🇴',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'PE',
    nameEn: 'Peru',
    flag: '🇵🇪',
    defaultLanguages: ['es'],
  ),
  CountryData(
    code: 'EG',
    nameEn: 'Egypt',
    flag: '🇪🇬',
    defaultLanguages: ['ar'],
  ),
  CountryData(
    code: 'SA',
    nameEn: 'Saudi Arabia',
    flag: '🇸🇦',
    defaultLanguages: ['ar'],
  ),
  CountryData(
    code: 'AE',
    nameEn: 'UAE',
    flag: '🇦🇪',
    defaultLanguages: ['ar', 'en'],
  ),
  CountryData(
    code: 'IL',
    nameEn: 'Israel',
    flag: '🇮🇱',
    defaultLanguages: ['he'],
  ),
  CountryData(
    code: 'ZA',
    nameEn: 'South Africa',
    flag: '🇿🇦',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'NG',
    nameEn: 'Nigeria',
    flag: '🇳🇬',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'KE',
    nameEn: 'Kenya',
    flag: '🇰🇪',
    defaultLanguages: ['en', 'sw'],
  ),
  CountryData(
    code: 'MN',
    nameEn: 'Mongolia',
    flag: '🇲🇳',
    defaultLanguages: ['mn'],
  ),
  CountryData(
    code: 'UZ',
    nameEn: 'Uzbekistan',
    flag: '🇺🇿',
    defaultLanguages: ['uz'],
  ),
  CountryData(
    code: 'KZ',
    nameEn: 'Kazakhstan',
    flag: '🇰🇿',
    defaultLanguages: ['kk', 'ru'],
  ),
  CountryData(
    code: 'UA',
    nameEn: 'Ukraine',
    flag: '🇺🇦',
    defaultLanguages: ['uk'],
  ),
  CountryData(
    code: 'GR',
    nameEn: 'Greece',
    flag: '🇬🇷',
    defaultLanguages: ['el'],
  ),
  CountryData(
    code: 'IE',
    nameEn: 'Ireland',
    flag: '🇮🇪',
    defaultLanguages: ['en'],
  ),
  CountryData(
    code: 'RO',
    nameEn: 'Romania',
    flag: '🇷🇴',
    defaultLanguages: ['ro'],
  ),
  CountryData(
    code: 'HU',
    nameEn: 'Hungary',
    flag: '🇭🇺',
    defaultLanguages: ['hu'],
  ),
  CountryData(
    code: 'MM',
    nameEn: 'Myanmar',
    flag: '🇲🇲',
    defaultLanguages: ['my'],
  ),
  CountryData(
    code: 'KH',
    nameEn: 'Cambodia',
    flag: '🇰🇭',
    defaultLanguages: ['km'],
  ),
  CountryData(
    code: 'LA',
    nameEn: 'Laos',
    flag: '🇱🇦',
    defaultLanguages: ['lo'],
  ),
  CountryData(
    code: 'NP',
    nameEn: 'Nepal',
    flag: '🇳🇵',
    defaultLanguages: ['ne'],
  ),
  CountryData(
    code: 'BD',
    nameEn: 'Bangladesh',
    flag: '🇧🇩',
    defaultLanguages: ['bn'],
  ),
  CountryData(
    code: 'PK',
    nameEn: 'Pakistan',
    flag: '🇵🇰',
    defaultLanguages: ['ur', 'en'],
  ),
];

// 주요 언어 목록
const List<LanguageData> spokenLanguages = [
  LanguageData(code: 'ko', nameEn: 'Korean', nameNative: '한국어'),
  LanguageData(code: 'en', nameEn: 'English', nameNative: 'English'),
  LanguageData(code: 'ja', nameEn: 'Japanese', nameNative: '日本語'),
  LanguageData(code: 'zh', nameEn: 'Chinese', nameNative: '中文'),
  LanguageData(code: 'es', nameEn: 'Spanish', nameNative: 'Español'),
  LanguageData(code: 'fr', nameEn: 'French', nameNative: 'Français'),
  LanguageData(code: 'de', nameEn: 'German', nameNative: 'Deutsch'),
  LanguageData(code: 'it', nameEn: 'Italian', nameNative: 'Italiano'),
  LanguageData(code: 'pt', nameEn: 'Portuguese', nameNative: 'Português'),
  LanguageData(code: 'ru', nameEn: 'Russian', nameNative: 'Русский'),
  LanguageData(code: 'ar', nameEn: 'Arabic', nameNative: 'العربية'),
  LanguageData(code: 'hi', nameEn: 'Hindi', nameNative: 'हिन्दी'),
  LanguageData(code: 'th', nameEn: 'Thai', nameNative: 'ไทย'),
  LanguageData(code: 'vi', nameEn: 'Vietnamese', nameNative: 'Tiếng Việt'),
  LanguageData(
    code: 'id',
    nameEn: 'Indonesian',
    nameNative: 'Bahasa Indonesia',
  ),
  LanguageData(code: 'ms', nameEn: 'Malay', nameNative: 'Bahasa Melayu'),
  LanguageData(code: 'tl', nameEn: 'Filipino', nameNative: 'Filipino'),
  LanguageData(code: 'tr', nameEn: 'Turkish', nameNative: 'Türkçe'),
  LanguageData(code: 'pl', nameEn: 'Polish', nameNative: 'Polski'),
  LanguageData(code: 'nl', nameEn: 'Dutch', nameNative: 'Nederlands'),
  LanguageData(code: 'sv', nameEn: 'Swedish', nameNative: 'Svenska'),
  LanguageData(code: 'no', nameEn: 'Norwegian', nameNative: 'Norsk'),
  LanguageData(code: 'da', nameEn: 'Danish', nameNative: 'Dansk'),
  LanguageData(code: 'fi', nameEn: 'Finnish', nameNative: 'Suomi'),
  LanguageData(code: 'he', nameEn: 'Hebrew', nameNative: 'עברית'),
  LanguageData(code: 'uk', nameEn: 'Ukrainian', nameNative: 'Українська'),
  LanguageData(code: 'mn', nameEn: 'Mongolian', nameNative: 'Монгол'),
  LanguageData(code: 'sw', nameEn: 'Swahili', nameNative: 'Kiswahili'),
  LanguageData(code: 'bn', nameEn: 'Bengali', nameNative: 'বাংলা'),
  LanguageData(code: 'ur', nameEn: 'Urdu', nameNative: 'اردو'),
];
