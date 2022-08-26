class CachetteException {
  final String message;
  const CachetteException(this.message);
  @override
  String toString() => 'CachetteException($message)';
}

class CachetteError {
  const CachetteError();
  @override
  String toString() => 'CachetteError';
}

class KeyConflictError<K> extends CachetteError {
  final K key;
  const KeyConflictError(this.key);
  @override
  String toString() => 'Key Conflict ($key)';
}

class CacheFullError extends CachetteError {
  const CacheFullError();
  @override
  String toString() => 'Cache Full';
}

class NotFoundError<K> extends CachetteError {
  final K key;
  const NotFoundError(this.key);
  @override
  String toString() => 'Not Found ($key)';
}
