/// Exceptions related to Cachette.
class CachetteException {
  final String message;
  const CachetteException(this.message);
  @override
  String toString() => 'CachetteException($message)';
}

/// Parent class for Cachette related errors.
class CachetteError {
  const CachetteError();
  @override
  String toString() => 'CachetteError';
}

/// Occurs if an attempt is made to add an item to the cache, whose key is
/// already in use, and the conflict policy is error.
class KeyConflictError<K> extends CachetteError {
  final K key;
  const KeyConflictError(this.key);

  @override
  String toString() => 'Key Conflict ($key)';

  @override
  bool operator ==(Object other) =>
      other is KeyConflictError && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// Occurs if the cache is full and the eviction policy is dontEvict.
class CacheFullError extends CachetteError {
  const CacheFullError();

  @override
  String toString() => 'Cache Full';

  @override
  bool operator ==(Object other) => other is CacheFullError;

  @override
  int get hashCode => 0;
}

/// Occurs if a queried key was not found in the cache.
class NotFoundError<K> extends CachetteError {
  final K key;
  const NotFoundError(this.key);

  @override
  String toString() => 'Not Found ($key)';

  @override
  bool operator ==(Object other) => other is NotFoundError && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
