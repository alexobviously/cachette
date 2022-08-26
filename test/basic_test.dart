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
      expect(cache[5], '5');
      expect(cache[27], '27');
      expect(cache[55], null);
    });
  });
}
