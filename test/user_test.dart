import 'package:cachette/cachette.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

enum _TestUser {
  foo,
  bar,
  baz;
}

void main() {
  group('User Tests', () {
    test('Basic users', () {
      final cache = UserCachette<int, String, _TestUser>(5);
      cache.add(0, '0', user: _TestUser.foo);
      cache.add(0, '0', user: _TestUser.bar);
      expect(cache.getUsers(0).unwrap(), {_TestUser.foo, _TestUser.bar});
      cache.removeUser(0, _TestUser.foo);
      expect(cache.getUsers(0).unwrap(), {_TestUser.bar});
      cache.removeUser(0, _TestUser.bar);
      expect(cache.get(0).error, isA<NotFoundError>());
    });

    test('Unused eviction & unevictable users', () {
      final cache = UserCachette<int, String, _TestUser>(
        5,
        unevictableUsers: {_TestUser.baz},
        evictionPolicy: EvictionPolicy.fifo,
      );
      cache.add(0, '0', users: {_TestUser.foo, _TestUser.bar});
      cache.add(1, '1', users: {_TestUser.foo, _TestUser.bar, _TestUser.baz});
      for (final i in List.generate(5, (i) => i + 2)) {
        cache.add(i, i.toString());
      }
      // 0 gets evicted because there's no space
      // 1 doesn't get evicted because it has `baz`, so 2 does instead
      expect(cache.keys.toSet(), {1, 3, 4, 5, 6});
    });
  });
}
