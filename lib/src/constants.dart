/// Policies that can be used to determine which entries are evicted as the
/// cache size limit is reached.
enum EvictionPolicy {
  dontEvict,
  fifo,
  lifo,
  random,
  leastRecentlyUsed,
  mostRecentlyUsed,
  leastFrequentlyUsed,
  mostFrequentlyUsed;
}

/// Policies that determine what happens if a key conflict happens.
/// `overwrite`: The new value overwrites the old value.
/// `error`: An error is returned when trying to add a key that already exists.
/// `exception`: An exception is thrown.
/// `users`: The same as `overwrite`, but the users list for the entry will be
/// modified if appropriate.
enum ConflictPolicy {
  overwrite,
  error,
  exception,
  users;
}

/// Returns [num] keys.
typedef GatherFunction<K> = List<K> Function(int num);
