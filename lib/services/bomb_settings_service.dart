enum BombVariant { normal, fake, silent }

class BombSettingsService {
  BombSettingsService._internal();

  static final BombSettingsService _instance =
      BombSettingsService._internal();

  factory BombSettingsService() => _instance;

  BombVariant _variant = BombVariant.normal;

  BombVariant get variant => _variant;

  void setVariant(BombVariant variant) {
    _variant = variant;
  }
}
