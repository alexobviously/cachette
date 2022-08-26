# Cachette
#### A simple in-memory cache.

Cachette is a very simple cache tool designed to fulfil the most basic use cases in an elegant way.

**What Cachette does**:
* Stores and retrieves key-value pairs in memory.
* Evicts excess values depending on the eviction policy. It currently supports *first in, first out* (FIFO), *last in, first out* (LIFO), *random eviction*, *least recently used* (LRU), *most recently used* (MRU), *least frequently used* (LFU), and *most frequently used* (MFU).
* Provides an elegant interface including streams and callbacks.
* Allows querying elements with functions like `where`.
* Doesn't require any `await` calls.

If you need to support more complex uses, you might want to consider using [stash](https://pub.dev/packages/stash).

## Basic Usage

```dart
final cache = Cachette<int, String>(3); // The positional parameter is size.
cache[0] = 'zero';
cache.add(1, 'one');
cache[2] = 'two';
print(cache[0]); // 'zero'
print(cache.get(2)); // Result(ok, CacheEntry(2, 'two'))
cache[3] = 'three';
print(cache.keys); // [0, 2, 3] - 1 was evicted under the default policy (LRU)
```