/// Used internally to hold cache entry metadata within Cachette.
class EntryInfo<K, U extends Object> {
  /// The key of the entry.
  final K key;

  /// When the entry was first added to the cache.
  final DateTime added;

  /// When the entry was last read.
  final DateTime lastAccess;

  /// The number of times the entry has been read.
  final int numUses;

  final Set<U> users;

  const EntryInfo({
    required this.key,
    required this.added,
    required this.lastAccess,
    this.numUses = 0,
    this.users = const {},
  });

  factory EntryInfo.create(K key, [Set<U>? users]) {
    final now = DateTime.now();
    return EntryInfo(
      key: key,
      added: now,
      lastAccess: now,
      users: {...users ?? {}},
    );
  }

  EntryInfo<K, U> copyWith({
    K? key,
    DateTime? added,
    DateTime? lastAccess,
    int? numUses,
    Set<U>? users,
  }) =>
      EntryInfo(
        key: key ?? this.key,
        added: added ?? this.added,
        lastAccess: lastAccess ?? this.lastAccess,
        numUses: numUses ?? this.numUses,
        users: users ?? this.users,
      );

  EntryInfo<K, U> update() =>
      copyWith(lastAccess: DateTime.now(), numUses: numUses + 1);

  EntryInfo<K, U> addUsers(Set<U> users) => copyWith(
        users: {...this.users, ...users},
        lastAccess: DateTime.now(),
      );

  EntryInfo<K, U> removeUsers(Set<U> users) => copyWith(
        users: {...this.users}..removeAll(users),
      );
}
