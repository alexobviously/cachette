import 'dart:async';

import 'package:cachette/cachette.dart';

/// A simple in-memory cache.
class Cachette<K, V extends Object> {
  /// The maximum number of items the cache can hold.
  final int size;

  /// Used to determine which items to evict when the cache becomes full.
  final EvictionPolicy evictionPolicy;

  /// Used to determine what should be done in the case of a key conflict.
  final ConflictPolicy conflictPolicy;

  /// Will be called each time an item is evicted.
  final void Function(CacheEntry<K, V> e)? onEvict;

  Cachette(
    this.size, {
    this.evictionPolicy = EvictionPolicy.leastRecentlyUsed,
    this.conflictPolicy = ConflictPolicy.overwrite,
    this.onEvict,
  });

  final Map<K, V> _items = {};
  final Map<K, EntryInfo<K>> _registry = {};

  int get length => _items.length;
  Iterable<K> get keys => _items.keys;
  Iterable<V> get values => _items.values;
  Iterable<CacheEntry<K, V>> get entries =>
      _registry.values.map((e) => CacheEntry.build(_items[e.key]!, e));

  final StreamController<CacheEntry<K, V>> _evictionStreamController =
      StreamController.broadcast();

  /// A stream of evicted cache entries.
  Stream<CacheEntry<K, V>> get evictionStream =>
      _evictionStreamController.stream;

  V? operator [](K key) => get(key).object?.value;
  void operator []=(K key, V value) => add(key, value);

  Result<CacheEntry<K, V>, CachetteError> get(K key) {
    if (!_items.containsKey(key)) {
      return Result.error(NotFoundError(key));
    }
    final item = _items[key]!;
    final info = _registry[key]!.update();
    _registry[key] = info;
    return Result.ok(CacheEntry.build(item, info));
  }

  Result<CacheEntry<K, V>, CachetteError> add(
    K key,
    V value, {
    ConflictPolicy? conflictPolicy,
  }) {
    conflictPolicy ??= this.conflictPolicy;
    if (_items.containsKey(key)) {
      switch (conflictPolicy) {
        case ConflictPolicy.overwrite:
          break;
        case ConflictPolicy.fail:
          return Result.error(KeyConflictError(key));
        case ConflictPolicy.exception:
          throw CachetteException('Conflicting key: $key');
      }
    }

    final cleanRes = clean(size - 1);
    if (!cleanRes.ok) {
      return Result.error(cleanRes.error!);
    }

    _items[key] = value;
    _registry[key] = EntryInfo.create(key);

    return Result.ok(CacheEntry.build(value, _registry[key]!));
  }

  Result<CacheEntry<K, V>, CachetteError> remove(
    K key, {
    bool callOnEvict = false,
  }) {
    if (!_items.containsKey(key)) {
      return Result.error(NotFoundError(key));
    }
    final result = _evict(key, callOnEvict: callOnEvict);
    if (!result.ok) {
      return Result.error(result.error!);
    }
    return Result.ok(result.object!);
  }

  void clear() {
    _items.clear();
    _registry.clear();
  }

  Result<int, CachetteError> clean([int? sizeLimit]) {
    sizeLimit ??= size;
    int toEvict = length - sizeLimit;
    if (toEvict < 1) {
      return Result.ok(0);
    }

    if (evictionPolicy == EvictionPolicy.dontEvict) {
      return Result.error(CacheFullError());
    }

    List<K> keys = gather(evictionPolicy, toEvict);
    return _evictMany(keys);
  }

  Result<int, CachetteError> _evictMany(
    List<K> keys, {
    bool callOnEvict = true,
  }) {
    for (K k in keys) {
      final res = _evict(k, callOnEvict: callOnEvict);
      if (!res.ok) {
        return Result.error(res.error!);
      }
    }
    return Result.ok(keys.length);
  }

  Result<CacheEntry<K, V>, CachetteError> _evict(K key,
      {bool callOnEvict = true}) {
    if (!_items.containsKey(key)) {
      return Result.error(NotFoundError(key));
    }
    final entry = CacheEntry.build(_items[key]!, _registry[key]!);
    if (callOnEvict) {
      onEvict?.call(entry);
      _evictionStreamController.add(entry);
    }
    _items.remove(key);
    _registry.remove(key);
    return Result.ok(entry);
  }

  late final Map<EvictionPolicy, GatherFunction<K>> _gatherers = {
    EvictionPolicy.fifo: _gatherFirst,
    EvictionPolicy.lifo: _gatherLast,
    EvictionPolicy.random: _gatherRandom,
    EvictionPolicy.leastRecentlyUsed: _gatherLru,
    EvictionPolicy.mostRecentlyUsed: _gatherMru,
    EvictionPolicy.leastFrequentlyUsed: _gatherLfu,
    EvictionPolicy.mostFrequentlyUsed: _gatherMfu,
  };

  List<K> gather(EvictionPolicy policy, int num) =>
      _gatherers[policy]?.call(num) ?? [];

  List<K> _gatherFirst(int num) => _items.keys.take(num).toList();
  List<K> _gatherLast(int num) =>
      _items.keys.toList().reversed.take(num).toList();
  List<K> _gatherRandom(int num) =>
      (_items.keys.toList()..shuffle()).take(num).toList();
  List<K> _gatherLru(int num) => (_registry.values.toList()
        ..sort((a, b) => a.lastAccess.compareTo(b.lastAccess)))
      .map((e) => e.key)
      .take(num)
      .toList();
  List<K> _gatherMru(int num) => (_registry.values.toList()
        ..sort((a, b) => b.lastAccess.compareTo(a.lastAccess)))
      .map((e) => e.key)
      .take(num)
      .toList();
  List<K> _gatherLfu(int num) => (_registry.values.toList()
        ..sort((a, b) => a.numUses.compareTo(b.numUses)))
      .map((e) => e.key)
      .take(num)
      .toList();
  List<K> _gatherMfu(int num) => (_registry.values.toList()
        ..sort((a, b) => b.numUses.compareTo(a.numUses)))
      .map((e) => e.key)
      .take(num)
      .toList();
}
