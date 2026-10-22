import 'package:cachette/cachette.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Basic Tests', () {
    test('Read/Write', () {
      final cache = Cachette<int, String>(100);
      for (int i = 0; i < 50; i++) {
        cache[i] = i.toString();
      }
      cache.remove(42);
      expect(cache[5], '5');
      expect(cache[27], '27');
      expect(cache[55], null);
      expect(cache[42], null);
    });

    test(
      'Updating an existing key in a full cache does not evict other keys',
      () {
        final cache = Cachette<int, String>(3);
        cache.add(1, 'one');
        cache.add(2, 'two');
        cache.add(3, 'three');

        expect(cache.length, 3);

        // Updating key 2 should NOT evict key 1 or 3
        cache.add(2, 'updated two');

        expect(cache.length, 3);
        expect(cache.containsKey(1), isTrue);
        expect(cache.containsKey(2), isTrue);
        expect(cache.containsKey(3), isTrue);
      },
    );
  });
}
