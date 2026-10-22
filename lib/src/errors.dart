/// Exceptions related to Cachette.
class const CachetteException(final String message) {
  @override
  String toString() => 'CachetteException($message)';
}

/// Parent class for Cachette related errors.
class const CachetteError() {
  @override
  String toString() => 'CachetteError';
}

/// Occurs if an attempt is made to add an item to the cache, whose key is
/// already in use, and the conflict policy is error.
class const KeyConflictError<K>(final K key) extends CachetteError {
  @override
  String toString() => 'Key Conflict ($key)';

  @override
  bool operator ==(Object other) =>
      other is KeyConflictError && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// Occurs if the cache is full and the eviction policy is dontEvict.
class const CacheFullError() extends CachetteError {
  @override
  String toString() => 'Cache Full';

  @override
  bool operator ==(Object other) => other is CacheFullError;

  @override
  int get hashCode => 0;
}

/// Occurs if a queried key was not found in the cache.
class const NotFoundError<K>(final K key) extends CachetteError {
  @override
  String toString() => 'Not Found ($key)';

  @override
  bool operator ==(Object other) => other is NotFoundError && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
