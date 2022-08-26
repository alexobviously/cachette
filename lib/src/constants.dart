enum EvictionPolicy {
  dontEvict,
  firstIn,
  lastIn,
  leastRecentlyUsed,
  leastFrequentlyUsed,
}

enum ConflictPolicy {
  overwrite,
  fail,
  exception,
}
