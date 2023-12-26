import 'package:cachette/cachette.dart';

/// A cache entry, containing a [key], [value] and some metadata.
class CacheEntry<K, V, U extends Object> extends EntryInfo<K, U> {
  /// The value of the entry.
  final V value;

  const CacheEntry({
    required this.value,
    required super.key,
    required super.added,
    required super.lastAccess,
    required super.numUses,
    required super.users,
  });

  factory CacheEntry.build(V value, EntryInfo<K, U> info) => CacheEntry(
        value: value,
        key: info.key,
        added: info.added,
        lastAccess: info.lastAccess,
        numUses: info.numUses,
        users: info.users,
      );

  @override
  String toString() => 'CacheEntry($key, $value, uses: $numUses, '
      'lastAccess: $lastAccess, added: $added, users: $users)';
}
