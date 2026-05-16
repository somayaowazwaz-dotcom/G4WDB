class BloomFilterService {
  // Simple bit array implementation for privacy
  final List<bool> _bits = List.filled(1000, false);

  void add(String key) {
    final hash = key.hashCode.abs() % 1000;
    _bits[hash] = true;
  }

  bool mightContain(String key) {
    final hash = key.hashCode.abs() % 1000;
    return _bits[hash];
  }
}