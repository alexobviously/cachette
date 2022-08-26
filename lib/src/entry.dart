import 'package:cachette/cachette.dart';

class CacheEntry<K, V> extends EntryInfo<K> {
  final V value;

  const CacheEntry({
    required this.value,
    required super.key,
    required super.added,
    required super.lastAccess,
    required super.numUses,
  });

  factory CacheEntry.build(V value, EntryInfo<K> info) => CacheEntry(
        value: value,
        key: info.key,
        added: info.added,
        lastAccess: info.lastAccess,
        numUses: info.numUses,
      );
}
