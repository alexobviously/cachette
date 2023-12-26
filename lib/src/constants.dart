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
enum ConflictPolicy {
  overwrite,
  error,
  exception,
  users;
}

/// Returns [num] keys.
typedef GatherFunction<K> = List<K> Function(int num);
