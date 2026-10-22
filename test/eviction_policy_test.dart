import 'package:cachette/cachette.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Eviction Policy Tests', () {
    test('First In', () {
      final cache = Cachette<int, String>(
        3,
        evictionPolicy: .fifo,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }
      expect(cache.keys, [2, 3, 4]);
    });
    test('Last In', () {
      final cache = Cachette<int, String>(
        3,
        evictionPolicy: .lifo,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }
      expect(cache.keys, [0, 1, 4]);
    });
    test('Least Recently Used', () {
      final cache = Cachette<int, String>(
        5,
        evictionPolicy: .leastRecentlyUsed,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }
      cache.get(0);
      cache.get(3);
      cache[5] = 'five';
      cache[6] = 'six';
      expect(cache.keys, [0, 3, 4, 5, 6]);
    });
    test('Most Recently Used', () {
      final cache = Cachette<int, String>(
        5,
        evictionPolicy: .mostRecentlyUsed,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }

      cache.get(0);
      cache.get(3);
      cache[5] = 'five';
      cache[6] = 'six';
      expect(cache.keys, [0, 1, 2, 4, 6]);
    });
    test('Least Frequently Used', () {
      final cache = Cachette<int, String>(
        5,
        evictionPolicy: .leastFrequentlyUsed,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
        for (int j = 0; j < 5 - i; j++) {
          cache.get(i);
        }
      }
      cache[5] = 'five';
      cache[6] = 'six';
      cache.get(6);
      cache.get(6);
      cache.get(6);
      cache[7] = 'seven';
      expect(cache.keys, [0, 1, 2, 6, 7]);
    });
    test('Most Frequently Used', () {
      final cache = Cachette<int, String>(
        5,
        evictionPolicy: .mostFrequentlyUsed,
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
        for (int j = 0; j < 5 - i; j++) {
          cache.get(i);
        }
      }
      cache[5] = 'five';
      cache[6] = 'six';
      cache.get(6);
      cache.get(6);
      cache.get(6);
      cache.get(6);
      cache[7] = 'seven';
      expect(cache.keys, [2, 3, 4, 5, 7]);
    });
    test('Don\'t Evict', () {
      final cache = Cachette<int, String>(
        3,
        evictionPolicy: .dontEvict,
      );
      cache[0] = 'zero';
      cache[1] = 'one';
      cache[2] = 'two';
      expect(cache.add(3, 'three').error, isA<CacheFullError>());
    });

    test('Rapid consecutive access deterministic MRU', () {
      for (int run = 0; run < 200; run++) {
        final cache = Cachette<int, String>(
          3,
          evictionPolicy: .mostRecentlyUsed,
        );
        cache.add(1, '1');
        cache.add(2, '2');
        cache.add(3, '3');
        cache.get(1);
        cache.get(2);
        cache.add(4, '4');
        expect(
          cache.containsKey(2),
          isFalse,
          reason:
              'Run $run: 2 was accessed after 1, so 2 must be evicted under MRU',
        );
      }
    });
  });
}
