import 'dart:math';

class ShuffleBag<T> {
  final List<T> _original;
  final Random _random;
  List<T> _bag;

  ShuffleBag(List<T> items, {Random? random})
      : _original = List<T>.from(items),
        _bag = List<T>.from(items),
        _random = random ?? Random() {
    _bag.shuffle(_random);
  }

  T next() {
    if (_bag.isEmpty) {
      _bag = List<T>.from(_original);
      _bag.shuffle(_random);
    }
    return _bag.removeAt(0);
  }
}
