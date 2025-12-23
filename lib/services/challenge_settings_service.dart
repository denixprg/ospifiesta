import '../data/challenges.dart';

class ChallengeSettingsService {
  ChallengeSettingsService._internal();

  static final ChallengeSettingsService _instance =
      ChallengeSettingsService._internal();

  factory ChallengeSettingsService() => _instance;

  Set<ChallengeCategory> _enabledCategories = {
    ChallengeCategory.suave,
    ChallengeCategory.picante,
  };

  bool _mixAll = true;

  Set<ChallengeCategory> get enabledCategories =>
      Set<ChallengeCategory>.from(_enabledCategories);

  bool get mixAll => _mixAll;

  void setCategories(Set<ChallengeCategory> categories) {
    _enabledCategories = Set<ChallengeCategory>.from(categories);
  }

  void setMixAll(bool value) {
    _mixAll = value;
  }
}
