import 'package:cachette/cachette.dart';

/// A cache entry, containing a [key], [value] and some metadata.
class const CacheEntry<K, V, U extends Object>({
  /// The value of the entry.
  required final V value,
  required super.key,
  required super.added,
  required super.lastAccess,
  super.numUses,
  super.users,
  super.lastTick,
}) extends EntryInfo<K, U> {
  factory build(V value, EntryInfo<K, U> info) => CacheEntry(
    value: value,
    key: info.key,
    added: info.added,
    lastAccess: info.lastAccess,
    numUses: info.numUses,
    users: info.users,
    lastTick: info.lastTick,
  );

  @override
  String toString() =>
      'CacheEntry($key, $value, uses: $numUses, '
      'lastAccess: $lastAccess, added: $added, users: $users)';
}
