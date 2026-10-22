import 'dart:async';

import 'package:cachette/cachette.dart';
import 'package:elegant/elegant.dart';

/// A simple in-memory cache.
typedef Cachette<K, V extends Object> = CachetteBase<K, V, Object>;

/// A Cachette that allows you to establish user type bounds.
class UserCachette<K, V extends Object, U extends Object>(
  super.size, {
  super.evictionPolicy = .leastRecentlyUsed,
  super.onEvict,
  super.unevictableUsers = const {},
}) extends CachetteBase<K, V, U> {
  this : super(conflictPolicy: .users);
}

/// The base class for Cachette implementations.
/// You should probably use `Cachette` or `UserCachette`.
class CachetteBase<K, V extends Object, U extends Object>(
  /// The maximum number of items the cache can hold.
  final int size, {

  /// Used to determine which items to evict when the cache becomes full.
  final EvictionPolicy evictionPolicy = .leastRecentlyUsed,

  /// Used to determine what should be done in the case of a key conflict.
  final ConflictPolicy conflictPolicy = .overwrite,

  /// Will be called each time an item is evicted.
  final void Function(CacheEntry<K, V, U> entry)? onEvict,

  /// If an entry is used by any of these users, it cannot be evicted.
  final Set<U> unevictableUsers = const {},
}) {
  final Map<K, V> _items = {};
  final Map<K, EntryInfo<K, U>> _registry = {};
  int _tick = 0;

  /// The current number of items in the cache.
  int get length => _items.length;

  /// All of the keys in the cache.
  Iterable<K> get keys => _items.keys;

  /// All of the values in the cache.
  Iterable<V> get values => _items.values;

  /// All items in the cache, in `CacheEntry` form.
  Iterable<CacheEntry<K, V, U>> get entries =>
      _registry.values.map((e) => .build(_items[e.key]!, e));

  final StreamController<CacheEntry<K, V, U>> _evictionStreamController =
      .broadcast();

  /// A stream of evicted cache entries.
  Stream<CacheEntry<K, V, U>> get evictionStream =>
      _evictionStreamController.stream;

  /// Whether the Cachette is closed.
  bool get isClosed => _evictionStreamController.isClosed;

  V? operator [](K key) => get(key).object?.value;
  void operator []=(K key, V value) => add(key, value);

  /// Gets a cache item with [key].
  Result<CacheEntry<K, V, U>, CachetteError> get(K key) {
    if (isClosed) return .error(const CacheClosedError());
    if (!_items.containsKey(key)) {
      return .error(NotFoundError(key));
    }
    final item = _items[key]!;
    final info = _registry[key]!.update(++_tick);
    _registry[key] = info;
    return .ok(CacheEntry.build(item, info));
  }

  /// Whether the cache contains an item with [key].
  bool containsKey(K key) => _items.containsKey(key);

  /// Gets the list of all users registered to the cache item with [key].
  Result<Set<U>, CachetteError> getUsers(K key) =>
      (get(key)).transformOk<Set<U>>((e) => e!.users);

  /// Adds a cache item with [key] and [value].
  /// Use [conflictPolicy] to override the Cachette's conflict policy.
  /// If [user] or [users] are provided, they will be added to the cache item.
  /// Note that in order to use users, `ConflictPolicy.users` must be used.
  /// Try saying the previous sentence out loud quickly.
  Result<CacheEntry<K, V, U>, CachetteError> add(
    K key,
    V value, {
    ConflictPolicy? conflictPolicy,
    U? user,
    Set<U>? users,
  }) {
    if (isClosed) return .error(const CacheClosedError());
    conflictPolicy ??= this.conflictPolicy;
    if (_items.containsKey(key)) {
      switch (conflictPolicy) {
        case .overwrite:
        case .users:
          break;
        case .error:
          return .error(KeyConflictError(key));
        case .exception:
          throw CachetteException('Conflicting key: $key');
      }
    }

    final cleanRes = clean(sizeLimit: size - 1);
    if (!cleanRes.ok) {
      return .error(cleanRes.error!);
    }

    if (user != null) {
      users = {...?users, user};
    }

    final tick = ++_tick;
    _registry[key] = switch ((conflictPolicy, users)) {
      // This `update()` prevents wiping users when adding a 'null' user
      // to a cache with users. This seems like weird user behaviour, but
      // it's best to guard against it.
      (.users, null) =>
        _registry[key]?.update(tick) ?? .create(key, null, tick),
      (.users, Set<U> users) =>
        _registry[key]?.addUsers(users, tick) ?? .create(key, users, tick),
      _ => .create(key, users, tick),
    };

    _items[key] = value;

    return .ok(CacheEntry.build(value, _registry[key]!));
  }

  /// Adds [user] to the cache item with [key].
  /// Only works if the cache item already exists.
  Result<CacheEntry<K, V, U>, CachetteError> addUser(K key, U user) =>
      addUsers(key, {user});

  /// Adds [users] to the cache item with [key].
  /// Only works if the cache item already exists.
  Result<CacheEntry<K, V, U>, CachetteError> addUsers(K key, Set<U> users) {
    if (isClosed) return .error(const CacheClosedError());
    if (!_items.containsKey(key)) {
      return .error(NotFoundError(key));
    }
    final info = _registry[key]!.addUsers(users, ++_tick);
    _registry[key] = info;
    return .ok(.build(_items[key]!, info));
  }

  /// Removes a single [user] from thee cache item with [key].
  /// If [removeIfUnused] and the item has no users after removing [user],
  /// it will be removed from the cache.
  Result<CacheEntry<K, V, U>, CachetteError> removeUser(
    K key,
    U user, {
    bool removeIfUnused = true,
    bool callOnEvict = true,
  }) => removeUsers(
    key,
    {user},
    removeIfUnused: removeIfUnused,
    callOnEvict: callOnEvict,
  );

  /// Removes [users] from thee cache item with [key].
  /// If [removeIfUnused] and the item has no users after removing [users],
  /// it will be removed from the cache.
  Result<CacheEntry<K, V, U>, CachetteError> removeUsers(
    K key,
    Set<U> users, {
    bool removeIfUnused = true,
    bool callOnEvict = true,
  }) {
    if (isClosed) return .error(const CacheClosedError());
    if (!_items.containsKey(key)) {
      return .error(NotFoundError(key));
    }
    final info = _registry[key]!.removeUsers(users);
    if (info.users.isEmpty && removeIfUnused) {
      return remove(key, callOnEvict: callOnEvict);
    }
    _registry[key] = info;
    return .ok(.build(_items[key]!, info));
  }

  /// Removes an item with [key] from the cache.
  Result<CacheEntry<K, V, U>, CachetteError> remove(
    K key, {
    bool callOnEvict = false,
  }) {
    if (isClosed) return .error(const CacheClosedError());
    if (!_items.containsKey(key)) {
      return .error(NotFoundError(key));
    }
    final result = _evict(key, callOnEvict: callOnEvict);
    if (!result.ok) {
      return .error(result.error!);
    }
    return .ok(result.object!);
  }

  /// Removes all items from the cache.
  void clear() {
    if (isClosed) return;
    _items.clear();
    _registry.clear();
    _tick = 0;
  }

  /// Closes the [Cachette] and its resources (eviction stream controller).
  ///
  /// If [clear] is true, also empties the cache.
  Future<void> close({bool clear = true}) async {
    if (clear) {
      _items.clear();
      _registry.clear();
      _tick = 0;
    }
    await _evictionStreamController.close();
  }

  /// Cleans the cache, i.e. removes enough cache items to meet [sizeLimit].
  /// If [sizeLimit] isn't provided, the [size] of the Cachette is used, which
  /// is the most likely use case.
  /// [policy] can be used to override the Cachette's eviction policy.
  Result<int, CachetteError> clean({int? sizeLimit, EvictionPolicy? policy}) {
    if (isClosed) return .error(const CacheClosedError());
    sizeLimit ??= size;
    policy ??= evictionPolicy;
    int toEvict = length - sizeLimit;
    if (toEvict < 1) {
      return .ok(0);
    }

    if (policy == .dontEvict) {
      return .error(const CacheFullError());
    }

    List<K> keys = gather(policy, toEvict);
    return _evictMany(keys);
  }

  Result<int, CachetteError> _evictMany(
    List<K> keys, {
    bool callOnEvict = true,
  }) {
    for (K k in keys) {
      final res = _evict(k, callOnEvict: callOnEvict);
      if (!res.ok) {
        return .error(res.error!);
      }
    }
    return .ok(keys.length);
  }

  Result<CacheEntry<K, V, U>, CachetteError> _evict(
    K key, {
    bool callOnEvict = true,
  }) {
    if (!_items.containsKey(key)) {
      return .error(NotFoundError(key));
    }
    final entry = CacheEntry.build(_items[key]!, _registry[key]!);
    if (callOnEvict) {
      onEvict?.call(entry);
      if (!_evictionStreamController.isClosed) {
        _evictionStreamController.add(entry);
      }
    }
    _items.remove(key);
    _registry.remove(key);
    return .ok(entry);
  }

  bool _entryEvictable(EntryInfo entry) =>
      !entry.users.any((u) => unevictableUsers.contains(u));

  late final Map<EvictionPolicy, GatherFunction<K>> _gatherers = {
    .fifo: _gatherFirst,
    .lifo: _gatherLast,
    .random: _gatherRandom,
    .leastRecentlyUsed: _gatherLru,
    .mostRecentlyUsed: _gatherMru,
    .leastFrequentlyUsed: _gatherLfu,
    .mostFrequentlyUsed: _gatherMfu,
  };

  /// Retries up to [num] items to be evicted according to [policy].
  List<K> gather(EvictionPolicy policy, int num) =>
      _gatherers[policy]?.call(num) ?? [];

  List<K> _gatherFirst(int num) => _items.keys
      .where((e) => _entryEvictable(_registry[e]!))
      .take(num)
      .toList();

  List<K> _gatherLast(int num) => _items.keys
      .where((e) => _entryEvictable(_registry[e]!))
      .toList()
      .reversed
      .take(num)
      .toList();

  List<K> _gatherRandom(int num) =>
      (_items.keys.where((e) => _entryEvictable(_registry[e]!)).toList()
            ..shuffle())
          .take(num)
          .toList();

  List<K> _gatherLru(int num) =>
      (_registry.values.where(_entryEvictable).toList()
            ..sort((a, b) => a.lastTick.compareTo(b.lastTick)))
          .map((e) => e.key)
          .take(num)
          .toList();

  List<K> _gatherMru(int num) =>
      (_registry.values.where(_entryEvictable).toList()
            ..sort((a, b) => b.lastTick.compareTo(a.lastTick)))
          .map((e) => e.key)
          .take(num)
          .toList();

  List<K> _gatherLfu(int num) =>
      (_registry.values.where(_entryEvictable).toList()
            ..sort((a, b) => a.numUses.compareTo(b.numUses)))
          .map((e) => e.key)
          .take(num)
          .toList();

  List<K> _gatherMfu(int num) =>
      (_registry.values.where(_entryEvictable).toList()
            ..sort((a, b) => b.numUses.compareTo(a.numUses)))
          .map((e) => e.key)
          .take(num)
          .toList();
}
