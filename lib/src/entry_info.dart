/// Used internally to hold cache entry metadata within Cachette.
class const EntryInfo<K, U extends Object>({
  /// The key of the entry.
  required final K key,

  /// When the entry was first added to the cache.
  required final DateTime added,

  /// When the entry was last read.
  required final DateTime lastAccess,

  /// The number of times the entry has been read.
  final int numUses = 0,

  /// Users that are currently registered to this entry.
  final Set<U> users = const {},
}) {
  factory create(K key, [Set<U>? users]) {
    final DateTime now = .now();
    return EntryInfo(
      key: key,
      added: now,
      lastAccess: now,
      users: {...?users},
    );
  }

  /// Creates a copy of this entry with some values changed.
  EntryInfo<K, U> copyWith({
    K? key,
    DateTime? added,
    DateTime? lastAccess,
    int? numUses,
    Set<U>? users,
  }) => EntryInfo(
    key: key ?? this.key,
    added: added ?? this.added,
    lastAccess: lastAccess ?? this.lastAccess,
    numUses: numUses ?? this.numUses,
    users: users ?? this.users,
  );

  /// Sets `lastAccess` to now and increments `numUses`.
  EntryInfo<K, U> update() =>
      copyWith(lastAccess: .now(), numUses: numUses + 1);

  /// Adds [users] to the entry's user list.
  EntryInfo<K, U> addUsers(Set<U> users) => copyWith(
    users: {...this.users, ...users},
    lastAccess: .now(),
  );

  /// Removes [users] from the entry's user list.
  EntryInfo<K, U> removeUsers(Set<U> users) => copyWith(
    users: {...this.users}..removeAll(users),
  );
}
