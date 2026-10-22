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

  /// Logical timestamp indicating when the entry was last accessed or added.
  final int lastTick = 0,
}) {
  factory create(K key, [Set<U>? users, int tick = 0]) {
    final DateTime now = .now();
    return EntryInfo(
      key: key,
      added: now,
      lastAccess: now,
      users: {...?users},
      lastTick: tick,
    );
  }

  /// Creates a copy of this entry with some values changed.
  EntryInfo<K, U> copyWith({
    K? key,
    DateTime? added,
    DateTime? lastAccess,
    int? numUses,
    Set<U>? users,
    int? lastTick,
  }) => EntryInfo(
    key: key ?? this.key,
    added: added ?? this.added,
    lastAccess: lastAccess ?? this.lastAccess,
    numUses: numUses ?? this.numUses,
    users: users ?? this.users,
    lastTick: lastTick ?? this.lastTick,
  );

  /// Sets `lastAccess` to now, increments `numUses`, and optionally updates `lastTick`.
  EntryInfo<K, U> update([int? tick]) => copyWith(
    lastAccess: .now(),
    numUses: numUses + 1,
    lastTick: tick,
  );

  /// Adds [users] to the entry's user list and optionally updates `lastTick`.
  EntryInfo<K, U> addUsers(Set<U> users, [int? tick]) => copyWith(
    users: {...this.users, ...users},
    lastAccess: .now(),
    lastTick: tick,
  );

  /// Removes [users] from the entry's user list.
  EntryInfo<K, U> removeUsers(Set<U> users) => copyWith(
    users: {...this.users}..removeAll(users),
  );
}
