enum EvictionPolicy {
  dontEvict,
  firstIn,
  lastIn,
  random,
  leastRecentlyUsed,
  leastFrequentlyUsed,
}

enum ConflictPolicy {
  overwrite,
  fail,
  exception,
}
