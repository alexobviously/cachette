enum EvictionPolicy {
  dontEvict,
  fifo,
  lifo,
  random,
  leastRecentlyUsed,
  mostRecentlyUsed,
  leastFrequentlyUsed,
  mostFrequentlyUsed,
}

enum ConflictPolicy {
  overwrite,
  fail,
  exception,
}

typedef GatherFunction<K> = List<K> Function(int num);
