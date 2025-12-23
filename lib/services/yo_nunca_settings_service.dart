import '../data/yo_nunca_data.dart';

class YoNuncaSettingsService {
  YoNuncaSettingsService._internal();

  static final YoNuncaSettingsService _instance =
      YoNuncaSettingsService._internal();

  factory YoNuncaSettingsService() => _instance;

  Set<YoNuncaCategory> _enabledCategories = {
    YoNuncaCategory.suave,
    YoNuncaCategory.picante,
  };

  bool _mixAll = true;

  Set<YoNuncaCategory> get enabledCategories =>
      Set<YoNuncaCategory>.from(_enabledCategories);

  bool get mixAll => _mixAll;

  void setCategories(Set<YoNuncaCategory> categories) {
    _enabledCategories = Set<YoNuncaCategory>.from(categories);
  }

  void setMixAll(bool value) {
    _mixAll = value;
  }
}
