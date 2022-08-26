import 'package:cachette/cachette.dart';

void main(List<String> args) async {
  final cachette = Cachette<int, String>(3);
  cachette.add(0, 'zero');
  cachette.add(1, 'one');
  cachette.add(2, 'two');
  print(cachette.entries.map((e) => e.lastAccess.microsecondsSinceEpoch));
  print(cachette[0]);

  cachette.add(3, 'three');

  print(cachette.values);
  print(cachette.entries.map((e) => e.lastAccess.microsecondsSinceEpoch));
}
