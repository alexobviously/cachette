enum EvictionPolicy {
  dontEvict,
  fifo,
  lifo,
  random,
  leastRecentlyUsed,
  leastFrequentlyUsed,
}

enum ConflictPolicy {
  overwrite,
  fail,
  exception,
}
