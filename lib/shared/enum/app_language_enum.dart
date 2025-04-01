import 'dart:ui';

enum AppLanguage {
  english('en', 'US', 'assets/svgs/en.svg', 'English'),
  vietnamese('vi', 'VN', 'assets/svgs/vi.svg', 'Tiếng Việt'),
  japanese('ja', 'JP', 'assets/svgs/ja.svg', '日本語');

  final String languageCode;
  final String countryCode;
  final String flagPath;
  final String name;

  const AppLanguage(this.languageCode, this.countryCode, this.flagPath, this.name);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
          (lang) => lang.languageCode == code,
      orElse: () => AppLanguage.vietnamese,
    );
  }

  Locale get locale => Locale(languageCode, countryCode);
}
