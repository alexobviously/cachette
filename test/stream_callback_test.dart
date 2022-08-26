import 'package:cachette/cachette.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Eviction Stream and Callback Tests', () {
    test('onEvict', () {
      List<int> evictedKeys = [];
      final cache = Cachette<int, String>(
        3,
        evictionPolicy: EvictionPolicy.fifo,
        onEvict: (e) => evictedKeys.add(e.key),
      );
      for (int i = 0; i < 5; i++) {
        cache.add(i, i.toString());
      }
      expect(evictedKeys, [0, 1]);
    });
  });
  test('Stream', () {
    final cache = Cachette<int, String>(3, evictionPolicy: EvictionPolicy.fifo);
    expectLater(cache.evictionStream, emitsInOrder([0, 1]));
    for (int i = 0; i < 5; i++) {
      cache.add(i, i.toString());
    }
  });
}
