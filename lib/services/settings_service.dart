class SettingsService {
  SettingsService._internal();

  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() => _instance;

  bool randomModeEnabled = false;
  int randomIntervalMinutes = 5;
}
