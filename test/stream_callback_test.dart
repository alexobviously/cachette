import 'package:cachette/cachette.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Eviction Stream and Callback Tests', () {
    test('onEvict', () {
      List<int> evictedKeys = [];
      final cache = Cachette<int, String>(
        3,
        evictionPolicy: .fifo,
        onEvict: (e) => evictedKeys.add(e.key),
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }
      expect(evictedKeys, [0, 1]);
    });
  });
  test('Stream', () {
    final cache = Cachette<int, String>(3, evictionPolicy: .fifo);
    expectLater(cache.evictionStream.map((e) => e.key), emitsInOrder([0, 1]));
    for (int i = 0; i < 5; i++) {
      cache.add(i, i.toString());
    }
  });

  test('close closes stream and supports clear', () async {
    final cache = Cachette<int, String>(3);
    cache.add(1, 'one');
    expect(cache.isClosed, isFalse);

    await cache.close();
    expect(cache.isClosed, isTrue);
    expect(cache.length, 0);
  });

  test('Operations on closed cache return CacheClosedError', () async {
    final cache = Cachette<int, String>(3);
    cache.add(1, 'one');
    await cache.close(clear: false);

    expect(cache.get(1).error, isA<CacheClosedError>());
    expect(cache[1], isNull);
    expect(cache.add(2, 'two').error, isA<CacheClosedError>());
    expect(cache.remove(1).error, isA<CacheClosedError>());
    expect(cache.clean().error, isA<CacheClosedError>());
  });
}
