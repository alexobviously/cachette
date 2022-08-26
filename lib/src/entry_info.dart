/// Used internally to hold cache entry metadata within Cachette.
class EntryInfo<K> {
  /// The key of the entry.
  final K key;

  /// When the entry was first added to the cache.
  final DateTime added;

  /// When the entry was last read.
  final DateTime lastAccess;

  /// The number of times the entry has been read.
  final int numUses;

  const EntryInfo({
    required this.key,
    required this.added,
    required this.lastAccess,
    this.numUses = 0,
  });

  factory EntryInfo.create(K key) {
    final now = DateTime.now();
    return EntryInfo(
      key: key,
      added: now,
      lastAccess: now,
    );
  }

  EntryInfo<K> copyWith({
    K? key,
    DateTime? added,
    DateTime? lastAccess,
    int? numUses,
  }) =>
      EntryInfo(
        key: key ?? this.key,
        added: added ?? this.added,
        lastAccess: lastAccess ?? this.lastAccess,
        numUses: numUses ?? this.numUses,
      );

  EntryInfo<K> update() =>
      copyWith(lastAccess: DateTime.now(), numUses: numUses + 1);
}
