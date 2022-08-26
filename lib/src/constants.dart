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
