import 'package:cachette/cachette.dart';

class Cachette<K, V extends Object> {
  final int size;
  final EvictionPolicy evictionPolicy;
  final ConflictPolicy conflictPolicy;

  Cachette({
    this.size = 100,
    this.evictionPolicy = EvictionPolicy.leastRecentlyUsed,
    this.conflictPolicy = ConflictPolicy.overwrite,
  });

  final Map<K, V> _items = {};
  final Map<K, EntryInfo<K>> _registry = {};

  int get length => _items.length;

  V? operator [](K key) => get(key).object?.value;

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

  Result<CacheEntry<K, V>, CachetteError> remove(K key) {
    if (!_items.containsKey(key)) {
      return Result.error(NotFoundError(key));
    }
    final entry = CacheEntry.build(_items[key]!, _registry[key]!);
    final result = _evict([key]);
    if (!result.ok) {
      return Result.error(result.error!);
    }
    return Result.ok(entry);
  }

  void clear() {
    _items.clear();
    _registry.clear();
  }

  Result<int, CachetteError> clean([int? sizeLimit]) {
    sizeLimit ??= size;
    int toEvict = sizeLimit - length;
    if (toEvict < 1) {
      return Result.ok(0);
    }

    if (evictionPolicy == EvictionPolicy.dontEvict) {
      return Result.error(CacheFullError());
    }

    List<K> keys = gather(evictionPolicy, toEvict);
    return _evict(keys);
  }

  Result<int, CachetteError> _evict(List<K> keys) {
    for (K k in keys) {
      _items.remove(k);
      _registry.remove(k);
    }
    return Result.ok(keys.length);
  }

  late final Map<EvictionPolicy, GatherFunction<K>> _gatherers = {
    EvictionPolicy.firstIn: _gatherFirst,
    EvictionPolicy.lastIn: _gatherLast,
    EvictionPolicy.leastFrequentlyUsed: _gatherLfu,
    EvictionPolicy.leastRecentlyUsed: _gatherLru,
  };

  List<K> gather(EvictionPolicy policy, int num) =>
      _gatherers[policy]?.call(num) ?? [];

  List<K> _gatherFirst(int num) => _items.keys.take(num).toList();
  List<K> _gatherLast(int num) =>
      _items.keys.toList().reversed.take(num).toList();
  List<K> _gatherLru(int num) => (_registry.values.toList()
        ..sort((a, b) => a.lastAccess.compareTo(b.lastAccess)))
      .map((e) => e.key)
      .take(num)
      .toList();
  List<K> _gatherLfu(int num) => (_registry.values.toList()
        ..sort((a, b) => a.numUses.compareTo(b.numUses)))
      .map((e) => e.key)
      .take(num)
      .toList();
}

typedef GatherFunction<K> = List<K> Function(int num);
